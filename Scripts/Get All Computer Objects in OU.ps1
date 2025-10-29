<#
.SYNOPSIS
    Retrieves all computer objects from groups within a specified Organizational Unit (OU) and exports the results to a CSV file.

.DESCRIPTION
    This script searches for all Active Directory groups within a specified OU, then identifies computer members 
    within each group (including nested groups through recursive search). The results are compiled into a CSV 
    file showing the relationship between groups and their computer members.

.PARAMETER OU
    The Distinguished Name of the Organizational Unit to search for groups containing computer objects.
    Must be modified in the script before execution.

.PARAMETER outputCSV
    The file path where the resulting CSV file will be saved. The filename includes the OU name.
    Must be modified in the script before execution.

.OUTPUTS
    CSV file containing two columns:
    - GroupName: Name of the Active Directory group
    - ComputerName: Name of the computer object (or "Empty" if no computers, or error message if access denied)

.EXAMPLE
    # Modify the variables in the script:
    $OU = "OU=Servers,DC=contoso,DC=com"
    $outputCSV = "C:\Reports\Servers-ADComputers.csv"
    
    # Then run the script to generate a report of all computer objects in groups within the Servers OU

.NOTES
    - Requires the ActiveDirectory PowerShell module
    - Requires appropriate permissions to read AD groups and their members
    - Uses recursive search to include computer members from nested groups
    - Handles errors gracefully by recording error messages in the output
    - Groups with no computer members are marked as "Empty" in the report

.LINK
    Get-ADGroup
    Get-ADGroupMember
    Export-Csv
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU and the output CSV file
$OU = "{OU to Search for Computer Objects}"
$outputCSV = "{Destination Path for CSV of Computer objects in OU}\$OU-ADComputers.csv"

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all groups in the specified OU
$groups = Get-ADGroup -Filter * -SearchBase $OU

# Initialize an array to hold the results
$results = @()

# Loop through each group and get its computer members
foreach ($group in $groups) {
    try {
        # Get computer members of the group
        $members = Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.objectClass -eq 'computer' }
        if ($members) {
            # Group has computer members
            foreach ($member in $members) {
                $results += [PSCustomObject]@{
                    GroupName    = $group.Name
                    ComputerName = $member.Name
                }
            }
        } else {
            # Group has no computer members
            $results += [PSCustomObject]@{
                GroupName    = $group.Name
                ComputerName = "Empty"
            }
        }
    } catch {
        # Handle errors (e.g., access denied)
        $results += [PSCustomObject]@{
            GroupName    = $group.Name
            ComputerName = "Error: $($_.Exception.Message)"
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCSV -NoTypeInformation

Write-Output "Export complete. The CSV file is located at $outputCSV"
