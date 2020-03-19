﻿<#
.Synopsis
    Parameterized script for installing additional Domain Controller into existing AD DS forest.
     
.DESCRIPTION
    Custom script with parameters for installing additional Domain Controller into existing AD DS forest.
    Script will install all needed prerequisites, before promote destination server to Domain Controller. 

.EXAMPLE
    InstallAdditionalDomainController.ps1 -DomainName <> -DSRMPassword <> -DomainAdminPassword <> -DomainAdminUsername <>
#>

    [CmdletBinding()]
param (
    [Parameter(Mandatory=$true)][string]$DomainName,
    [Parameter(Mandatory=$true)][string]$DSRMPassword,
    [Parameter(Mandatory=$true)][string]$DomainAdminUsername,
    [Parameter(Mandatory=$true)][string]$DomainAdminPassword
)

# Install AD DS feature
Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

# Define variables for the new forest
$Password = ConvertTo-SecureString -String $DomainAdminPassword -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential $DomainAdminUsername, $Password

$DomainParameters = @{

    DomainName                    = $DomainName
    InstallDns                    = $true
    CreateDnsDelegation           = $false
    DatabasePath                  = "C:\Windows\NTDS"
    LogPath                       = "C:\Windows\NTDS"
    SysvolPath                    = "C:\Windows\SYSVOL"
    NoGlobalCatalog               = $false	    
    NoRebootOnCompletion          = $false
    Force                         = $true
    CriticalReplicationOnly       = $false
    SiteName                      = "Default-First-Site-Name"
    SafeModeAdministratorPassword = ($DSRMPassword | ConvertTo-SecureString -AsPlainText -Force)
    Credential                    = $Credentials

}

# Install new forest
Import-Module ADDSDeployment
Install-ADDSDomainController @DomainParameters