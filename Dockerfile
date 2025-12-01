# Use Python 3.9 slim base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY website/ .

# Create data directory for file persistence
RUN mkdir -p /data

# Expose port for Flask app
EXPOSE 31415

# Run the Flask application with Gunicorn (production WSGI server)
# Use 1 worker to avoid concurrent NFS write conflicts
CMD ["gunicorn", "--bind", "0.0.0.0:31415", "--workers", "1", "--threads", "4", "--timeout", "120", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
