import boto3
import os
import time

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.extension.aws.trace import AwsXRayIdGenerator
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

QUEUE_URL  = os.environ['AWS_SQS_QUEUE_URL']
AWS_REGION = os.environ['AWS_REGION']

XRAY_ENDPOINT = os.getenv("AWS_XRAY_ENDPOINT", "NOT_SET")
SERVICE_NAME  = os.getenv("AWS_SERVICE_NAME", "consumer-service")
POLL_TIMEOUT  = int(os.getenv("POLL_TIMEOUT", "60"))


sqs = boto3.client(
    'sqs',
    region_name=AWS_REGION)

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

def poll():
    with tracer.start_as_current_span("sqs.poll") as span:
        span.set_attribute("messaging.system", "aws.sqs")
        span.set_attribute("messaging.destination.name", QUEUE_URL)
        
        response = sqs.receive_message(
            QueueUrl=QUEUE_URL,
            MaxNumberOfMessages=10,
            WaitTimeSeconds=0,
            VisibilityTimeout=30
        )
        
        messages = response.get('Messages', [])
        if not messages:
            print("No messages found")
        else:
            for msg in messages:
                with tracer.start_as_current_span("sqs.process_message") as msg_span:
                    msg_span.set_attribute("messaging.message_id", msg['MessageId'])
                    print(f"Processing: {msg['Body']}")
                    sqs.delete_message(QueueUrl=QUEUE_URL, ReceiptHandle=msg['ReceiptHandle'])
                    print(f"Deleted {msg['MessageId']}")

if __name__ == "__main__":
    print(f"Starting SQS poller for {QUEUE_URL}")
    while True:
        poll()
        time.sleep(POLL_TIMEOUT)
