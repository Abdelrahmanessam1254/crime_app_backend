FROM python:3.10-slim

# Install OpenCV dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy code
COPY . /app/

# Set up virtual environment and install dependencies
RUN python -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r requirements.txt

ENV PATH="/opt/venv/bin:$PATH"

# Collect static files (optional)
RUN python manage.py collectstatic --noinput

# Expose port (optional)
EXPOSE 8000

ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

CMD ["gunicorn", "crime.wsgi:application", "--bind", "0.0.0.0:8000"]

