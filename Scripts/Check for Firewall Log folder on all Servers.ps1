<#
.SYNOPSIS
    Checks for the presence of Windows Firewall log files on all servers in a specified Active Directory OU.

.DESCRIPTION
    This script queries Active Directory for all computers in a specified Organizational Unit (OU) and checks
    if Windows Firewall log files exist on each server. It verifies the presence of pfirewall.log, domainfw.log,
    privatefw.log, and publicfw.log files in the standard Windows firewall log directory. Servers missing all
    firewall log files are identified and reported.

.PARAMETER None
    This script uses hardcoded variables for configuration.

.INPUTS
    None. The script reads from Active Directory based on the configured OU.

.OUTPUTS
    - Text file containing list of servers missing firewall log files
    - Console output displaying the list of affected servers

.EXAMPLE
    .\Check for Firewall Log folder on all Servers.ps1
    
    Runs the script to check all servers in the configured OU for missing firewall log files.

.NOTES
    - Requires Active Directory PowerShell module
    - Requires appropriate permissions to access remote server file systems via administrative shares
    - Script checks for files at: \\ServerName\C$\Windows\system32\LogFiles\Firewall\
    - Only reports servers where ALL firewall log files are missing
    - Update $ServerOU and $Out_File variables before running

.REQUIREMENTS
    - Active Directory PowerShell module
    - Administrative access to target servers
    - Network connectivity to target servers
    - Write permissions to output file location
#>


# Import Active Directory Module
Import-Module ActiveDirectory

# To point to servers OU
$ServerOU = '{OU Containing Servers}'

# Get all computers within the specified OU
$ServerList = Get-ADComputer -Filter * -SearchBase $ServerOU -Properties Name -SearchScope Subtree

# Variable used to store computers that are missing the firewall log folder
$FirewallLogMissing = @()

# Variable for output file
$Out_File = "\\{Server Name}\{Output File Path}\FirewallLogMissing.txt"

# Iterate through OU
foreach ($computer in $ServerList) {
    
    $ServerName = $computer.Name
    # Check if the firewall log folders exist on each computer
    $pfirewallExists = Test-Path "\\$ServerName\C$\Windows\system32\LogFiles\Firewall\pfirewall.log"
    $domainfw = Test-Path "\\$ServerName\C$\Windows\system32\LogFiles\Firewall\domainfw.log"
    $privatefw = Test-Path "\\$ServerName\C$\Windows\system32\LogFiles\Firewall\privatefw.log"
    $publicfw = Test-Path "\\$ServerName\C$\Windows\system32\LogFiles\Firewall\publicfw.log"

    # If none of the firewall log files exist, add the server to the list
    if (-not $pfirewallExists -and -not $domainfw -and -not $privatefw -and -not $publicfw) {
        $FirewallLogMissing += $ServerName
    }
}

# Output the list of servers without the firewall log folder to a text file
$FirewallLogMissing | Out-File -FilePath $Out_File

# Display the list of servers without the firewall log folder
$FirewallLogMissing
