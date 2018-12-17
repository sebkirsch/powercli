#
# List all VMs with disconnected vNICs
#
# Desc:    List all running VMs with disconnected vNICs
# Date:    21.08.2018
# Author:  Sebastian Kirsch
# URL:     https://www.justvirtualthings.com
#

### CONFIG ###
$vc_server = "YOUR-VCENTER.domain.tld"
$vc_user = "YOUR-USERNAME"
$vc_pass = "YOUR-PASSWORD"
### END CONFIG ###

### MAIN ###
$vmList = @()

Write-Output ""
Write-Output "---------------------------"
Write-Output " List all disconnected VMs"
Write-Output "---------------------------"
Write-Output ""

# Connect to vCenter
Write-Output ""
Write-Output " * Connecting to vCenter server"
$vc_conn = Connect-VIServer -Server $vc_server -Protocol https -User $vc_user -Password $vc_pass

# Search for VMs with disconnected vNICs
Write-Output " * Searching for VMs with disconnected vNICs"
foreach ($VM in (Get-Vm | where {$_.Powerstate -eq "PoweredOn"} | Get-NetworkAdapter | where {$_.Connectionstate.connected -eq $false -and $_.Connectionstate.StartConnected -eq $true})) {
	$dcVM = "" | Select vmName, nicName, nicType, nicNetwork
	
	$dcVM.vmName = $VM.parent.Name
	$dcVM.nicName = $VM.Name
	$dcVM.nicType = $VM.Type
	$dcVM.nicNetwork = $VM.NetworkName

	$vmList += $dcVM
}

# Disconnect from vCenter
Write-Output " * Disconnecting from vCenter server"
Disconnect-VIServer $vc_server -Confirm:$False

Write-Output ""
Write-Output ""
Write-Output $vmList | out-host

Write-Output ""
Read-Host -Prompt "Press Enter to exit"
#EOF
