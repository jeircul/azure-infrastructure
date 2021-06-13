variable "project_name" {
    type = string
    default = "myProjectName"
}

variable "resource_group" {
    type = string
    default = "myResourceGroup"

}

variable "location"  {
    type = string
    default = "norwayeast"
}


variable "user_name"  {
    type = string
    default = "sysAdmin"
}

variable "public_key"  {
    type = string
    default = "<INSERT PUBLIC KEY HERE>"
}
