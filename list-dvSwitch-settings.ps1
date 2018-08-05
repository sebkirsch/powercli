#
# List dvSwitch settings
#
# Desc:    List all dvSwitches and their settings
# Date:    05.08.2018
# Author:  Sebastian Kirsch
# URL:     https://www.justvirtualthings.com
#

### CONFIG ###
$vc_server = "YOUR-VCENTER.domain.tld"
$vc_user = "YOUR-USERNAME"
$vc_pass = "YOUR-PASSWORD"
### END CONFIG ###

### MAIN ###
Write-Output ""

# Connect to vCenter
$vc_conn = Connect-VIServer -Server $vc_server -Protocol https -User $vc_user -Password $vc_pass

# Collect dvSwitches and settings
foreach($dvSW in Get-VDSwitch){
	$settings = "" | Select UUID, Datacenter, Version, OverallStatus, ConfigStatus, AlarmActionsEnabled, NumHosts, MTU,
							NumUplinks, UsedPorts, MaxPorts, LDP, LDPOperation,	AllowPromiscuous, MACChanges, ForgedTransmits,
							AllPortsBlocked, Teaming, FailureDetection,	NotifySwitches, Failback, ActiveUplinkPort, StandbyUplinkPort,
							VlanType, VlanId, MulticastFiltering

	Write-Output "==============================="
	Write-Output " $($dvSW.Name)"
	Write-Output "==============================="
	
	$settings.UUID = $dvSW.ExtensionData.Config.Uuid
	$settings.Datacenter = $dvSW.Datacenter
	$settings.Version = $dvSW.Version
	$settings.MTU = $dvSW.Mtu
	$settings.OverallStatus = $dvSW.ExtensionData.OverallStatus
	$settings.ConfigStatus = $dvSW.ExtensionData.ConfigStatus
	$settings.AlarmActionsEnabled = $dvSW.ExtensionData.AlarmActionsEnabled
	$settings.NumHosts = $dvSW.ExtensionData.Summary.NumHosts
	$settings.MulticastFiltering = $dvSW.ExtensionData.Config.MulticastFilteringMode
	
	# Ports
	$settings.UsedPorts = $dvSW.NumPorts
	$settings.MaxPorts = $dvSW.MaxPorts
	
	# Link Discovery
	$settings.LDP = $dvSW.LinkDiscoveryProtocol
	$settings.LDPOperation = $dvSW.LinkDiscoveryProtocolOperation

	# VLAN
	if($dvSW.ExtensionData.Config.DefaultPortConfig.Vlan.GetType().Name -eq "VmwareDistributedVirtualSwitchPvlanSpec"){
		$VLANType = "PrivateVLAN"
		$VLANId = $dvSW.ExtensionData.Config.DefaultPortConfig.Vlan.PvlanId
	} elseif($dvSW.ExtensionData.Config.DefaultPortConfig.Vlan.GetType().Name -eq "VmwareDistributedVirtualSwitchTrunkVlanSpec") {
		$VLANType = "VLANTrunk"
		$VLANId = [string]::Join(',',($dvSW.ExtensionData.Config.DefaultPortConfig.Vlan.VlanId | %{[string]$_.Start + "-" + [string]$_.End}))
	} elseif($dvSW.ExtensionData.Config.DefaultPortConfig.Vlan.GetType().Name -eq "VmwareDistributedVirtualSwitchVlanIdSpec") {
		$VLANType = "VLAN"
		$VLANId = $dvSW.Extensiondata.Config.DefaultPortConfig.Vlan.VlanId
		if($VLANId -eq 0) {
			$VLANType = "None"
		}
	} else {
		$VLANType = "None"
		$VLANId = ''
	}
	$settings.VlanType = $VLANType
	$settings.VlanId = $VLANId
	
	# Teaming and failover
	if ($dvSW.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.FailureCriteria.CheckBeacon.Value -eq $True) {
		$FailureDetection = "BeaconProbing"
	} else {
		$FailureDetection = "LinkStatus"
	}
	if ($dvSW.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.RollingOrder.Value -eq $True) {
		$Failback = $False
	} else {
		$Failback = $True
	}
	$settings.NumUplinks = $dvSW.NumUplinkPorts
	$settings.Teaming = $dvSW.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.Policy.Value
	$settings.FailureDetection = $FailureDetection
	$settings.NotifySwitches = $dvSW.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.NotifySwitches.Value
	$settings.Failback =  $Failback
	$settings.ActiveUplinkPort = $dvSW.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.ActiveUplinkPort -join ' | '
	$settings.StandbyUplinkPort = $dvSW.ExtensionData.Config.DefaultPortConfig.UplinkTeamingPolicy.UplinkPortOrder.StandbyUplinkPort -join ' | '
	
	# Security
	$settings.AllowPromiscuous = $dvSW.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value
	$settings.MACChanges = $dvSW.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value
	$settings.ForgedTransmits = $dvSW.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value
	$settings.AllPortsBlocked = $dvSW.ExtensionData.Config.DefaultPortConfig.Blocked.Value
	
	Write-Output $settings
}    

# Disconnect from vCenter
Disconnect-VIServer $vc_server -Confirm:$False

# End
Write-Output ""
Read-Host -Prompt "Press Enter to exit"
#EOF
