# Start with the official Python 3.12 slim image
FROM python:3.12

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV AIRFLOW_HOME=/root/airflow

# Install system dependencies for Airflow and dbt
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && apt-get clean

# Upgrade pip
RUN pip install --upgrade pip

# Copy requirements and install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

# Copy the entire project into the container
COPY . /app

# Set the working directory
WORKDIR /app

# Copy custom airflow.cfg to the AIRFLOW_HOME directory
COPY airflow.cfg $AIRFLOW_HOME/airflow.cfg

# Expose port 8080 for Airflow web server
EXPOSE 8080

# Initialize the database during build
RUN airflow db init

# Set the default command to start Airflow, performing migrations if needed
CMD ["bash", "-c", "airflow db migrate && airflow connections get 'google_cloud_default' || airflow connections add 'google_cloud_default' --conn-type 'google_cloud_platform' --conn-extra \"{\\\"extra__google_cloud_platform__project\\\": \\\"${GCP_PROJECT}\\\"}\" && airflow webserver & airflow scheduler"]
