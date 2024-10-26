from airflow import DAG
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.operators.python_operator import PythonOperator
from datetime import datetime
import pandas as pd
import os
from dotenv import load_dotenv

default_args = {
    'start_date': datetime(2024, 10, 25),
    'email_on_failure': False,
    'email_on_retry': False,
}

load_dotenv()

# Set in .env file
project_id = os.getenv('GCP_PROJECT')

raw_ingestion_dataset = 'raw_ingestion'
raw_spotify_table = 'spotify_top_2023_metadata'

with DAG('spotify_ingestion_dag', default_args=default_args, schedule_interval='@daily', catchup=False) as dag:

    # Task to create BigQuery dataset if it doesn't exist
    create_dataset_query = f"""
    CREATE SCHEMA IF NOT EXISTS `{project_id}.{raw_ingestion_dataset}`
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

    # Function to load raw Spotify data into BigQuery
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

    # Define task order
    create_dataset_task >> load_csv_to_bq_task
