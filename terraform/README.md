# Create Resources with Terraform

## Prerequisites:

[Install Terraform](https://developer.hashicorp.com/terraform/install)

Authenticate to Google Cloud Platform (GCP)
```bash
gcloud auth login application-default
```

## Create Airflow Service Account (GCP -> IAM)
Running the below commands will create a service account in GCP that Airflow will use to connect to BigQuery (BQ). It will also assign the roles [BigQuery Data Editor](https://cloud.google.com/bigquery/docs/access-control#bigquery.dataEditor), [BigQuery Job User](https://cloud.google.com/bigquery/docs/access-control#bigquery.jobUser), and [BigQuery Data Viewer](https://cloud.google.com/bigquery/docs/access-control#bigquery.dataViewer). 

Check out the [service account module](/modules/service_account/main.tf) to see how the resources are created.

Using your terminal:

1. Navigate to the `terraform` directory

    ```bash
    cd terraform
    ```

2. Open `terraform.tfvars` and update with your project id and location to save key file
    ```hcl
    // replace with your GCP project ID
    project_id           = "gcp-project-id"

    // replace with the location to save service account key file
    key_file_path        = "/Users/username/bigquery-key.json"
    ```

3. Initialize Terraform

    ```bash
    terraform init
    ```

4. Run a Plan
Returns an output of resources to be created

    ```bash
    terraform plan
    ``` 

5. Apply configuration
Applies the configuration as reflected on the plan

    ```bash
    terraform apply
    ```

6. Destroy (optional)
If you would like to destroy the resources used for this demo once you're done

    ```bash
    terraform destroy
    ```