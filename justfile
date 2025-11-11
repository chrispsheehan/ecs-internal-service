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
        --interactive \
        --command "/bin/sh"