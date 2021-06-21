#cloud-config
#
# This is an cloud-init file .
#
# azure-cli is installed as a nice to have
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
# key is included directly, so will need to be updated if the signing key changes
#
# Stop the walinux agent and b) configure the firewall to block the Instance Metadata Service.
#
# This allows azcmagent to be installed and the VM to be onboarded to Azure Arc
# as if it was an on prem virtual machine.
#
# Don't create files in /tmp during the early stages that cloud-init works in. Use /var/run.
# Generated runcmd script run as root: sudo cat /var/lib/cloud/instance/scripts/runcmd
# Cloud-init output: cat /var/log/cloud-init-output.log

cloud_config_modules:
  - apt_configure
  - package_update_upgrade_install
  - runcmd

cloud_final_modules:
  - scripts-user

apt:
  sources:
    azure-cli:
      source: 'deb https://packages.microsoft.com/repos/azure-cli/ $RELEASE main'
      key: |
        -----BEGIN PGP PUBLIC KEY BLOCK-----
        Version: GnuPG v1.4.7 (GNU/Linux)

        mQENBFYxWIwBCADAKoZhZlJxGNGWzqV+1OG1xiQeoowKhssGAKvd+buXCGISZJwT
        LXZqIcIiLP7pqdcZWtE9bSc7yBY2MalDp9Liu0KekywQ6VVX1T72NPf5Ev6x6DLV
        7aVWsCzUAF+eb7DC9fPuFLEdxmOEYoPjzrQ7cCnSV4JQxAqhU4T6OjbvRazGl3ag
        OeizPXmRljMtUUttHQZnRhtlzkmwIrUivbfFPD+fEoHJ1+uIdfOzZX8/oKHKLe2j
        H632kvsNzJFlROVvGLYAk2WRcLu+RjjggixhwiB+Mu/A8Tf4V6b+YppS44q8EvVr
        M+QvY7LNSOffSO6Slsy9oisGTdfE39nC7pVRABEBAAG0N01pY3Jvc29mdCAoUmVs
        ZWFzZSBzaWduaW5nKSA8Z3Bnc2VjdXJpdHlAbWljcm9zb2Z0LmNvbT6JATUEEwEC
        AB8FAlYxWIwCGwMGCwkIBwMCBBUCCAMDFgIBAh4BAheAAAoJEOs+lK2+EinPGpsH
        /32vKy29Hg51H9dfFJMx0/a/F+5vKeCeVqimvyTM04C+XENNuSbYZ3eRPHGHFLqe
        MNGxsfb7C7ZxEeW7J/vSzRgHxm7ZvESisUYRFq2sgkJ+HFERNrqfci45bdhmrUsy
        7SWw9ybxdFOkuQoyKD3tBmiGfONQMlBaOMWdAsic965rvJsd5zYaZZFI1UwTkFXV
        KJt3bp3Ngn1vEYXwijGTa+FXz6GLHueJwF0I7ug34DgUkAFvAs8Hacr2DRYxL5RJ
        XdNgj4Jd2/g6T9InmWT0hASljur+dJnzNiNCkbn9KbX7J/qK1IbR8y560yRmFsU+
        NdCFTW7wY0Fb1fWJ+/KTsC4=
        =J6gs
        -----END PGP PUBLIC KEY BLOCK-----
      filename: azure-cli.list

package_update: true

runcmd:
 - echo "Starting azure arc runcmd steps at $(date +%H:%M:%S)"
 - echo "Configuring walinux agent"
 - service walinuxagent stop
 - waagent deprovision force
 - rm -fr /var/lib/waagent
 - echo "Configuring Firewall"
 - ufw --force enable
 - ufw deny out from any to 169.254.169.254
 - ufw default allow incoming
 - echo "Configuring hostname to ${hostname}"
 - hostname ${hostname}
 - echo ${hostname} > /etc/hostname
 - echo "Installing azcmagent"
 - wget --no-verbose https://aka.ms/azcmagent -O /var/run/install_linux_azcmagent.sh
 - chmod 755 /var/run/install_linux_azcmagent.sh
 - bash /var/run/install_linux_azcmagent.sh
 - echo "Finished azure arc runcmd steps at $(date +%H:%M:%S)"

packages:
  - azure-cli
  - stress
  - jq

package_upgrade: true
