# Analytics Pipeline | dbt, Airflow, and Bigquery

This repository contains a demo with instructions for scheduling an analytics pipeline locally using Apache Airflow to schedule dbt jobs for a BigQuery warehouse.

We're using Google Cloud Platform (GCP) and BigQuery (BQ) for the purposes of this demo, but if you're familiar with another public cloud or warehouse, you can substitute where applicable (i.e. `dbt-bigquery` -> `dbt-snowflake`).

## Getting Started

### Clone this repo (or fork it if you'd like to contribute)
Clone the repo and open a terminal from the cloned directory

```bash
git clone https://github.com/chelseybeck/airflow-dbt.git
```

### Prerequisites

- [GCP account](https://cloud.google.com/solutions/smb)
- Python 3.11+ - [download](https://www.python.org/downloads/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Google Cloud Command Line Interface (CLI)](https://cloud.google.com/sdk/docs/install) (for authentication with BigQuery)
- GCP Service Account with the following permissions:
  - BigQuery Data Editor
  - BigQuery Data Viewer
  - Bigquery Job User

  The service account can be [created manually](https://cloud.google.com/iam/docs/service-accounts-create#creating) in the GCP UI or using the Terraform module in the `terraform` directory - [see details](/terraform/README.md)

## Python Environment Setup

It's recommended to use a virtual environment to isolate dependencies. Here's how to set it up:

1. Create a virtual environment:

    ```bash
    python3 -m venv venv
    ```

2. Activate the virtual environment:
- On macOS/Linux:

    ```bash
    source venv/bin/activate
    ```
- On Windows:

    ```bash
    venv\Scripts\activate
    ```

3. Upgrade `pip`

    ```bash
    pip install --upgrade pip
    ```

### Install Dependencies

```bash
pip install -r requirements.txt
```

## Set up Environment Variables

1. Copy the example `.env` file
    ```bash
    cp .env.example .env
    ```
2. Replace the file paths in `.env` with your system paths

## Initialize Airflow and Run DAG


1. Update DAG directory location:

    Find Airflow's Home directory
    - on Windows:
        ```bash
        echo %AIRFLOW_HOME%
        ```
    - on macOS/Linux
        ```bash
        echo $AIRFLOW_HOME
        ```
    Navigate to Airflow's home directory and open the `airflow.cfg` file. Change the `dags_folder` path to the `airflow-dbt` code repository and save. For example:
    ```
    dags_folder = /Users/username/GitHub/airflow-dbt/dags
    ```
    Remove authentication (easiest option if running demo locally, otherwise [set it up](https://airflow.apache.org/docs/apache-airflow-providers-fab/stable/auth-manager/api-authentication.html))
    ```
    auth_backend # delete this line or set it up
    ```
    Optional - remove DAG examples. When set to true, many examples are provided on the home page in the UI when Airflow is started
    ```
    load_examples = False
    ```

2. Initialize the database
    ```bash
    airflow db migrate
    ```

3. Start the Airflow webserver:

    ```bash
    airflow webserver --port 8080
    ```

    Access the Airflow UI at `localhost:8080/home`
    [airflow home](http://0.0.0.0:8080/home)

4. Start the scheduler

    ```bash
    airflow scheduler
    ```

5. Run the DAGs from [Airflow's UI](http://0.0.0.0:8080/home):
  - Click on the DAG `spotify_ingestion_dag`
    - Loads Spotify data from a csv file into BigQuery
  - Click the 'play' button to trigger the DAG (upper right corner)

  - Click on the DAG `daily_dbt_dag`
    - Runs dbt jobs ([models directory](/analytics/models)) 
  - Click the 'play' button to trigger the DAG (upper right corner)
