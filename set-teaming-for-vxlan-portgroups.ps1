#
# Set teaming policy for VXLAN portgroups
#
# Desc:    Set teaming policy for all NSX VXLAN dvPortgroups
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
$changedCounter = 0
Write-Output ""
Write-Output "--------------------------------------------"
Write-Output " Set teaming policy for all VXLAN portgoups"
Write-Output "--------------------------------------------"
Write-Output ""

# Enter dvSwitch name
$dvs = Read-Host -Prompt " Enter dvSwitch name"
Write-Output ""

# Select teaming policy
Write-Output " Available Teaming Policies:"
Write-Output "   (1) Route based on IP hash"
Write-Output "   (2) Route based on source MAC hash"
Write-Output "   (3) Route based on originating virtual port"
Write-Output "   (4) Use explicit failover order"
Write-Output "   (5) Route based on physical NIC load"
$teamingPolicy = Read-Host -Prompt " Please select a teaming policy (Default: 3)"
switch($teamingPolicy) {
	1 {$teaming = 'LoadBalanceIP'}
	2 {$teaming = 'LoadBalanceSrcMac'}
	3 {$teaming = 'LoadBalanceSrcId'}
	4 {$teaming = 'ExplicitFailover'}
	5 {$teaming = 'LoadBalanceLoadBased'}
	default {$teaming = 'LoadBalanceSrcId'}
}
Write-Output ""

# Network Failure Detection
Write-Output " Network failure detection:"
Write-Output "   (l) Link status only"
Write-Output "   (b) Beacon Probing"
$failureDetection = Read-Host -Prompt " Please choose (Default: l)"
switch($failureDetection) {
	'b' {$failure = 'BeaconProbing'}
	'l' {$failure = 'LinkStatus'}
	default {$failure = 'LinkStatus'}
}
Write-Output ""

# Notify Switches
Write-Output " Notify Switches:"
Write-Output "   (y) Yes"
Write-Output "   (n) No"
$notifySwitches = Read-Host -Prompt " Please choose (Default: y)"
switch($notifySwitches) {
	'y' {$notify = $True}
	'n' {$notify = $False}
	default {$notify = $True}
}
Write-Output ""

# Failback
Write-Output " Failback:"
Write-Output "   (y) Yes"
Write-Output "   (n) No"
$failbackNic = Read-Host -Prompt " Please choose (Default: y)"
switch($failbackNic) {
	'y' {$failback = $True}
	'n' {$failback = $False}
	default {$failback = $True}
}
Write-Output ""

# Uplink Ports
Write-Output " Uplink Port configuration:"
$ActiveUplink = Read-Host -Prompt "   Please enter the name of the active uplink adapters (Default: Uplink 1)"
$StandbyUplink = Read-Host -Prompt "   Please enter the name of the standby uplink adapters (Default: Uplink 2)"
$UnusedUplink = Read-Host -Prompt "   Please enter the name of the unused uplink adapters (Default: empty)"
Write-Output ""
if ($ActiveUplink -eq "") {
	$ActiveUplink = "Uplink 1"
}
if ($StandbyUplink -eq "") {
	$StandbyUplink = "Uplink 2"
}
if ($UnusedUplink -eq "") {
	$UnusedUplink = "{}"
}

Write-Output " ------------------------------"
Write-Output "  Modifying VXLAN dvPortgroups"
Write-Output " ------------------------------"

# Connect to vCenter
Write-Output " * Connecting to vCenter server"
$vc_conn = Connect-VIServer -Server $vc_server -Protocol https -User $vc_user -Password $vc_pass

# Set teaming policy on all VXLAN portgroups
Write-Output " * Configuring teaming policy"
foreach($dvPG in Get-VDPortgroup -VDSwitch $dvs){

	if($dvPG.name -like "vxw-dvs-*") {
		$changedPG = Get-VDPortgroup $dvPG | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy $teaming -FailoverDetectionPolicy $failure -NotifySwitches $notify -EnableFailback $failback -ActiveUplinkPort $ActiveUplink -StandbyUplinkPort $StandbyUplink -UnusedUplinkPort $UnusedUplink -confirm:$false
		if ($changedPG) {
			$changedCounter = $changedCounter + 1
		}
	}

}

# Disconnect from vCenter
Write-Output " * Disconnecting from vCenter server"
Disconnect-VIServer $vc_server -confirm:$False

# End
Write-Output ""
Write-Output ""
Write-Output "All Done. $($changedCounter) dvPortgroups were changed."
Write-Output ""
Read-Host -Prompt "Press Enter to exit"
#EOF
