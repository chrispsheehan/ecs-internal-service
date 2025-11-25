import os
from datetime import datetime
from typing import Dict, Any

from fastapi import FastAPI, Request, HTTPException
import httpx

from opentelemetry import trace, propagate
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.extension.aws.trace import AwsXRayIdGenerator
from opentelemetry.trace import SpanKind

# -------------------------
# env
# -------------------------
DOWNSTREAM_URL = os.getenv("DOWNSTREAM_URL", "http://downstream:8080")
XRAY_ENDPOINT  = os.getenv("AWS_XRAY_ENDPOINT", "NOT_SET")
SERVICE_NAME   = os.getenv("AWS_SERVICE_NAME", "caller-service")
IMAGE          = os.getenv("IMAGE", "NOT_FOUND")

# -------------------------
# otel (x-ray ids + otlp)
# -------------------------
resource = Resource.create({"service.name": SERVICE_NAME})
trace.set_tracer_provider(
    TracerProvider(
        resource=resource,
        id_generator=AwsXRayIdGenerator(),
    )
)
otlp_exporter = OTLPSpanExporter(endpoint=XRAY_ENDPOINT, insecure=True)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))

tracer = trace.get_tracer(__name__)
PROPAGATOR = propagate.get_global_textmap()

# -------------------------
# app
# -------------------------
app = FastAPI()

@app.middleware("http")
async def otel_server_middleware(request: Request, call_next):
    # extract upstream context (if any)
    ctx = PROPAGATOR.extract(request.headers)

    attrs = {
        "http.method": request.method,
        "http.scheme": request.url.scheme,
        "http.host": request.headers.get("host", ""),
        "http.target": request.url.path,
        "http.user_agent": request.headers.get("user-agent", "")
    }

    with tracer.start_as_current_span(
        name=f"{request.method} {request.url.path}",
        context=ctx,
        kind=SpanKind.SERVER,
        attributes=attrs,
    ) as span:
        try:
            resp = await call_next(request)
            span.set_attribute("http.status_code", resp.status_code)
            return resp
        except Exception as exc:
            span.record_exception(exc)
            span.set_attribute("http.status_code", 500)
            raise

# -------------------------
# helpers
# -------------------------
async def call_downstream_same_path(path: str) -> Dict[str, Any]:
    url = f"{DOWNSTREAM_URL.rstrip('/')}{path}"
    with tracer.start_as_current_span(
        "HTTP GET downstream",
        kind=SpanKind.CLIENT,
        attributes={"http.method": "GET", "http.url": url},
    ) as span:
        headers: Dict[str, str] = {}
        PROPAGATOR.inject(headers)
        try:
            async with httpx.AsyncClient(timeout=2.0) as client:
                resp = await client.get(url, headers=headers)
            span.set_attribute("http.status_code", resp.status_code)
            span.set_attribute("http.response_content_length", len(resp.content))
            resp.raise_for_status()
            if "application/json" in resp.headers.get("content-type", "").lower():
                body = resp.json()
            else:
                body = resp.text
            return {"downstream_status": resp.status_code, "downstream_body": body}
        except Exception as exc:
            span.record_exception(exc)
            raise HTTPException(status_code=502, detail=f"downstream failed: {exc}")

# -------------------------
# routes (same names as downstream)
# -------------------------
@app.get("/health")
async def health():
    return {"msg": f"{SERVICE_NAME}  ok"}

@app.get("/host")
async def host():
    hostname = os.uname().nodename
    current_time = datetime.utcnow().isoformat()
    downstream = await call_downstream_same_path("/host")
    return {
        "caller": {
            "message": f"caller handled at {current_time}",
            "imageUri": IMAGE,
            "hostname": hostname,
            "service": SERVICE_NAME,
        },
        **downstream,
    }

@app.get("/boto3-test")
async def boto3_test():
    return await call_downstream_same_path("/boto3-test")

@app.get("/requests-test")
async def requests_test():
    return await call_downstream_same_path("/requests-test")

@app.get("/httpx-test")
async def httpx_test():
    return await call_downstream_same_path("/httpx-test")
