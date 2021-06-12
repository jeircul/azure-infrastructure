# azure-infrastructure
This is my introduction to Infrastructure as Code.
There are a lot of approvement that can be done, but my goal is to learn IAC and some of the tools that goes with it.

And if someone can use this to get some ideas of their own, thats just a plus!


## Deploy a CentOS VM with ARM templates with Ansible installed

### Prerequisites
- You need an Azure account and subscription
- You need a [service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) and define a new secret in Github Secrets. It needs to have a structure like this: 
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
4. Updates OS with *yum updates*
5. Installs Ansible

### Deployment

To change the input parameters and environment variables to suit your own needs, do the following:
- Go to the *ansible-vm.parameters.json* to change project name, Azure location, Administrator account and VM size.
- Go to the *deploy_VM_with_ARM.yml* and locate environment variables to set which Subscription you want to use (this needs to already exist in your Azure environment), set resource group name (this can be an already existing one or a new resource group that will be created), Azure location and VM name (should be *projectName* plus *-vm* extension)

To deploy, go to Github Actions, choose the *Deploy Ansible VM with ARM templates* on the left hand side. On the right hand side you choose *Run workflow* and choose your branch the branch and run.

You should now be able to ssh into the newly created VM.
In the Azure portal, navigate to your VM and choose *Connect* for details of how to connect.

