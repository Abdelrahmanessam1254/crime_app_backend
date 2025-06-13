FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy code
COPY . /app/

# Create virtual environment and install Python packages
RUN python -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r requirements.txt

# Add venv to PATH
ENV PATH="/opt/venv/bin:$PATH"

# Collect static files (optional, for production)
RUN python manage.py collectstatic --noinput

# Expose port (optional)
EXPOSE 8000

# Start gunicorn
CMD ["gunicorn", "crime.wsgi:application", "--bind", "0.0.0.0:8000"]
