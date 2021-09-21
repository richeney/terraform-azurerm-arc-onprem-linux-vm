#cloud-config
#
# This is an cloud-init file to connect the VM to Azure Arc using the azcmagent.
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
  - [ echo, "Running as $(whoami) and logging to /var/opt/azcmagent/log/azcmagent.log"]
  - [ echo, azcmagent, connect, --verbose,
    --service-principal-id, "${service_principal_appid}",
    --service-principal-secret, 'redacted',
    --tenant-id, "${tenant_id}",
    --subscription-id, "${subscription_id}",
    --resource-group, "${resource_group_name}",
    --location, "${location}",
    --tags, "${tags}"
    ]
  - [ azcmagent, connect, --verbose,
    --service-principal-id, "${service_principal_appid}",
    --service-principal-secret, "${service_principal_secret}",
    --tenant-id, "${tenant_id}",
    --subscription-id, "${subscription_id}",
    --resource-group, "${resource_group_name}",
    --location, "${location}",
    --tags, "${tags}"
    ]
  - echo "Finished azcmagent connect runcmd steps at $(date +%H:%M:%S)"
