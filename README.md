# Auto-tagging for IBM Cloud resources

This Terraform template deploys a serverless job on IBM Cloud Code Engine that runs the `quay.io/cloud-governance/cloud-governance:latest` container image on a scheduled basis to apply tags to supported resources.

## Architecture

The deployment creates the following resources:

- **Resource group**: Container for the Code Engine Project
- **Code Engine Project**: Container for all Code Engine resources
- **Secret**: Stores sensitive configuration data (API keys, credentials)
- **ConfigMap**: Stores non-sensitive configuration data
- **Job**: Serverless job definition with the cloud-governance container
- **Cron scheduler**: Runs the job on the configured schedule

**Note**: [Job scheduling is not currently supported by the IBM Cloud Terraform provider](https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5231) and must be configured separately via the CLI after deployment.

## Security Considerations

As the [redhat-performance/cloud-governance](https://github.com/redhat-performance/cloud-governance) tool does not yet support IBM Cloud's [Trusted Profiles](https://cloud.ibm.com/docs/account?topic=account-create-trusted-profile&interface=ui) feature, regular API keys are used for authentication.


## Prerequisites

1. **IBM Cloud Account**: Ensure you have an active IBM Cloud account
    - [Create an API key](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui)
    - [Create a classic infrastructure API key](https://cloud.ibm.com/docs/account?topic=account-classic_keys&interface=ui)
1. **Terraform**: [Install Terraform](https://developer.hashicorp.com/terraform/install)
1. **IBM Cloud CLI**:
    - [Install and configure the IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)
    - [Install the Cloud Engine plugin](https://cloud.ibm.com/docs/codeengine?topic=codeengine-cli)
1. **`jq`** (Optional): Install [jq](https://jqlang.org/)


## Usage

### 1. Log in via the CLI

[Log in using a one-time passcode.](https://cloud.ibm.com/docs/account?topic=account-federated_id&interface=cli#login_cli)  

```bash
ibmcloud login -a https://cloud.ibm.com -u passcode -p <passcode>
```

**Note**: The easiest method to get the passcode is to log into the IBM Cloud console via a browser, click on the avatar icon in the top-right corner, and click on **Log in to CLI and API**.

### 2. Generate classic infrastructure username

```bash
echo "$(ibmcloud account show -o json | jq -r '.ims_account_id')_$(ibmcloud target --output json | jq -r '.user.user_email')"
```

### 3. Configuration

1. Copy the example configuration file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

1. Edit `terraform.tfvars` with your specific values:
   ```hcl
    secret_data = {
        "IBM_CLOUD_API_KEY" = "<IBM CLOUD API KEY>"
        "IBM_API_USERNAME"  = "<Classic infra username>"
        "IBM_API_KEY"       = "<IBM Classic Infrastructure API Key>"
    }

    config_data = {
        "IBM_CUSTOM_TAGS_LIST" = "tag1:value1,tag2:value2,tag3:value3"
        "account"              = "Account Name"
        ...
    }
   ```

### 4. Deployment

1. Configure API access for Terraform

    ```bash
    export IC_API_KEY="<IBM CLOUD API KEY>"
    ```

1. Initialize Terraform:
   ```bash
   terraform init
   ```

1. Plan the deployment:
   ```bash
   terraform plan
   ```

1. Create the resources:
   ```bash
   terraform apply
   ```

1. Set up job scheduling:

   The CLI command will be displayed in the Terraform output.  
   Example:  
   ```bash
   Outputs:
    ...
    schedule_cli_command = "ibmcloud target -r us-east -g auto-tagger && ibmcloud ce project select -n auto-tagger && ibmcloud ce subscription cron create --name auto-tagger-job-schedule --destination auto-tagger-job --schedule '0 0 */1 * *' --destination-type job --tz UTC"
    ```

### 5. Deprovisioning

1. Configure API access for Terraform

    ```bash
    export IC_API_KEY="<IBM CLOUD API KEY>"
    ```

1. Delete the resources:
    ```bash
    terraform destroy
    ```

**Note**: This will also remove the scheduling, so no need to remove that via other methods.