# Running dActionBoard in Apache Airflow


Running dActionBoard queries in Apache Airflow is easy.
You'll need to provide three arguments for running `DockerOperator` inside your DAG:

* `/path/to/google-ads.yaml` - absolute path to `google-ads.yaml` file (can be remote)
* `service_account.json` - absolute path to service account json file
* `/path/to/dactionboard.yaml` - absolute path to [YAML config](../README.md#initial-setup-and-run-via-an-interactive-installer)

## Example DAG

```
from airflow import DAG
from datetime import datetime, timedelta
from airflow.providers.docker.operators.docker import DockerOperator
from docker.types import Mount


default_args = {
    'description'           : 'https://github.com/google/dactionboard',
    'depend_on_past'        : False,
    'start_date'            : datetime(2023, 3, 1),
    'email_on_failure'      : False,
    'email_on_retry'        : False,
    'retries'               : 1,
    'retry_delay'           : timedelta(minutes=5)
}
with DAG('dactionboard', default_args=default_args, schedule_interval="* 0 * * *", catchup=False) as dag:
    dactionboard = DockerOperator(
        task_id='dactionboard_docker',
        image='ghcr.io/google/dactionboard:latest',
        api_version='auto',
        auto_remove=True,
        command=[
            "/google-ads.yaml",
            "/dactionboard.yaml",
        ],
        docker_url="unix://var/run/docker.sock",
        mounts=[
            Mount(
                source="/path/to/service_account.json",
                target="/service_account.json",
                type="bind"),
            Mount(
                source="/path/to/google-ads.yaml",
                target="/google-ads.yaml",
                type="bind"),
            Mount(
                source="/path/to/dactionboard.yaml",
                target="/dactionboard.yaml",
                type="bind")
        ]
    )
    dactionboard
```
