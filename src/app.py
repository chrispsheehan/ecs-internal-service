import os
from datetime import datetime
from fastapi import FastAPI, Request
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.extension.aws.trace import AwsXRayIdGenerator
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

image = os.getenv("IMAGE", "NOT_FOUND")
xray_endpoint = os.getenv("AWS_XRAY_ENDPOINT", "NOT_FOUND")

app = FastAPI()

tracer = trace.get_tracer("chris-local")

# Set up OpenTelemetry with AWS X-Ray support
trace.set_tracer_provider(
    TracerProvider(id_generator=AwsXRayIdGenerator())
)
otlp_exporter = OTLPSpanExporter(endpoint=xray_endpoint, insecure=True)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(otlp_exporter)
)

FastAPIInstrumentor().instrument_app(app)


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
