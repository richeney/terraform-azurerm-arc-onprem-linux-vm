#cloud-config
#
# This is an cloud-init file to install the azcmagent.
#
#
#
# Stop the walinux agent and b) configure the firewall to block the Instance Metadata Service.
#
# This allows azcmagent to be installed and the VM to be onboarded to Azure Arc
# as if it was an on prem virtual machine.
#
# Don't create files in /tmp during the early stages that cloud-init works in. Use /var/run.
# Generated runcmd script run as root: sudo cat /var/lib/cloud/instance/scripts/runcmd
# Cloud-init output: cat /var/log/cloud-init-output.log

merge_how:
 - name: list
   settings: [append]
 - name: dict
   settings: [no_replace, recurse_list]

cloud_config_modules:
  - runcmd
cloud_final_modules:
  - scripts-user

runcmd:
  - echo "Starting azcmagent connect runcmd steps at $(date +%H:%M:%S)"
  - [ azcmagent, connect,
    --tenant-id, "${tenant_id}",
    --subscription-id, "${subscription_id}",
    --service-principal-id, "${service_principal_appid}",
    --service-principal-secret, "${service_principal_secret}",
    --resource-group, "${resource_group_name}",
    --location, "${location}",
    --tags, "${tags}"
    ]
  - echo "Starting azcmagent connect runcmd steps at $(date +%H:%M:%S)"
