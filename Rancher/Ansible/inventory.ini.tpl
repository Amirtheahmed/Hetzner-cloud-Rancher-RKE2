[masters]
{% for master_name, master in master_nodes.items() %}
{{ master_name }} ansible_host={{ master[0].public_ip }} ansible_private_ip={{ master[0].private_ip }}
{% endfor %}

[workers]
{% for worker_name, worker in worker_nodes.items() %}
{{ worker_name }} ansible_host={{ worker[0].public_ip }} ansible_private_ip={{ worker[0].private_ip }}
{% endfor %}
