# Check if the secrets files exist
TFVARS := Terraform/terraform.tfvars.json

.PHONY: init apply destroy master_configure_rke2  configure_workers master_configure_ccm master_configure_traefik master_configure_rancher

# Define targets
all: secrets export

secrets:
	@if [ -e $(TFVARS) ]; then \
		export HCLOUD_TOKEN=$(shell jq -r '.hcloud_token' $(TFVARS)); \
		export SSH_KEYS_MASTER=$(shell jq -r '.ssh_keys.master' $(TFVARS)); \
		export SSH_KEYS_WORKER=$(shell jq -r '.ssh_keys.worker' $(TFVARS)); \
	else \
		echo "No secrets file found! Please create one!"; \
		exit 1; \
	fi

export:
	export TF_VAR_hcloud_token=$(HCLOUD_TOKEN)
	export TF_VAR_ssh_keys=$(SSH_KEYS)

init:
	cd Terraform && terraform init

apply: all
	cd Terraform && terraform init
	cd Terraform && terraform plan
	@TF_VAR_hcloud_token=$(HCLOUD_TOKEN) \
	TF_VAR_ssh_keys=$(SSH_KEYS) python3.10 Script.py

destroy: all
	cd Terraform && terraform init
	cd Terraform && terraform destroy
	rm -f Ansible/inventory.ini
	# remove the token file, token file names ends with _node_token
	rm -f Ansible/*_node_token

master_configure_rke2: all
	cd Ansible && ansible-playbook -i inventory.ini master-playbook.yaml

configure_workers: all
	cd Ansible && ansible-playbook -i inventory.ini workers-playbook.yaml

master_configure_ccm: all
	cd Ansible && ansible-playbook -i inventory.ini master-ccm-playbook.yaml --ask-vault-pass

master_configure_traefik: all
	cd Ansible && ansible-playbook -i inventory.ini master-traefik-playbook.yaml

master_configure_rancher: all
	cd Ansible && ansible-playbook -i inventory.ini master-rancher-playbook.yaml

master_configure_operators: all
	cd Ansible && ansible-playbook -i inventory.ini master-operators-playbook.yaml



