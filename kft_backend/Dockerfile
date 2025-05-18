# Use an official Python runtime as a parent image
FROM python:3.12.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies (if any, e.g., for psycopg2)
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install pipenv if you are using it, or just copy requirements.txt
# COPY Pipfile Pipfile.lock /app/
# RUN pip install pipenv && pipenv install --system --deploy --ignore-pipfile

# Copy the requirements file into the container
COPY requirements.txt /app/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application's code into the container
COPY . /app/

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application using Gunicorn
# Adjust the number of workers as needed
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "kft_backend.wsgi:application"]