# PowerShell Script for File Server Configuration

# This script sets up a file server with SMB shares, NTFS permissions, quota management, and shadow copy settings.

# Parameters
$shareName = "DataShare"
$folderPath = "D:\FileShares\Data"

# Create folder for the share
New-Item -Path $folderPath -ItemType Directory -Force

# Create the SMB share
New-SmbShare -Name $shareName -Path $folderPath -FullAccess "Everyone"

# Set NTFS permissions
$acl = Get-Acl $folderPath
$permission = "DOMAIN\FileServerUsers","ReadAndExecute","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl -Path $folderPath -AclObject $acl

# Configure quota management
$quotaPath = "D:\FileShares"
$limit = 100GB
Set-FsrmQuota -Path $quotaPath -Limit $limit -UserNotifications Enabled

# Enable shadow copies
Enable-VolumeShadowCopy -Volume D:

Write-Host "File server setup completed successfully."