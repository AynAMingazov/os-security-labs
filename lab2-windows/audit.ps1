# Lab 2: file access audit on Windows Server 2022 (run as Administrator)

# 1. Enable object access auditing for the file system
auditpol /set /subcategory:"File System" /success:enable /failure:enable
auditpol /get /subcategory:"File System"

# 2. Folder with inheritance disabled
New-Item -ItemType Directory -Path C:\Test -Force | Out-Null
$acl = Get-Acl C:\Test
$acl.SetAccessRuleProtection($true, $true)      # disable inheritance, keep copies of inherited rules
Set-Acl C:\Test $acl

# 3. SACL: audit every access of Everyone to the test file
New-Item -ItemType File -Path C:\Test\secret.txt -Force | Out-Null
$acl = Get-Acl C:\Test\secret.txt -Audit
$rule = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone", "Read,Write", "Success,Failure")
$acl.AddAuditRule($rule)
Set-Acl C:\Test\secret.txt $acl

# 4. Generate access and read the Security log
Get-Content C:\Test\secret.txt | Out-Null
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4656,4663} -MaxEvents 5 |
    Select-Object TimeCreated, Id, Message | Format-List

# 5. Local policy: minimum password length (also set in secpol.msc)
net accounts /minpwlen:6
net accounts
