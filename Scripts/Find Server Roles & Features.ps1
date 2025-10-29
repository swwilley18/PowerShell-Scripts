<#
.SYNOPSIS
Retrieves and exports installed Windows roles and features from a remote server.

.DESCRIPTION
This script prompts the user for a server name, queries the specified server for all installed Windows roles and features, and exports the results to a text file. The output file is saved with a naming convention that includes the server name.

.PARAMETER None
This script uses interactive input to gather the server name from the user.

.INPUTS
Server name entered interactively by the user via Read-Host prompt.

.OUTPUTS
Text file containing the names and installation states of all installed Windows features on the specified server. The file is saved as "{ServerName}-RolesInstalled.txt" in the configured output directory.

.EXAMPLE
When prompted, enter "SERVER01" to generate a report of installed roles and features for SERVER01.

.NOTES
- Requires appropriate permissions to query Windows features on the target server
- The output path variable contains a placeholder "{Path to Drop Results .txt file}" that should be updated with an actual file path
- Uses Get-WindowsFeature cmdlet which requires PowerShell remoting to be enabled on the target server
- Script pauses at the end to allow user to review the output file location

.FUNCTIONALITY
Remote server administration, Windows feature inventory, system documentation
#>


Write-Host
# Prompt user for server name
$ServerName = Read-Host "Please enter a Server name to see what roles and Features are Installed on it"
# Define output file path
$Output="{Path to Drop Results .txt file}\$ServerName-RolesInstalled.txt"

# Query installed Windows features and export to file
Get-WindowsFeature -ComputerName $ServerName | Where-Object {$_.installState -eq "Installed"} | Select-Object Name,InstallState |
Out-File $Output
Write-Host
Write-Host "Check the file listed below for results:"
Write-Host $Output
Pause;