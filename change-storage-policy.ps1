#
# Change storage policy for virtual disks
#
# Desc:    Change storage policy for virtual disks on specific datastores
# Date:    31.08.2018
# Author:  Sebastian Kirsch
# URL:     https://www.justvirtualthings.com
#

### CONFIG ###
$vc_server = "YOUR-VCENTER.domain.tld"
$vc_user = "YOUR-USERNAME"
$vc_pass = "YOUR-PASSWORD"
$clusters = @("CLUSTER-NAME-2", "CLUSTER-NAME-2")
$datastores = @("DATASTORE-NAME-1", "DATASTORE-NAME-2")
$spName = "STORAGE-POLICY-NAME"
### END CONFIG ###

### MAIN ###
$dsRegex = [Regex]::new("(?<=\[)(.*)(?=\])")
$totalVms = 0
$totalDisks = 0
$totalSnapshots = 0

Write-Output ""
Write-Output "-------------------------"
Write-Output " Change storage policies"
Write-Output "-------------------------"
Write-Output ""

# Connect to vCenter
Write-Output ""
Write-Output " * Connecting to vCenter server"
$vc_conn = Connect-VIServer -Server $vc_server -Protocol https -User $vc_user -Password $vc_pass

# Changing storage policy for virtual machines
Write-Output ""
Write-Output " * Changing storage policies"
Write-Output ""

$storPolicy = Get-SpbmStoragePolicy -Name $spName

foreach ($cluster in $clusters) {
	$vms = Get-Cluster $cluster | Get-VM

	foreach ($vm in $vms) {

		$vDisks = $vm | Get-HardDisk
		$diskCount = $vDisks.count
		$foreignDS = $false
			
		foreach ($vDisk in $vDisks) {
			$dsPath = $vDisk.Filename
			$dsMatch = $dsRegex.Match($dsPath)            

			# check if datastore is in the defined $datastore array
			if ($dsMatch.Success) {
				if ($datastores.Contains($dsMatch.Value)) {
					$vdSP = (Get-SpbmEntityConfiguration $vDisk).StoragePolicy.Name
					
					# check if policy name of the virtual disk is the same as defined in $spName
					if ($vdSP -ne $spName) {
					
						# check if snapshot exists for this virtual disk
						if (-not ($vm | Get-Snapshot)) {
							Write-Output "Changing disk storage policy for $($vm.Name)"
							if (Set-SpbmEntityConfiguration $vDisk -StoragePolicy $storPolicy -confirm:$false) {
								$totalDisks = $totalDisks + 1
							}
						} else {
							Write-Output "Snapshot present for $($vm.Name). Skipping disk..."
							$totalSnapshots = $totalSnapshots + 1
						}
						
					}
					
				} else {
					$foreignDS = $true
				}
			}

			if ($foreignDS -eq $false) {
				$vmSP = (Get-SpbmEntityConfiguration $vm).StoragePolicy.Name
				if ($vmSP -ne $spName) {
					Write-Output "Changing VM storage policy for $($vm.Name)"
					if (Set-SpbmEntityConfiguration $vm -StoragePolicy $storPolicy -confirm:$false) {
						$totalVms = $totalVms + 1
					}
				}
			}

		}
		
	}
	
}

# Disconnect from vCenter
Write-Output ""
Write-Output " * Disconnecting from vCenter server"
Disconnect-VIServer $vc_server -Confirm:$False

Write-Output ""
Write-Output "--------------------------------------------------------"
Write-Output "Changed $($totalVms) VMs and $($totalDisks) vDisks."
Write-Output "$($totalSnapshots) disks were skipped due to snapshots."
Write-Output "--------------------------------------------------------"
Write-Output ""
Read-Host -Prompt "Press Enter to exit"
#EOF
