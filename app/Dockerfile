FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
RUN useradd --create-home --uid 1000 appuser
COPY --from=builder /install /usr/local
COPY --chown=1000:1000 orders_api.py .

USER 1000:1000
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD [ "python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health')" ]

CMD [ "python", "orders_api.py" ]