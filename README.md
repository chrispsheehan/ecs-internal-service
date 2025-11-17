# ecs-internal-service

## 🚀 setup roles for ci

```sh
just tg dev aws/oidc apply
```

## 🚀 aws requirements

needs vpc named vpc with private and public subnets


need to run (xray host)

docker run --rm -it \
  -p 2000:2000/udp \
  -v ~/.aws:/root/.aws:ro \
  -e AWS_REGION=eu-west-2 \
  -e AWS_ACCESS_KEY_ID=secret \
  -e AWS_SECRET_ACCESS_KEY=secret \
  -e AWS_SDK_LOAD_CONFIG=1 \
  amazon/aws-xray-daemon:latest \
  -o


and otel collector

docker run --rm -p 4317:4317 \
  -v $(pwd)/collector-config.yaml:/etc/collector-config.yaml:ro \
  -v ~/.aws:/root/.aws:ro \
  -e AWS_REGION=eu-west-2 \
  -e AWS_ACCESS_KEY_ID=secret \
  -e AWS_SECRET_ACCESS_KEY=secret \
  -e AWS_SDK_LOAD_CONFIG=1 \
  public.ecr.aws/aws-observability/aws-otel-collector:latest \
  --config /etc/collector-config.yaml
