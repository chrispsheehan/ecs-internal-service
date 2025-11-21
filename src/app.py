import os
from datetime import datetime
from fastapi import FastAPI
import boto3
import requests
import httpx

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.resources import Resource
from opentelemetry.semconv.resource import ResourceAttributes
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.extension.aws.trace import AwsXRayIdGenerator
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.botocore import BotocoreInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor

image = os.getenv("IMAGE", "NOT_FOUND")
xray_endpoint = os.getenv("AWS_XRAY_ENDPOINT", "NOT_FOUND")
service_name = os.getenv("AWS_SERVICE_NAME", "NOT_FOUND")

app = FastAPI()
s3_client = boto3.client('s3')

tracer = trace.get_tracer(__name__)

# Set up OpenTelemetry with AWS X-Ray support
resource = Resource.create({ResourceAttributes.SERVICE_NAME: service_name})
trace.set_tracer_provider(
    TracerProvider(
        resource=resource,
        id_generator=AwsXRayIdGenerator()
    )
)

otlp_exporter = OTLPSpanExporter(endpoint=xray_endpoint, insecure=True)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(otlp_exporter)
)

FastAPIInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
BotocoreInstrumentor().instrument()
HTTPXClientInstrumentor().instrument()

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
        "hostname": hostname
    }

@app.get("/boto3-test")
def boto3_test():
    buckets = s3_client.list_buckets()  # boto3 call automatically traced
    bucket_names = [b["Name"] for b in buckets.get("Buckets", [])]
    return {"bucket_names": bucket_names}


@app.get("/requests-test")
def requests_test():
    response = requests.get("https://example.com")  # requests call automatically traced
    return {
        "status_code": response.status_code,
        "message": f"Received {len(response.content)} bytes",
        "imageUri": image
    }

@app.get("/httpx-test")
async def requests_test():
    async with httpx.AsyncClient() as client:
        response = await client.get("https://example.com")
    return {
        "status_code": response.status_code,
        "message": f"Received {len(response.content)} bytes",
        "imageUri": image
    }