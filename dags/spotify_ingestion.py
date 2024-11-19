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
data_directory = './spotify_data'

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

    # Function to load all CSV files in a directory into BigQuery
    def load_csvs_to_bq():
        hook = BigQueryHook()
        bq_client = hook.get_client()

        # Iterate through all CSV files in the specified directory
        for file_name in os.listdir(data_directory):
            if file_name.endswith('.csv'):
                table_name = file_name.replace('.csv', '')
                file_path = os.path.join(data_directory, file_name)
                
                # Read the CSV file into a pandas DataFrame
                df = pd.read_csv(file_path)

                # Load DataFrame into BigQuery table
                table_id = f'{project_id}.{raw_ingestion_dataset}.{table_name}'
                bq_client.load_table_from_dataframe(df, table_id)

    # Task to load all CSV files from the directory into BigQuery
    load_csvs_to_bq_task = PythonOperator(
        task_id='load_csvs_to_bq',
        python_callable=load_csvs_to_bq,
    )

    # Define task order
    create_dataset_task >> load_csvs_to_bq_task
