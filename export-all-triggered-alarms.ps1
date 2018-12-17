#
# Export all triggered alarms
#
# Desc:    Export all triggered alarms for all datacenter objects to a csv file
# Date:    09.08.2018
# Author:  Sebastian Kirsch
# URL:     https://www.justvirtualthings.com
#

### CONFIG ###
$vc_server = "YOUR-VCENTER.domain.tld"
$vc_user = "YOUR-USERNAME"
$vc_pass = "YOUR-PASSWORD"
### END CONFIG ###

### MAIN ###
$allAlarms = @()

Write-Output ""
Write-Output "-----------------------------"
Write-Output " Export all triggered alarms"
Write-Output "-----------------------------"
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

# Get all alarms
Write-Output " * Collecting all triggered alarms"
foreach ($alarm in ((get-datacenter).extensiondata.triggeredalarmstate)) {
	$triggeredAlarm = "" | Select Object, Alarm, Status, Timestamp, Acknowledged, AcknowledgedBy, AcknowledgedTime
	
	$alarmDefinition = Get-View -Id $alarm.Alarm
	$alarmEntity = Get-View -Id $alarm.Entity
	
	$triggeredAlarm.Object = $alarmEntity.Name
	$triggeredAlarm.Alarm = $alarmDefinition.Info.Name
	$triggeredAlarm.Status = $alarm.OverallStatus
	$triggeredAlarm.Timestamp = $alarm.Time
	$triggeredAlarm.Acknowledged = $alarm.Acknowledged
	$triggeredAlarm.AcknowledgedBy = $alarm.AcknowledgedByUser
	$triggeredAlarm.AcknowledgedTime = $alarm.AcknowledgedTime
	
	$allAlarms += $triggeredAlarm
}

# CSV export
Write-Output " * Exporting data to csv file"
$allAlarms | Export-Csv -UseCulture -NoTypeInformation $csvFile

# Disconnect from vCenter
Write-Output " * Disconnecting from vCenter server"
Disconnect-VIServer $vc_server -Confirm:$False

# End
Write-Output ""
Write-Output "All Done."
Write-Output ""
Read-Host -Prompt "Press Enter to exit"
#EOF
