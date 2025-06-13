FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install Python dependencies in a virtual environment
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install -r requirements.txt

# Set environment PATH to use the venv by default
ENV PATH="/opt/venv/bin:$PATH"

# Collect static files (optional, for production)
RUN /opt/venv/bin/python manage.py collectstatic --noinput

# Expose port
EXPOSE 8000

# Run the app using gunicorn
CMD ["gunicorn", "crime.wsgi:application", "--bind", "0.0.0.0:8000"]
