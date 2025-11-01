FROM python:3.9-slim-bullseye

LABEL maintainer="Suraj"
ENV PYTHONUNBUFFERED=1 \
    PATH="/py/bin:$PATH"

ARG DEV=false

WORKDIR /app

# Install system dependencies for both cases
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    python3-dev \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirement files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# --- Smart psycopg2 switch ---
RUN set -eux; \
    python -m venv /py; \
    /py/bin/pip install --upgrade pip; \
    if [ "$DEV" = "true" ]; then \
        echo "Switching psycopg2 → psycopg2-binary for DEV build"; \
        sed -i 's/^psycopg2$/psycopg2-binary/' /tmp/requirements.txt || true; \
        sed -i 's/^psycopg2==/psycopg2-binary==/' /tmp/requirements.txt || true; \
    fi; \
    /py/bin/pip install --no-cache-dir -r /tmp/requirements.txt; \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install --no-cache-dir -r /tmp/requirements.dev.txt; \
    fi; \
    if [ "$DEV" != "true" ]; then \
        echo "Cleaning up build dependencies for prod..."; \
        apt-get purge -y gcc python3-dev libc6-dev || true; \
        apt-get autoremove -y; \
        apt-get clean; \
    fi; \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY ./app /app

RUN useradd --create-home django-user
USER django-user

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]