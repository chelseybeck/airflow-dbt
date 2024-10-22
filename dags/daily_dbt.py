from airflow import DAG
from airflow_dbt.operators.dbt_operator import DbtRunOperator, DbtTestOperator
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.operators.python_operator import PythonOperator  # Ensure this is imported
from datetime import datetime
from dotenv import load_dotenv
import os
import pandas as pd

default_args = {
    'start_date': datetime(2024, 10, 18),
    'email_on_failure': False,
    'email_on_retry': False,
}

# Load the environment variables from the .env file
load_dotenv()

profiles_dir = os.getenv('PROFILES_DIR')  # Set the dbt profiles directory name in your .env file
dbt_project = os.getenv('DBT_PROJECT_DIR')  # Set the dbt project directory name in your .env file
raw_ingestion_dataset = os.getenv('RAW_INGESTION_DATASET')  # Set the BigQuery dataset name in your .env file
raw_spotify_table = os.getenv('RAW_SPOTIFY_TABLE')  # Set the BigQuery table name in your .env file
project_id = os.getenv('GCP_PROJECT')  # Set your Google Cloud Project ID in your .env file

with DAG('daily_dbt_dag', default_args=default_args, schedule_interval='@daily', catchup=False) as dag:

    # Task to create BigQuery dataset if it doesn't exist
    create_dataset_query = f"""
    CREATE SCHEMA IF NOT EXISTS `{project_id}.{raw_ingestion_dataset}`;
    """
    create_dataset_task = BigQueryInsertJobOperator(
        task_id='create_bq_dataset',
        configuration={
            "query": {
                "query": create_dataset_query,
                "useLegacySql": False,
            }
        },
        location='US'  # Set your dataset location, adjust if different
    )

    # Function to load local CSV file into BigQuery
    def load_csv_to_bq():
        hook = BigQueryHook()
        bq_client = hook.get_client()

        # Read the CSV file into a pandas DataFrame
        df = pd.read_csv('./spotify_top_2023_metadata.csv')

        # Load DataFrame into BigQuery table
        bq_client.load_table_from_dataframe(
            df, f'{raw_ingestion_dataset}.{raw_spotify_table}'
        )

    # Task to load local CSV file into BigQuery
    load_csv_to_bq_task = PythonOperator(
        task_id='load_csv_to_bq',
        python_callable=load_csv_to_bq,
    )

    # Task to run dbt models using DbtRunOperator
    dbt_run = DbtRunOperator(
        task_id='dbt_run',
        dir=dbt_project,
        profiles_dir=profiles_dir,
    )

    # Task to run dbt tests using DbtTestOperator
    dbt_test = DbtTestOperator(
        task_id='dbt_test',
        dir=dbt_project,
        profiles_dir=profiles_dir,
        retries=0  # Optional: disable retries
    )

    # Define the order of tasks
    create_dataset_task >> load_csv_to_bq_task >> dbt_run >> dbt_test
