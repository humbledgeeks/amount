# The name of the snapshot you want to revert back to.
$snapname = "<snapshot name>"

# The FQDN or IP address of your vCenter Server instance.
Connect-VIServer -Server <vCenter>

# The name of the folder that contains your nested hosts.
$vms = Get-VM -Location test-scripts | 
    ForEach-Object {$vms.name} {
        Stop-VM $_.name -Confirm:$false
        Set-VM $_.name -Snapshot $snapname -Confirm:$false
        Start-VM $_.name -Confirm:$false
        }
Disconnect-VIServer -Confirm:$false