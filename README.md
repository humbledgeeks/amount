# Introduction 
Supplemental scipts for Humbled Geeks blog.

# Projects
1.	Add vSphere Hosts to vCenter
- add_hosts_to_vcenter.ps1

2.	Configure Hosts
- configure_hosts.ps1 = Configure base networking, iSCSI datastores, and NTP server info
- configure_hosts.csv = Variables called on by .ps1

3.	Create DHCP Scopes
- create_dhcp_scopes.ps1 = Create and Configure DHCP Scopes
- create_dhcp_scopes_add.csv = Variables called on by .ps1 to ADD scopes
- create_dhcp_scopes_set.csv = Variables called on by .ps1 to SET scopes

4.	Create DNS Records
- create_dns_records.ps1 = Create DNS Zones, Create A and PTR Records
- create_dns_records_zone.csv = Variables called on by .ps1 to Create DNS Zones
- create_dns_records_a.csv = Variables called on by .ps1 to Create A and PTR Records

# Run
Local machine with network connectivity to vCenter
1. Add vSphere Hosts to vCenter

Local machine with network connectivity to ESXi Hosts
2. Configure Hosts

Windows Server with DHCP Role
3. Create DHCP Scopes

Windows Server with DNS Role
4. Create DNS Records

# Contribute
Be geeks!
