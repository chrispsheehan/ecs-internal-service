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

`just local-connect`
