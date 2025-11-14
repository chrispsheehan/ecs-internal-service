from fastapi import FastAPI, Request
import os
from datetime import datetime

app = FastAPI()

image = os.getenv("IMAGE", "NOT_FOUND")

@app.middleware("http")
async def log_requests(request: Request, call_next):
    print(f"Request received: {request.method} {request.url.path}")
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
