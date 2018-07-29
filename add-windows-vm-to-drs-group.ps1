#
# Adding Windows VMs to DRS group
#
# Desc:    Search for Microsoft Windows VMs and add them to a DRS group
# Date:    02.03.2018
# Author:  Sebastian Kirsch
#

### CONFIG ###
$vc_server = "vcenter.domain.tld"
$vc_user = "YOUR-VC-USER"
$vc_pass = "YOUR-VC-PASSWORD"
$drs_group = "YOUR-DRS-VM-GROUPNAME"
$drs_clusters = @("CLUSTER-NAME1", "CLUSTER-NAME2", "CLUSTER-NAME3")
### END CONFIG ###


### FUNCTIONS ###
function ModifyDRSGroup {
    param ($cluster, $VMs, $DRSgroup)
    $cluster = Get-Cluster $cluster
    $spec = New-Object VMware.Vim.ClusterConfigSpecEx
    $DRSvmGroup = New-Object VMware.Vim.ClusterGroupSpec
    $DRSvmGroup.operation = "edit"
    $DRSvmGroup.Info = New-Object VMware.Vim.ClusterVmGroup
    $DRSvmGroup.Info.Name = $DRSgroup
    Get-VM $VMs | %{$DRSvmGroup.Info.VM += $_.Extensiondata.MoRef}
    $spec.GroupSpec += $DRSvmGroup
    $cluster.ExtensionData.ReconfigureComputeResource($spec,$true)
}
### END FUNCTIONS ###


### MAIN ###
Write-Output ""
Write-Output "---------------------------------"
Write-Output " Adding Windows VMs to DRS group"
Write-Output "---------------------------------"

# Connect to vCenter
Write-Output " * Connecting to vCenter server"
$vc_conn = Connect-VIServer -Server $vc_server -Protocol https -User $vc_user -Password $vc_pass

# Search for Windows VMs in the clusters $drs_clusters and add them to DRS group
foreach ($drs_cluster in $drs_clusters){
    $WinVMs = ""
    Write-Output " * Searching for Windows VMs in cluster $drs_cluster"
    $WinVMs = Get-Cluster $drs_cluster | Get-vm | where {($_.extensiondata.config.Guestfullname -like “*Microsoft Windows Server*”)}
    Write-Output " * Adding $($WinVMs.Count) Windows VMs to DRS group '$drs_group' in cluster $drs_cluster"
    ModifyDRSGroup -cluster $drs_cluster -VMs $WinVMs -DRSgroup $drs_group
}

# Disconnect from vCenter
Write-Output " * Disconnecting from vCenter server"
Disconnect-VIServer $vc_server -Confirm:$False

Write-Output ""
#EOF
