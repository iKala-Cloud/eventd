
# eventd

- **eventd** routes interested metrics/logs (events) to central data lake
- **eventd** equips opinioed ETL & data schema for different events 
- **eventd** provides simple visualization template via Data Studio


## Installation

We use Terraform as our provision tool

1. Prepare GCP service account with below permissions

    ```
    Logs Configuration Writer (on the logsink's project, folder, or organization)
    Project IAM Admin (on the destination project)
    Service Usage Admin (on the destination project)
    BigQuery Data Editor (on the destination project)
    ```

2. Set `GOOGLE_APPLICATION_CREDENTIALS` environment variable to authenticate Terraform

    Set environment variable to the path of the service account key JSON file, e.g.

    ```
    export GOOGLE_APPLICATION_CREDENTIALS="/tmp/eventd-project-8636a2dc818e.json"
    ```

3. Use terrafrom to provison log sink and raw dataset

    ```
    terraform apply
    ```

## Configuration


## Usage/Examples


## How to test


## Feedback

If you have any feedback, please reach out to us at gcp-arch@ikala.tv


## Contributing

Contributions are always welcome!

See `contributing.md` for ways to get started.

Please adhere to this project's `code of conduct`.


## Acknowledgements


