import os
from datetime import datetime
from fastapi import FastAPI, Request
import boto3
import requests
import httpx


from opentelemetry import trace, propagate
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.resources import Resource
from opentelemetry.semconv.resource import ResourceAttributes
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.extension.aws.trace import AwsXRayIdGenerator
from opentelemetry.trace import SpanKind
from opentelemetry.instrumentation.wsgi import collect_request_attributes  

image = os.getenv("IMAGE", "NOT_FOUND")
xray_endpoint = os.getenv("AWS_XRAY_ENDPOINT", "NOT_FOUND")
service_name = os.getenv("AWS_SERVICE_NAME", "NOT_FOUND")

app = FastAPI()
s3_client = boto3.client('s3')

resource = Resource.create({ResourceAttributes.SERVICE_NAME: service_name})
trace.set_tracer_provider(
    TracerProvider(
        resource=resource,
        id_generator=AwsXRayIdGenerator(),
    )
)

otlp_exporter = OTLPSpanExporter(endpoint=xray_endpoint, insecure=True)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(otlp_exporter)
)

tracer = trace.get_tracer(__name__)
PROPAGATOR = propagate.get_global_textmap()

@app.middleware("http")
async def otel_server_middleware(request: Request, call_next):
    # Extract parent context from incoming headers
    ctx = PROPAGATOR.extract(request.headers.__getitem__)

    # Attributes similar to what FastAPI/ASGI instrumentation would set
    attributes = collect_request_attributes(request.scope)
    attributes["http.route"] = request.url.path

    with tracer.start_as_current_span(
        name=f"{request.method} {request.url.path}",
        context=ctx,
        kind=SpanKind.SERVER,
        attributes=attributes,
    ) as span:
        response = await call_next(request)
        span.set_attribute("http.status_code", response.status_code)
        return response


@app.get("/health")
async def health():
    return {"msg": "Hello, this is your API"}


@app.get("/host")
async def host_info():
    hostname = os.uname().nodename
    current_time = datetime.utcnow().isoformat()
    return {
        "message": f"Request handled by backend at {current_time}",
        "imageUri": image,
        "hostname": hostname,
    }


@app.get("/boto3-test")
def boto3_test():
    with tracer.start_as_current_span(
        "S3 ListBuckets",
        kind=SpanKind.CLIENT,
        attributes={
            "rpc.system": "aws-api",
            "rpc.service": "s3",
            "rpc.method": "ListBuckets",
            "aws.region": s3_client.meta.region_name,
        },
    ) as span:
        buckets = s3_client.list_buckets()
        bucket_names = [b["Name"] for b in buckets.get("Buckets", [])]
        span.set_attribute("aws.s3.bucket_count", len(bucket_names))
        return {"bucket_names": bucket_names}


@app.get("/requests-test")
def requests_test():
    url = "https://example.com"

    with tracer.start_as_current_span(
        "HTTP GET",
        kind=SpanKind.CLIENT,
        attributes={
            "http.method": "GET",
            "http.url": url,
        },
    ) as span:
        headers = {}
        PROPAGATOR.inject(headers.__setitem__)

        response = requests.get(url, headers=headers)

        span.set_attribute("http.status_code", response.status_code)
        span.set_attribute("http.response_content_length", len(response.content))

    return {
        "status_code": response.status_code,
        "message": f"Received {len(response.content)} bytes",
        "imageUri": image,
    }


@app.get("/httpx-test")
async def httpx_test():
    url = "https://example.com"

    async with httpx.AsyncClient() as client:
        with tracer.start_as_current_span(
            "HTTP GET",
            kind=SpanKind.CLIENT,
            attributes={
                "http.method": "GET",
                "http.url": url,
            },
        ) as span:
            headers = {}
            PROPAGATOR.inject(headers.__setitem__)

            response = await client.get(url, headers=headers)

            span.set_attribute("http.status_code", response.status_code)
            span.set_attribute("http.response_content_length", len(response.content))

    return {
        "status_code": response.status_code,
        "message": f"Received {len(response.content)} bytes",
        "imageUri": image,
    }
