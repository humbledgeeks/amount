#========================================================================================================================
# Specify host credentials
#========================================================================================================================
$hostuser = 'root'
$hostpass = '<password>'
$vmhosts = Import-CSV -Path configure_hosts.csv
$vmhosts| ForEach-Object {$vmhosts.hostname} {
    #====================================================================================================================
	# Connect to each host
	#====================================================================================================================
    Connect-VIServer -Server $_.mgmtip -User $hostuser -Password $hostpass
	
	#====================================================================================================================
	# Configure local networking
	#====================================================================================================================
	# Edit NIC Teaming Policy
	Get-VirtualSwitch -name $_.sw0name | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $_.sw0nic0,$_.sw0nic1
	
	# Remove Default VMPG
	Get-VirtualSwitch -name $_.sw0name | Get-VirtualPortGroup -Name 'VM Network' | Remove-VirtualPortGroup -Confirm:$false
	
	# Rename Default Management Network
	Get-VirtualSwitch -name $_.sw0name | Get-VirtualPortGroup -Name 'Management Network' | Set-VirtualPortGroup -Name $_.mgmtpgname
	
	# Add iSCSI-1 VMPG and VLAN & Edit NIC Teaming Policy
	Get-VirtualSwitch -name $_.sw0name | New-VirtualPortGroup -Name $_.iscsipg1name -VLanId $_.iscsipg1vlan
	Get-VirtualPortGroup -Name $_.iscsipg1name | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $_.sw0nic0 -MakeNicUnused $_.sw0nic1
	
	# Add iSCSI-2 VMPG and VLAN & Edit NIC Teaming Policy
	Get-VirtualSwitch -name $_.sw0name | New-VirtualPortGroup -Name $_.iscsipg2name -VLanId $_.iscsipg2vlan
	Get-VirtualPortGroup -Name $_.iscsipg2name | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $_.sw0nic1 -MakeNicUnused $_.sw0nic0
	
	# Add OOB Mgmt VMPG and VLAN
	Get-VirtualSwitch -name $_.sw0name | New-VirtualPortGroup -Name $_.oobmpgname -VLanId $_.oobmpgvlan
	
	# Add vCenter VMPG and VLAN
	Get-VirtualSwitch -name $_.sw0name | New-VirtualPortGroup -Name $_.vcenpgname -VLanId $_.vcenpgvlan
	
	# Add Nested Labs VMPG and VLAN
	Get-VirtualSwitch -name $_.sw0name | New-VirtualPortGroup -Name $_.nlabpgname -VLanId $_.nlabpgvlan

    # Add Core Servers VMPG and VLAN
	Get-VirtualSwitch -name $_.sw0name | New-VirtualPortGroup -Name $_.corepgname -VLanId $_.corepgvlan
	
	# Create new vSwitch for Secure VMPGs
	# NEED TO FIND COMMANDS REQUIRED
	# Add Internet VMPG and VLAN
	# Get-VirtualSwitch -name $_.sw1name | New-VirtualPortGroup -Name $_.inetpgname -VLanId $_.inetpgvlan
		
	#====================================================================================================================
	# Configure iSCSI vmk
	#====================================================================================================================
	New-VMHostNetworkAdapter -VirtualSwitch $_.sw0name -PortGroup $_.iscsipg1name -IP $_.iscsi1ip -SubnetMask $_.iscsi1sn
	New-VMHostNetworkAdapter -VirtualSwitch $_.sw0name -PortGroup $_.iscsipg2name -IP $_.iscsi2ip -SubnetMask $_.iscsi2sn
	
	#====================================================================================================================
	# Configure iSCSI Initiator
	#====================================================================================================================
	Get-VMHostStorage $_.mgmtip | Set-VMHostStorage -SoftwareIScsiEnabled $true
	New-IScsiHbaTarget -IScsiHba $_.vmhbax -Address $_.iscsitg1ip -Port $_.iscsitg1port
    New-IScsiHbaTarget -IScsiHba $_.vmhbax -Address $_.iscsitg2ip -Port $_.iscsitg2port
    New-IScsiHbaTarget -IScsiHba $_.vmhbax -Address $_.iscsitg3ip -Port $_.iscsitg3port
    New-IScsiHbaTarget -IScsiHba $_.vmhbax -Address $_.iscsitg4ip -Port $_.iscsitg4port
	$bind1 = @{
		adapter = $_.vmhbax
		force = $true
		nic = 'vmk1'
	}
	$bind2 = @{
		adapter = $_.vmhbax
		force = $true
		nic = 'vmk2'
	}
	$esxcli = Get-EsxCli -V2 -VMHost $_.mgmtip
	$esxcli.iscsi.networkportal.add.Invoke($bind1)
	$esxcli.iscsi.networkportal.add.Invoke($bind2)
	Get-VMHostStorage -RescanAllHba -RescanVmfs
	
	#====================================================================================================================
	# Rename Local Datastore (if needed)
	#====================================================================================================================
	Get-Datastore -Name datastore1 | Set-Datastore -Name $_.localdatastore

    #====================================================================================================================
	# Configure NTP Server and Restart Service
	#====================================================================================================================
    Get-VMHost | Add-VMHostNtpServer -NtpServer us.pool.ntp.org
    Get-VMHost | Get-VMHostService | where {$_.Key -eq "ntpd"} | Restart-VMHostService -Confirm:$false
	
	#====================================================================================================================
	# Disconnect from each host
	#====================================================================================================================
	Disconnect-VIServer $_.mgmtip -Confirm:$false
}