<#
.SYNOPSIS
    Retrieves all user members from Active Directory groups within a specified Organizational Unit (OU) and exports the results to a CSV file.

.DESCRIPTION
    This script searches for all Active Directory groups within a specified OU, then recursively retrieves all user members from each group. The results include group name, username, group creation date, and group modification date. Groups with no user members are marked as "Empty" and any errors encountered during processing are captured in the output.

.PARAMETER OU
    The Distinguished Name of the Organizational Unit to search for AD groups. This should be specified in the script by replacing the placeholder "{OU to Search for User Objects}".

.PARAMETER outputCSV
    The file path where the CSV results will be saved. The script uses a dynamic path based on the OU name by replacing the placeholder "{Destination Path for CSV of User objects in OU}".

.OUTPUTS
    CSV file containing the following columns:
    - GroupName: Name of the Active Directory group
    - UserName: SamAccountName of the user member (or "Empty" if no users, or error message if processing failed)
    - GroupCreated: Date when the group was created
    - GroupModified: Date when the group was last modified

.EXAMPLE
    # Before running, update the following variables in the script:
    $OU = "OU=MyOU,DC=domain,DC=com"
    $outputCSV = "C:\Reports\MyOU-ADUsers.csv"

.NOTES
    - Requires the ActiveDirectory PowerShell module
    - Requires appropriate permissions to read AD groups and their members
    - Uses recursive group membership retrieval
    - Includes progress bar for monitoring script execution
    - Handles errors gracefully by capturing them in the output
    - Only processes user objects, filtering out other object types like computers or groups

.PREREQUISITES
    - Active Directory PowerShell module must be installed
    - Sufficient permissions to read AD groups and memberships in the target OU
    - Network connectivity to domain controllers
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU and the output CSV file
$OU = "{OU to Search for User Objects}"
# Define the output CSV file destination
$outputCSV = "{Destination Path for CSV of User objects in OU}\$OU-ADUsers.csv"

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all groups in the specified OU
$groups = Get-ADGroup -Filter * -SearchBase $OU -Properties WhenCreated, WhenChanged

# Initialize an array to hold the results
$results = @()

# Initialize progress bar variables
$totalGroups = $groups.Count
$currentGroup = 0

# Loop through each group and get its members
foreach ($group in $groups) {
    # Increment progress counter
    $currentGroup++
    # Update progress bar
    Write-Progress -Activity "Processing Groups" -Status "Processing $($group.Name)" -PercentComplete (($currentGroup / $totalGroups) * 100)
    
    try {
        # Get user members of the group
        $members = Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.objectClass -eq 'user' }
        # Check if any members were found
        if ($members) {
            # Found user members
            foreach ($member in $members) {
                # Add user attributes to results
                $results += [PSCustomObject]@{
                    GroupName        = $group.Name
                    UserName         = $member.SamAccountName
                    GroupCreated     = $group.WhenCreated
                    GroupModified    = $group.WhenChanged
                }
            }
        } else {
            # Group has no user members
            $results += [PSCustomObject]@{
                GroupName = $group.Name
                UserName  = "Empty"
            }
        }
    } catch {
        # Handle errors (e.g., access denied)
        $results += [PSCustomObject]@{
            GroupName = $group.Name
            UserName  = "Error: $($_.Exception.Message)"
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCSV -NoTypeInformation

Write-Output "Export complete. The CSV file is located at $outputCSV"

