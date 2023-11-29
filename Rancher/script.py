import os
import json
import jinja2
import sys

# Set the current directory to the directory of this script
os.chdir(os.path.dirname(os.path.realpath(__file__)))

# 1. Run Terraform script
exit_code = os.system('cd Terraform && terraform apply -auto-approve')
if exit_code != 0:
    raise Exception("Terraform apply failed with exit code: {}".format(exit_code))

# 2. Get output IPs
master_nodes = {}
worker_nodes = {}

# MASTER NODES
master1_ip = os.popen('cd Terraform && terraform output -raw master1_ip').read().strip()
master1_private_ip = os.popen('cd Terraform && terraform output -raw master1_private_ip').read().strip()

master_nodes['master-1'] = [{'public_ip': master1_ip, 'private_ip': master1_private_ip}]

# WORKER NODES
worker1_ip = os.popen('cd Terraform && terraform output -raw worker1_ip').read().strip()
worker1_private_ip = os.popen('cd Terraform && terraform output -raw worker1_private_ip').read().strip()
#
# worker2_ip = os.popen('cd Terraform && terraform output -raw worker2_ip').read().strip()
# worker2_private_ip = os.popen('cd Terraform && terraform output -raw worker2_private_ip').read().strip()


worker_nodes['worker-1'] = [{'public_ip': worker1_ip, 'private_ip': worker1_private_ip}]
# worker_nodes['worker-2'] = [{'public_ip': worker2_ip, 'private_ip': worker2_private_ip}]

# 3. Replace placeholders in template
with open('Ansible/inventory.ini.tpl') as f:
    template = jinja2.Template(f.read())
inventory = template.render(
    master_nodes=master_nodes,
    worker_nodes=worker_nodes
)

# 4. Write to inventory.ini
with open('Ansible/inventory.ini', 'w') as f:
    f.write(inventory)
