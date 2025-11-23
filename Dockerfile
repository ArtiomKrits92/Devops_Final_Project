# Use Python 3.9 slim base image
FROM python:3.9-slim

# Copy application files
COPY website/ /app/

# Install dependencies
RUN pip install --no-cache-dir flask

# Create data directory for file persistence
RUN mkdir -p /data

# Expose port for Flask app
EXPOSE 31415

# Run the Flask application
CMD ["python", "/app/app.py"]
