# azure-infrastructure
This is my introduction to Infrastructure as Code.
There are a lot of approvements that can be done, but my goal is to learn IAC and some of the tools that goes with it.

And if someone can use this to get some ideas of their own, thats just a plus!

## Deploy a CentOS VM with Ansible installed using ARM templates

### Prerequisites
- You need an Azure account and subscription
- You need a [service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) and define a new secret in Github Secrets. The secret must be called AZURE_SP_CREDS and it needs to have a structure like this: 
    ```json
    {
        "clientId": "<GUID>",
        "clientSecret": "<GUID>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>",
        (...)
    }
    ```
- You need to [create a public-private key pair](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys) to use the server with ssh private keys. Public key can be put in *ansible-vm.parameters.json*. Private key should **never** be shared.

### Workflow
This workflow does the following:
1. Logs in to your Azure account
2. Creates resource group if it does not exist from before, if it does exist it will skip this step.
3. Creates VM and all other resources needed to be able to log on to the vm afterwards (public IP, network security group, virtual network etc.)
4. Updates OS with *yum update*
5. Installs Ansible

### Deployment

#### Change input parameters and environment variables
To change the input parameters and environment variables to suit your own needs, do the following:
- Go to the *ansible-vm.parameters.json* to change project name, Azure location, Administrator account and VM size.
- Go to the *deploy_VM_with_ARM.yml* and locate environment variables to set which Subscription you want to use (this needs to already exist in your Azure environment), set resource group name (this can be an already existing one or a new resource group that will be created), Azure location and VM name (should be *projectName* plus *-vm* extension)

#### Run Github Action Workflow to deploy
To deploy, go to Github Actions, choose the *Deploy Ansible VM with ARM templates* on the left hand side. On the right hand side you choose *Run workflow* and choose branch and run.

#### SSH into your VM after deployment is done
You should now be able to ssh into the newly created VM.
In the Azure portal, navigate to your VM and choose *Connect* for details of how to connect. To see if Ansible has been installed run `ansible --version`.

## Deploy an Ubuntu VM with Ansible installed using Terraform
***
**NOTE**  
This action uses the same Service Principal as above, so if you already added it in the *Deploy a CentOS VM with Ansible installed using ARM templates* action, then you don't need to do it here.
***
### Prerequisites
- You need an Azure account and subscription
- You need a [service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) and define a new secret in Github Secrets. The secret must be called AZURE_SP_CREDS and it needs to have a structure like this: 
    ```json
    {
        "clientId": "<GUID>",
        "clientSecret": "<GUID>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>",
        (...)
    }
    ```
- You need to [create a public-private key pair](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys) to use the server with ssh private keys. Public key can be put in *ansible-vm.parameters.json*. Private key should **never** be shared.

### Workflow
This workflow does the following:
1. Logs in to your Azure account
2. Creates resource group (it will fail if resource group already exist)
3. Creates VM and all other resources needed to be able to log on to the vm afterwards (public IP, network security group, virtual network etc.)
4. Updates OS with *apt-get update*
5. Installs Ansible dependencies and then installs Ansible

### Deployment

#### Set client secret as environment variable
Terraform needs the client id, tenant id and the client secret of the service principal to be set as environment variables in *.gihub/workflows/deploy_vm_with_terraform.yml*. It also needs the subscription id.
**Client secret:** Add a new Github Action secret called AZURE_SP_CLIENT_SECRET containing the client secret as value.\*  
**Client id, tenant id and subscription id**: You can add secrets for these values as well, one seperate for each id. Or you can add it in plain text in the file.

 \* The client secret is impossible to retrieve if you did not save it when you first created it. So you need to either reset it or create a new one. Remeber to update the AZURE_SP_CREDS secret if you do this.

###¤ Change input parameters and environment variables
To change the input parameters and environment variables to suit your own needs, do the following:
- Go to *ansible-vm-with-terraform/variables.tf* to set:
    - Project name (most resources will have the project name plus a post-fix (example: the virtual machine will be *projectName-vm*))
    - Resource group name (this can not exist from before)
    - Azure location.
- Go to *.gihub/workflows/deploy_vm_with_terraform.yml* and set vmName and resource group in the environment variables. Remember this needs to be the same as you set in the terraform variables file.
- Go to the *ansible-vm.tf* file if you want to change specifications on the VM (optional).

#### Run Github Action Workflow to deploy
To deploy, go to Github Actions, choose the *Deploy Ansible VM with Terraform* on the left hand side. On the right hand side you choose *Run workflow* and choose branch and run.

#### SSH into your VM after deployment is done
You should now be able to ssh into the newly created VM.
In the Azure portal, navigate to your VM and choose *Connect* for details of how to connect. To see if Ansible has been installed run `ansible --version`.
