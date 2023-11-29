# Hetzner Cloud Rancher Cluster Setup using Terraform and Ansible
> Authored by: Amir Ahmed Salih 
> 
> amirtheahmed@gmail.com

## Overview

This repository provides the required Terraform and Ansible configuration files for setting up a Rancher cluster on Hetzner Cloud.

For more in-depth insights and examples, the following blog posts provide excellent references:
- [Creating a Kubernetes cluster on Hetzner Cloud](https://acsec.pro/creating-a-kubernetes-cluster-on-hetzner-cloud-with-hetzner-ccm-rancher-traefik-and-cloudflare?source=tw1122)
- [Configuring Traefik Ingress and Clouflare in Kubernetes using full strict encryption mode](https://acsec.pro/configuring-traefik-ingress-and-clouflare-in-kubernetes-using-full-strict-encryption-mode)

## Prerequisites

Ensure that the following tools are installed and configured on your local system:

- Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Ansible (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Hetzner Cloud account (https://accounts.hetzner.com/signUp)
- Hetzner CLI (https://github.com/hetznercloud/cli)
- Rancher CLI (https://github.com/rancher/cli)
- Rancher Terraform provider (https://registry.terraform.io/providers/rancher/rancher2/latest)
- Terraform Hetzner provider (https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- Jinja2 (https://pypi.org/project/Jinja2/)
- Jq (https://github.com/jqlang/jq)

## Configuration Steps

1. Login to your Hetzner cloud account and create new project
2. Create two separate ssh keys on your machine to be used for master and worker k8s nodes
3. Inside the newly created project, go to Security page and inside SSH Keys Tab add your newly created ssh keys (public keys) with proper distinct name
4. Take note of the hetzner ssh key fingerprints, we will be using them in the coming steps
5. Go to Api Tokens tab and create new hetzner cloud api token with Read and Write permission and take note of the token
6. Inside Terraform folder, create a new file `terraform.tfvars.json` and populate it as follows:

    ```json
    {
      "hcloud_token": "<your-hetzner-api-token>",
      "ssh_keys": {
        "master": "<master-node-ssh-fingerprint>",
        "worker": "<worker-node-ssh-fingerprint>"
      }
    }
    ```

7. Inside Ansible folder, create a new Ansible Vault (password protected secure file to store sensitive secrets like api token)
    file `secret.yml` via `ansible-vault create secret.yml` command (enter new password to secure the vault,
    you will be asked this password later on so make sure to note it down) and insert your Hetzner API token like this:

    ```yaml
    hetzner_api_token: <your-hetzner-api-token>
    ```
8. Inside Rancher folder, configure/update rancher administration url via ingress-route.yaml file
9. Inside Traefik folder, configure/update traefik administration url inside ingress-route.yaml file
10. Now we need to configure our main Terraform file `Infrastructure.tf` inside Terraform folder. We can configure the following sections:

    VARIABLES: in this section we define essential variables to be used in the rest of the script
    - `network_ip_range`     - Here configure network ip range for the cluster
    - `subnet_type`          - Here configure network subnet type
    - `subnet_network_zone`  - Here configure network subnet network zone cluster ([available zones](https://docs.hetzner.com/cloud/general/locations/)) 
    - `placement_group_name` - Here configure network subnet placement group name for the cluster
    - `placement_group_type` - Here configure network subnet placement group type for the cluster. [Docs](https://docs.hetzner.com/cloud/placement-groups/overview)
   
    SERVERS: here we define and configure all servers we want to be created on our hetzner cloud account. the commented server resource definitions are example if you need to create additional servers
    - server resource definition for master is already setup `master-1`, optionally you can configure the following:
      - `name`  - name os the server
      - `image` - os image to be used for the server
      - `location` - location (hetzner data center) of the server. [docs](https://docs.hetzner.com/cloud/general/locations/)
      - `server_type` - type of hetzner cloud server type code. you can get list of server type from cloud console inside servers page. click on Add Server list of all available servers will be listed
   
    - server resource definition for `worker-1` is already setup. if you want more workers, just copy-paste the server resource definitions and change the id of the resource. optionally you can configure the resource just like you did for the master node

    OUTPUTS: here we define all data we want this terraform script to output when run
    - here we must define terraform outputs to return all public and private ip addresses of the server resources we defined above (master, and workers). 
      - make sure to create outputs(public & private) for each of the server you defined above
    
    FIREWALL: here we setup our firewall
    - add or remove allowed ports for the servers we defined above
   
11. Lastly we need to configure `script.py` file in the root directory. this python script is very essential because it executes our Terraform script (`Infrastructure.tf`) and based on its output it populates `inventory.ini` which will be used by Ansible later.
   - Here you can configure master and worker server to exactly match what we created inside Terraform earlier.

## Rancher Cluster Deployment Steps

Follow these steps to set up the Rancher cluster:
Inside root directory where Makefile is located
1. Run `make init` to install all dependencies.
2. Execute `make apply` to create all resources and servers on Hetzner Cloud. If successful ansible inventory file (`inventory.ini`) will be created inside Ansible directory
3. Configure the RKE2 Server on the Master node by running `make master_configure_rke2`.
4. Initialize the RKE2 Agent on Worker nodes with `make configure_workers`.
5. Configure the Hetzner Cloud Controller Manager on the Master node with `make master_configure_ccm`. Here you will be asked for Ansible vault password which we created previously at _Step 7_ of Configuration above
6. Install Traefik on the Master node by running `make master_configure_traefik`. Here you will be asked for username and password to setup Traefik on the cluster
7. Complete the Rancher configuration on the Master node using `make master_configure_rancher`.
8. Install necessary k8s operators on master node using `make master_configure_operators`.
9. Congratulations. Rancher cluster have been deployed and load balancer with public ip for the cluster has been successfully created on hetzner.
10. Now to access rancher administration dashboard. we need to setup our domain in Cloudflare and point it to our cluster's load balancer public ip address.
    - the domain name will be the one you configured for rancher at _step 8_ above
    - you can get the cluster's load balancer public ip from hetzner cloud console inside Load balancers page called `k8slb`
    - if the domain name is already created on cloudflare for rancher admin, just update the ip address to point to the loadbalancer's ip address.
11. After setting up domain for rancher admin, visit the url and if it's the first time you accessing the admin ui it will ask for bootstrap password. To get bootstrap password
    - login to master node server using *_root_* as username and ssh key you created specifically for master in the beginning. you can get the ip of master server node from hetzner cloud console
    - run the following command 
      `kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'`
    - the command will generate a bootstrap password, copy the password and paste it inside rancher admin dashboard and login
    - if bootstrap is correct, then it will ask to set password for default admin user.
    - click continue and you will be logged in to rancher admin ui.
12. Lastly we need to also create cloudflare domain to point to our traefik dashboard. based on the url you set on _Step 9_ and loadbalancer's ip address setup cloudflare.
13. Congratulations, you have successfully deployed and configured you Rancher cluster on hetzner cloud.

## Interacting with Rancher (RKE2) cluster from local machine
To interact with the created cluster from local machine.
1. you need to install `kubectl` on your local machine
2. download kubeconfig file from rancher dashboard
   - login to rancher dashboard
   - select your cluster, usually its called `local`
   - on top right corner click on the document icon to download kubeconfig file
3. use the downloaded kubeconfig file with kubectl to interact with the rancher cluster 
    `kubectl --kubeconfig=<path-to-kubeconfig>/kubeconfig.yaml ...`

## Scaling up worker nodes

To scale up the number of worker nodes, add necessary additional server resources inside `Infrastructure.tf` and configure `script.py` to match that.

## Scaling down worker nodes

Before scaling down, use taints and draining nodes as best practices:

1. **Taint the node**: This ensures that no new pods are scheduled on the node while you're trying to remove it. Use the following command to taint the node:
    
    ```bash
    kubectl taint nodes <node-name> key=value:NoSchedule
    ```
2. **Drain the node**: This will evict all the pods running on the node. It is good practice to drain the node to make sure it's free of running tasks before you remove it. The following command will drain the node:
        ```bash
        kubectl drain <node-name>
        ```
3. **Remove the node**: After all pods have been drained from the node, you can proceed to delete the node from the cluster. After deleting the node object in Kubernetes, you should also destroy the node in your cloud or on-premises infrastructure to ensure that it is completely removed.
        ```bash
        kubectl delete node <node-name>
        ```
After these steps, you can adjust(comment out or remove) your `Infrastructure.tf` and `script.py` files to match your desired number of nodes and then apply the changes by running `make init` and `make apply`.

## Decommissioning the cluster

If you need to destroy the Rancher cluster and all resources on Hetzner Cloud, simply run `make destroy`.
