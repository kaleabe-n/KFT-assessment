# Use an official Python runtime as a parent image
FROM python:3.10-slim-buster

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app
ENV APP_HOME=/app

# Install system dependencies (if any, e.g., for psycopg2)
# Create a non-root user and group
RUN groupadd -r appuser && useradd -r -g appuser -d ${APP_HOME} -s /sbin/nologin -c "Application User" appuser

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY --chown=appuser:appuser requirements.txt ${APP_HOME}/

# Switch to the non-root user before installing dependencies
USER appuser

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application's code into the container
# Ensure the app home directory exists and set permissions
USER root
RUN mkdir -p ${APP_HOME} && chown -R appuser:appuser ${APP_HOME}
USER appuser

COPY --chown=appuser:appuser . ${APP_HOME}/

# Expose the port the app runs on
EXPOSE 8000

# Switch back to root if Gunicorn needs to bind to a privileged port (<=1024),
# then Gunicorn can drop privileges. For port 8000, appuser should be fine.
# USER root

# Command to run the application using Gunicorn
# Adjust the number of workers as needed
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "kft_backend.wsgi:application"]