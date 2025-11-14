# Base image with python 3.11 slim
FROM python:3.11-slim

WORKDIR /usr/app

# Install dependencies (adjust as per your real dependencies)
COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source
COPY ./app ./app

# Expose port
ENV PORT=3000
EXPOSE 3000

# Run app using uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "3000"]
