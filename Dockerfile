FROM python:3.9-alpine3.13

LABEL maintainer="Suraj"
ENV PYTHONUNBUFFERED=1

# Copy app and requirement files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app
EXPOSE 8000

# Default argument
ARG DEV=false

# Create virtual environment and install deps
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --no-cache --update \
        postgresql-client \
        libpq \
        gcc \
        python3-dev \
        musl-dev \
        postgresql-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    if [ "$DEV" != "true" ]; then \
        apk del gcc musl-dev python3-dev postgresql-dev; \
    fi && \
    rm -rf /tmp && \
    adduser --disabled-password --no-create-home django-user

ENV PATH="/py/bin:$PATH"
USER django-user