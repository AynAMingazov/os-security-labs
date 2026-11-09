# Lab 3: Active Directory on Windows Server 2022 (run as Administrator)
# In the lab most steps were done in the GUI; this script repeats them in PowerShell.

# 1. Role and new forest (the server reboots after the second command)
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "domain.local" -DomainNetbiosName "DOMAIN" -InstallDns

# 2. Domain user with logon hours Mon-Fri 08:00-18:00
Import-Module ActiveDirectory
New-ADUser -Name "ainur mingazov" -GivenName ainur -Surname mingazov `
    -SamAccountName ainur14 -UserPrincipalName ainur14@domain.local `
    -AccountPassword (Read-Host -AsSecureString "Password") -Enabled $true
# Logon hours are a 21-byte bitmap in UTC; in the lab they were set in ADUC -> Account -> Logon Hours.

# 3. Groups: user -> global -> domain local -> resource
New-ADGroup -Name GlobalDomainGroup14 -GroupScope Global -GroupCategory Security
New-ADGroup -Name LocalDomainGroup14  -GroupScope DomainLocal -GroupCategory Security
Add-ADGroupMember GlobalDomainGroup14 -Members ainur14
Add-ADGroupMember LocalDomainGroup14  -Members GlobalDomainGroup14

# 4. OU with a GPO that imports the security template from lab 2
New-ADOrganizationalUnit -Name "Workstations14" -Path "DC=domain,DC=local"
New-GPO -Name "SecureWS14" | New-GPLink -Target "OU=Workstations14,DC=domain,DC=local"
# Template TestTemplate14.inf was imported in gpmc.msc:
# Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Import Policy
