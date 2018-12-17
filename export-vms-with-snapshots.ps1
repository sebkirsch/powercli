#
# Export snapshot list
#
# Desc:    Export a list with all VMs with snapshots to a csv file
# Date:    01.09.2018
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
$totalSnapshots = 0
$totalVMs = 0

Write-Output ""
Write-Output "----------------------"
Write-Output " Export snapshot list"
Write-Output "----------------------"
Write-Output ""

# Enter csv filename
$csvFile = Read-Host -Prompt "Enter path & filename for csv file"
if ($csvFile -eq "") {
	Write-Output "Invalid filename or path. Aborting..."
	Read-Host -Prompt "Press Enter to exit"
	Exit
}

# Connect to vCenter
Write-Output ""
Write-Output " * Connecting to vCenter server"
$vc_conn = Connect-VIServer -Server $vc_server -Protocol https -User $vc_user -Password $vc_pass

# Search for VMs with snapshots
Write-Output " * Searching for VMs with snapshots"

$allVMs = Get-Vm

foreach ($vm in $allVMs) {

	if (($vm | Get-Snapshot)) {
		foreach ($snapshot in ($vm | Get-Snapshot)) {
			$snapVm = "" | Select Name, Cluster, SnapshotName, SnapshotCreated, SnapshotSizeGB, SnapshotIsCurrent
			$snapVM.Name = $vm.name
			$snapVM.Cluster = (Get-Cluster -VM $vm.name).name
			$snapVM.SnapshotName = $snapshot.Name
			$snapVM.SnapshotCreated = $snapshot.Created
			$snapVM.SnapshotSizeGB = $snapshot.SizeGB
			$snapVM.SnapshotIsCurrent = $snapshot.IsCurrent
			
			$vmList += $snapVm
			$totalSnapshots = $totalSnapshots + 1
		}
		$totalVMs = $totalVMs + 1
	}
	
}

# Disconnect from vCenter
Write-Output " * Disconnecting from vCenter server"
Disconnect-VIServer $vc_server -Confirm:$False

# CSV export
Write-Output " * Exporting data to csv file"
$vmList | Export-Csv -UseCulture -NoTypeInformation $csvFile

Write-Output ""
Write-Output "Found $($totalSnapshots) snapshots for $($totalVMs) VMs."
Write-Output ""
Read-Host -Prompt "Press Enter to exit"
#EOF
