# ---- Stage 1: FastAPI App Responder ----
FROM python:3.11-slim AS app-responder

WORKDIR /usr/app

# Install dependencies
COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source
COPY ./src ./app

# Set env and expose port
ENV PORT=3000
EXPOSE 3000

# Default command for app
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:3000", "app.responder.app:app"]

# ---- Stage 2: Collector ----
FROM public.ecr.aws/aws-observability/aws-otel-collector:latest AS collector

COPY ./collector-config.yaml /opt/aws/aws-otel-collector/etc/collector-config.yaml

CMD ["--config", "/opt/aws/aws-otel-collector/etc/collector-config.yaml"]


# ---- Stage 3: DEBUG ----
FROM alpine:latest AS debug

RUN apk add --no-cache curl

CMD ["sleep", "infinity"]


# ---- Stage 1: FastAPI App Caller ----
FROM python:3.11-slim AS app-caller

WORKDIR /usr/app

# Install dependencies
COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source
COPY ./src ./app

# Set env and expose port
ENV PORT=3000
EXPOSE 3000

# Default command for app
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:3000", "app.caller.app:app"]
