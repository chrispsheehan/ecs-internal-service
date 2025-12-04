FROM public.ecr.aws/aws-observability/aws-otel-collector:latest AS collector

COPY ./collector-config.yaml /opt/aws/aws-otel-collector/etc/collector-config.yaml

CMD ["--config", "/opt/aws/aws-otel-collector/etc/collector-config.yaml"]



FROM alpine:latest AS debug

RUN apk add --no-cache curl

CMD ["sleep", "infinity"]



FROM python:3.11-slim AS app-responder

WORKDIR /usr/app

COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src ./app

ENV PORT=3000
EXPOSE 3000

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:3000", "app.responder.app:app"]



FROM python:3.11-slim AS app-caller

WORKDIR /usr/app

COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src ./app

ENV PORT=3000
EXPOSE 3000

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:3000", "app.caller.app:app"]


FROM python:3.11-slim AS consumer

WORKDIR /usr/app

COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src/consumer ./consumer

CMD ["python", "consumer/app.py"]
