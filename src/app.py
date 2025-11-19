import os
from datetime import datetime
from fastapi import FastAPI, Request
import boto3
import requests
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.extension.aws.trace import AwsXRayIdGenerator
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.botocore import BotocoreInstrumentor

image = os.getenv("IMAGE", "NOT_FOUND")
xray_endpoint = os.getenv("AWS_XRAY_ENDPOINT", "NOT_FOUND")

app = FastAPI()

tracer = trace.get_tracer(__name__)

s3_client = boto3.client('s3')

# Set up OpenTelemetry with AWS X-Ray support
trace.set_tracer_provider(
    TracerProvider(id_generator=AwsXRayIdGenerator())
)
otlp_exporter = OTLPSpanExporter(endpoint=xray_endpoint, insecure=True)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(otlp_exporter)
)

FastAPIInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
BotocoreInstrumentor().instrument()



@app.middleware("http")
async def otel_middleware(request: Request, call_next):
    span_name = f"HTTP {request.method} {request.url.path}"
    with tracer.start_as_current_span(span_name):
        response = await call_next(request)
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
