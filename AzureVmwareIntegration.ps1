# Copyright 2022 CloudZbridge USA 
# Author John Gakhokidze
# Feel free to use/chaneg and distribute, assuming you keep these 3 lines


# Set Subscription to where you Automation Account is
Select-AZSubscription $subscription

# Get Workspace handle
$Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName

# Invoke KQL query
$QueryResults = Invoke-AzOperationalInsightsQuery -Workspace $Workspace -Query "Update| where (Product contains 'Windows Server 2019') and (Computer contains 'SOME_NAMING_SCHEMA')|distinct Computer"

# Note: KQL query returns FQDN name of server, depending on your VMware naming convention, you may want to trim
# In example below, I am removing domain.com

$context=($QueryResults.Results|findstr -v Computer|findstr -v "\-\-\-").Trim(".domain.com")

#You can user also Credentials here, or just leave only user and will be authenticated
Connect-VIServer -Server $vcenter -User $user -Password 'SOME_PASSOWRD'

foreach($server in $context){
    $name="Pre Windows updates"
    $vm = get-vm -name $server
    write-host "creating snapshot $name for $vm.name"
# Running snapshots in sync, you may want to change to -runasync:$true
    $snap = New-Snapshot -vm $vm -name $name -confirm:$false -runasync:$false
    $snap
    }

# Uncomment section below in new file for removing snapshot and comment 8 lines above

#foreach ($server in $servers){
#    $vm = get-vm -name $server
#    $snap = get-Snapshot -vm $vm -name $name
#    write-host "removing snapshot $snap.name for $vm.name"
# Removing snapshots in sync, you may want to change to -runasync:$true
#    remove-snapshot -snapshot $snap -confirm:$false -runasync:$false
#}
