# dbt Models

The directories inside of `models` represent datasets in BQ and each `.sql` file corresponds to a table or view in the warehouse. `.yml` files document the data's metadata and enforce governance

This structure can be modified in [dbt_project.yml](dbt_project.yml)

## Run dbt models locally
To run dbt models locally (outside of Airflow or the Docker container), you'll need [dbt-core](https://docs.getdbt.com/docs/core/pip-install) and the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) installed on your machine

## dbt Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
