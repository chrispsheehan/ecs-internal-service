# ecs-internal-service

## 🚀 setup roles for ci

```sh
just tg dev aws/oidc apply
```

## 🚀 aws requirements

needs vpc named `vpc` with private and public subnets

## 🚀 usage

start locally with `docker compose up --build`

debug with `docker exec -it debug-tool /bin/sh`

can hit the app with `curl http://localhos6:3000/health`


## 🚀 local tunnel

needs `brew install --cask session-manager-plugin`

`just local-connect caller`



debug
curl -X POST https://xray.eu-west-2.amazonaws.com/ -H "Content-Type: application/x-amz-json-1.1" -H "X-Amz-Target: AWSXRay_20160125.PutTraceSegments" -d '{"TraceSegmentDocuments":["{\"id\":\"1-5f84c7a8-869cd2224b6d8afd7a5d278f\",\"name\":\"my-service\",\"start_time\":1602611816.123,\"end_time\":1602611816.456}"]}' --max-time 3