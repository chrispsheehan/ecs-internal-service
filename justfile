_default:
    just --list

git-tidy:
    #!/usr/bin/env bash
    git fetch --prune
    for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
        git branch -d $branch
    done


branch name:
    #!/usr/bin/env bash
    git fetch origin
    git checkout main
    git pull origin
    git branch --set-upstream-to=origin/main {{ name }}
    git pull
    git checkout -b {{ name }}
    git push -u origin {{ name }}


format:    
    #!/usr/bin/env bash
    terraform fmt -recursive
    terragrunt hclfmt


# Terragrunt operation on {{module}} containing terragrunt.hcl
tg env module op:
    #!/usr/bin/env bash
    cd {{justfile_directory()}}/infra/live/{{env}}/{{module}} ; terragrunt {{op}}


tg-all op:
    #!/usr/bin/env bash
    cd {{justfile_directory()}}/infra/live 
    terragrunt run-all {{op}}

get-task-id:
    #!/usr/bin/env bash
    aws ecs list-tasks \
        --region eu-west-2 \
        --cluster "ecs-internal-service-cluster" \
        --service-name "ecs-internal-service-service" \
        --desired-status RUNNING \
        --query 'taskArns[-1]' --output text

local-connect:
    #!/usr/bin/env bash
    TASK_ID=$(just get-task-id)
    aws ecs execute-command \
        --region eu-west-2 \
        --cluster "ecs-internal-service-cluster" \
        --task "$TASK_ID" \
        --container "ecs-internal-service-debug" \
        --interactive \
        --command "/bin/sh"


install:
    #!/usr/bin/env bash
    python3 -m venv env
    source env/bin/activate
    pip3 install -r requirements.txt


start-adot-collector:
    #!/usr/bin/env bash
    CONTAINER_NAME="aws-adot-collector"
    if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
        echo "Container '${CONTAINER_NAME}' is already running."
    else
        echo "Starting container '${CONTAINER_NAME}'..."
        docker run -d -p 4317:4317 \
            -v $(pwd)/collector-config.yaml:/etc/collector-config.yaml:ro \
            -v ~/.aws:/root/.aws:ro \
            --env-file $(pwd)/.env \
            --name ${CONTAINER_NAME} \
            public.ecr.aws/aws-observability/aws-otel-collector:latest \
            --config /etc/collector-config.yaml
    fi

start:
    #!/usr/bin/env bash
    just start-adot-collector
    source env/bin/activate
    AWS_XRAY_ENDPOINT="http://localhost:4317" uvicorn src.app:app --reload --host 0.0.0.0 --port 8000 &

    echo "FastAPI is running with debugpy enabled on port 8000"
    echo "Open VS Code and attach debugger to 'FastAPI: Uvicorn (reload)' configuration to debug."

    # Wait for uvicorn to exit before script ends, if needed
    wait