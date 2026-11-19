FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    HOST="0.0.0.0"

WORKDIR /app

COPY requirements-demo.txt .
RUN pip install --no-cache-dir -r requirements-demo.txt

COPY demo_app.py .
COPY static ./static

EXPOSE 8000 10000

CMD ["sh", "-c", "uvicorn demo_app:app --host 0.0.0.0 --port ${PORT:-8000}"]
