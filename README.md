# PowerCLI scripts

## Description
This is a collection of some PowerCLI scripts that I use more often. They were tested under vSphere 6.0, 6.5 and 6.7 and PowerCLI 10.0.0.

## Content
[add-windows-vms-to-drs-group.ps1](add-windows-vms-to-drs-group.ps1) - Search for Microsoft Windows VMs and add them to a DRS group.

[change-storage-policy.ps1](change-storage-policy.ps1) - Change storage policy for virtual disks on specific datastores.

[export-all-triggered-alarms.ps1](export-all-triggered-alarms.ps1) - Export all triggered alarms for all datacenter objects to a csv file.

[export-dvPortgroup-settings.ps1](export-dvPortgroup-settings.ps1) - Export all dvPortgroups and settings to a csv file.

[export-vms-with-snapshots.ps1](export-vms-with-snapshots.ps1) - Export a list with all VMs with snapshots to a csv file.

[list-dvSwitch-settings.ps1](list-dvSwitch-settings.ps1) - List all dvSwitches and their settings.

[list-vms-with-disconnected-vnic.ps1](list-vms-with-disconnected-vnic.ps1) - List all running VMs with disconnected vNICs.

[set-teaming-for-vxlan-portgroups.ps1](set-teaming-for-vxlan-portgroups.ps1) - Set teaming policy for all NSX VXLAN dvPortgroups.

## Author
- Sebastian Kirsch - [https://www.justvirtualthings.com](https://www.justvirtualthings.com)

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
