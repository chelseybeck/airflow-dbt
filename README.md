# Analytics Pipeline | dbt, Airflow, and Bigquery

Demo for running an analytics pipeline locally using Apache Airflow, dbt, and BigQuery (BQ)

We're using Google Cloud Platform (GCP) and BQ for the purposes of this demo, but if you're familiar with another public cloud or warehouse, you can substitute where applicable (i.e. `dbt-bigquery` -> `dbt-snowflake`)

dbt models can be found in the [models](/analytics/models) directory. Add `.sql` and `.yml` files there to create tables or views in the warehouse using this pipeline

The below instructions will walk you through deploying Airflow in a local Docker container. This was chosen for easy setup and development, but a cloud hosted Airflow instance is necessary for a production-level solution. Each major public cloud provider supports Airflow hosting

## Getting Started

### Clone this repo 
[Git required](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Clone the repo and open a terminal from the cloned directory

```bash
git clone https://github.com/chelseybeck/airflow-dbt-demo.git
```

### Prerequisites
- [Docker](https://docs.docker.com/engine/install/)
- [GCP account](https://cloud.google.com/solutions/smb)
- GCP Service Account (+ key.json) with the following permissions:
  - BigQuery Data Editor
  - BigQuery Data Viewer
  - Bigquery Job User

  The service account can be [created manually](https://cloud.google.com/iam/docs/service-accounts-create#creating) in the GCP UI or locally using the Terraform module in the `terraform` directory - [see details](/terraform/README.md)

#### Update `.env` variables

```bash
cp .env.example .env
```

Open `.env` and update the `GCP_PROJECT` with your project ID

### Run Airflow in a Docker container

Build the Docker image
```bash
DOCKER_BUILDKIT=0 sudo docker build -t airflow-dbt-demo .
```

Run the new container - change `local-path-to-key` to your local path
```bash
sudo docker run --env-file .env \
  -p 8080:8080 \
  -v /local-path-to-key/bigquery-key.json:/app/bigquery-airflow-dbt.json \
  --name airflow-dbt-demo-container \
  airflow-dbt-demo
```


Create Airflow admin user
```bash
docker exec -it airflow-dbt-demo-container airflow users create \
--username gstacy \
--firstname Gwen \
--lastname Stacy \
--role Admin \
--email gstacy@spiderverse.com
```

Access the [Airflow UI](http://0.0.0.0:8080/home) and login with admin user credentials

Turn on the `spotify_ingestion_dag` (which will trigger it to run) and once it completes, turn on the `daily_dbt_dag`. 

You should now see two new datasets in BQ:

`raw_ingestion` - contains the raw spotify table `spotify_top_2023_metadata`

`dev_spotify_derived` - contains the dbt models as defined in the models directory

#### Helpful Docker commands:

Stop the existing container (if running)
```bash
docker stop airflow-dbt-demo-container
```

Remove the existing container
```bash
docker rm airflow-dbt-demo-container
```
