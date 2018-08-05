#
# Export all dvPortgroup settings
#
# Desc:    Export all dvPortgroups and settings to a csv file
# Date:    04.08.2018
# Author:  Sebastian Kirsch
# URL:     https://www.justvirtualthings.com
#

### CONFIG ###
$vc_server = "YOUR-VCENTER.domain.tld"
$vc_user = "YOUR-USERNAME"
$vc_pass = "YOUR-PASSWORD"
### END CONFIG ###

### MAIN ###
$dvPGInfo = @()

Write-Output ""
Write-Output "--------------------------------------"
Write-Output " Export all dvPortgroups and settings"
Write-Output "--------------------------------------"
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

# Collect dvPortgroups and settings
Write-Output " * Gathering information about all dvPortgroups"
foreach($dvSW in Get-VDSwitch){
	foreach($dvPG in (Get-VDPortgroup -VDSwitch $dvSW | Sort Name)){
		$settings = "" | Select Name, dvSwitch, PortBinding, TotalPorts, PortsInUse, IsUplink, AutoExpand, VlanType, VlanId, 
								Teaming, FailureDetection, NotifySwitches, Failback, ActiveUplinkPort, StandbyUplinkPort,
								AllowPromiscuous, MACChanges, ForgedTransmits, AllPortsBlocked
		
		$settings.Name = $dvPG.name
		$settings.dvSwitch = $dvSW
		$settings.IsUplink = $dvPG.IsUplink
		$settings.AutoExpand = $dvPG.ExtensionData.Config.AutoExpand
		
		# dvPorts
		$settings.PortBinding = $dvPG.PortBinding
		$settings.TotalPorts = $dvPG.ExtensionData.Config.NumPorts
		$settings.PortsInUse = $dvPG.ExtensionData.vm.count
		
		# VLAN
		if($dvPG.ExtensionData.Config.DefaultPortConfig.Vlan.GetType().Name -eq "VmwareDistributedVirtualSwitchPvlanSpec"){
			$VLANType = "PrivateVLAN"
			$VLANId = $dvPG.ExtensionData.Config.DefaultPortConfig.Vlan.PvlanId
        } elseif($dvPG.ExtensionData.Config.DefaultPortConfig.Vlan.GetType().Name -eq "VmwareDistributedVirtualSwitchTrunkVlanSpec") {
			$VLANType = "VLANTrunk"
			$VLANId = [string]::Join(',',($dvPG.ExtensionData.Config.DefaultPortConfig.Vlan.VlanId | %{[string]$_.Start + "-" + [string]$_.End}))
		} elseif($dvPG.ExtensionData.Config.DefaultPortConfig.Vlan.GetType().Name -eq "VmwareDistributedVirtualSwitchVlanIdSpec") {
			$VLANType = "VLAN"
			$VLANId = $dvPG.Extensiondata.Config.DefaultPortConfig.Vlan.VlanId
			if($VLANId -eq 0) {
				$VLANType = "None"
			}
        } else {
			$VLANType = "None"
			$VLANId = ''
        }	
		$settings.VlanType = $VLANType
		$settings.VlanId = $VLANId
		
		# Teaming and Failover
		if ($dvPG.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.FailureCriteria.CheckBeacon.Value -eq $True) {
			$FailureDetection = "BeaconProbing"
		} else {
			$FailureDetection = "LinkStatus"
		}
		if ($dvPG.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.RollingOrder.Value -eq $True) {
			$Failback = $False
		} else {
			$Failback = $True
		}
		$settings.Teaming = $dvPG.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.Policy.Value
		$settings.FailureDetection = $FailureDetection
		$settings.NotifySwitches = $dvPG.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.NotifySwitches.Value
		$settings.Failback =  $Failback
		$settings.ActiveUplinkPort = $dvPG.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.ActiveUplinkPort -join ' | '
		$settings.StandbyUplinkPort = $dvPG.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.StandbyUplinkPort -join ' | '

		# Security
		$settings.AllowPromiscuous = $dvPG.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value
		$settings.MACChanges = $dvPG.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value
		$settings.ForgedTransmits = $dvPG.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value
		$settings.AllPortsBlocked = $dvPG.ExtensionData.Config.DefaultPortConfig.Blocked.Value
		
		$dvPGInfo += $settings
	}
}    

# CSV export
Write-Output " * Exporting data to csv file"
$dvPGInfo | Export-Csv -UseCulture -NoTypeInformation $csvFile

# Disconnect from vCenter
Write-Output " * Disconnecting from vCenter server"
Disconnect-VIServer $vc_server -Confirm:$False

# End
Write-Output ""
Write-Output "All Done."
Write-Output ""
Read-Host -Prompt "Press Enter to exit"
#EOF
