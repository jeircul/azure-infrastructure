# azure-infrastructure
This is my introduction to Infrastructure as Code.
There are a lot of approvement that can be done, but my goal is to learn IAC and some of the tools that goes with it.

And if someone can use this to get some ideas of their own, thats just a plus!


## Deploy a CentOS VM with ARM templates with Ansible installed

This workflow does the following:
1. Logs in to your Azure account
2. Creates resource group if it does not exist from before, if it does exist it will skip this step.
3. Creates VM and all other resources needed to be able to log on to the vm afterwards (public IP, network security group, virtual network etc.)
4. Updates OS with *yum updates*
5. Installs Ansible

### Prerequisites
- You need an Azure subscription
- You need a service principal and define a new secret in Github Secrets. It needs to have a structure like this: 
    ```json
    {
        "clientId": "<GUID>",
        "clientSecret": "<GUID>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>",
        (...)
    }
    ```

To deploy, go to Github Actions, choose the *Deploy Ansible VM with ARM templates* on the left hand side. On the right hand side you choose *Run workflow* and choose your branch the branch and run.

- Go to the *ansible-vm.parameters.json* to change project name, Azure location, Administrator account and VM size.
- Go to the *deploy_VM_with_ARM.yml* to set which Subscription you want to use (this needs to already exist in your Azure environment), set resource group name (if you want to use an already existing resource group, put this here), Azure location (if you need to create a new resource group) and VM name (should be *projectName* plus *-vm* extension)