# Get-ServerList
# Description: This function retrieves a list of all servers from a specified Active Directory OU and exports the list to a CSV file. 
# Requires the Active Directory module for PowerShell.
# Usage: Get-ServerList -OU "OU=Servers,DC=domain,DC=com"
# parameters:
#   -OU: The distinguished name of the Organizational Unit containing the servers.
# Replace {Server Name} and {Path to File} in the $OutFile variable with actual values before running the script.
# This script can be modified to return the server list instead of exporting to a file if needed.

Function Get-ServerList {
    param {
        [string]$OU
    }

    #Point to Server OU
    $Servers = $OU

    # Get all computers within the specified OU
    $ServerList = (Get-ADComputer -SearchBase $Servers -Filter * -SearchScope Subtree | Select-Object Name)

    #Variable for output file
    $OutFile = "\\{Server Name}\{Path to File}\ServerList.csv"
    
    #Check for existing Server List and Delete
    if (Test-Path $OutFile) {

        #Delete Server list if it exists already
        Remove-Item -Path $OutFile -Force
        Write-Host "Old Server List deleted successfully."

    } else {
    }

    Write-Host "Creating ServerList.csv"

    #Creates a new txt file containing the name of each server in the Servers OU 
    $ServerList | Export-Csv $OutFile -NoTypeInformation
}