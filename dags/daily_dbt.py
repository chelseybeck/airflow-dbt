from airflow import DAG
from airflow_dbt.operators.dbt_operator import DbtRunOperator, DbtTestOperator
from datetime import datetime
from dotenv import load_dotenv
import os

default_args = {
    'start_date': datetime(2024, 10, 18),
    'email_on_failure': False,
    'email_on_retry': False,
}

# Load the environment variables from the .env file
load_dotenv()

# Set in .env file
profiles_dir = os.getenv('PROFILES_DIR')  
dbt_project = os.getenv('DBT_PROJECT_DIR')

with DAG('daily_dbt_dag', default_args=default_args, schedule_interval='@daily', catchup=False) as dag:

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

    # Define task order
    dbt_run >> dbt_test
