# Base image with python 3.11 slim
FROM python:3.11-slim

WORKDIR /usr/app

# Install dependencies (adjust as per your real dependencies)
COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn uvicorn[standard]

# Copy app source
COPY ./src ./app

# Expose port
ENV PORT=3000
EXPOSE 3000

# Run app using uvicorn
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:3000", "app.app:app"]
