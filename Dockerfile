# Stage 1: Build stage
FROM python:3.10-slim-bullseye AS builder

WORKDIR /app

# Install build and OpenCV-related dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Setup virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Final runtime image
FROM python:3.10-slim-bullseye

WORKDIR /app

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy project files
COPY . .

# Optional: collect static files (only if STATIC_ROOT is configured)
RUN python manage.py collectstatic --noinput

# Expose app port
EXPOSE 8000

# Protobuf workaround for DeepFace / TensorFlow
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

CMD ["gunicorn", "crime.wsgi:application", "--bind", "0.0.0.0:8000"]
