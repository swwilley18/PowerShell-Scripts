<#
.SYNOPSIS
    Retrieves a list of installed software applications and their versions from a remote server.

.DESCRIPTION
    This script prompts the user for a server name, then uses WMI to query the Win32_Product class
    to retrieve all installed applications and their versions. The results are exported to a text file
    for review.

.PARAMETER None
    This script uses Read-Host to interactively prompt for the server name.

.INPUTS
    Server name entered via Read-Host prompt.

.OUTPUTS
    Text file containing installed applications and versions, saved to the specified output path.

.EXAMPLE
    .\Find Installed Applications & Versions.ps1
    
    When prompted, enter a server name (e.g., "SERVER01") to generate a list of installed software.

.NOTES
    - Requires appropriate WMI permissions on the target server
    - The output path variable contains a placeholder "{Destination Path of output CSV}" that needs to be updated
    - Win32_Product class queries can be slow and may trigger consistency checks on the target system
    - Consider using alternative methods like registry queries for better performance

.LINK
    https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-product
#>

# Prompt user for server name
$Server = read-host "Please enter a server name to see the list of installed software"
# Define output file path
$Output="{Destination Path of output CSV}\$Server-InstalledApplications.txt"

# Query installed applications using WMI and export to file
Get-WmiObject -ComputerName $Server -Class Win32_Product | Select-Object Name, version |
Out-File $Output
Write-Host
Write-Host "Check the file listed below for results:"
Write-Host $Output

Pause;