# azure-infrastructure
This is my introduction to Infrastructure as Code.
There are a lot of approvement that can be done, but my goal is to learn IAC and some of the tools that goes with it.

And if someone can use this to get some ideas of their own, thats just a plus!


## Deploy a CentOS VM with ARM templates with Ansible installed

- Go to the *ansible-vm.parameters.json* to change project name, Azure location, Administrator account and VM size.
- Go to the *deploy_VM_with_ARM.yml* to set which Subscription you want to use (this needs to already exist in your Azure environment), set resource group name (if you want to use an already existing resource group, put this here), Azure location (if you need to create a new resource group) and VM name (should be *projectName* plus *-vm* extension)