<#
.SYNOPSIS
    Retrieves all nested Active Directory groups within groups located in a specified Organizational Unit (OU).

.DESCRIPTION
    This script scans all Active Directory groups within a specified OU and identifies any nested groups (groups that are members of other groups). 
    The results are exported to a CSV file showing the parent group name and its nested group members. Groups without nested members are marked as "Empty".

.PARAMETER OU
    The Distinguished Name of the Organizational Unit containing the AD Groups to be analyzed.
    Must be manually set in the script before execution.

.PARAMETER OutputCsv
    The destination path for the CSV file that will contain the nested AD groups report.
    The filename includes the OU name for identification.

.OUTPUTS
    CSV file containing two columns:
    - 'Group Name': The name of the parent AD group
    - 'Nested AD Group': The name of the nested group member, or "Empty" if no nested groups exist

.EXAMPLE
    # Modify the script variables before running:
    $OU = "OU=Security Groups,DC=contoso,DC=com"
    $OutputCsv = "C:\Reports\Security Groups-NestedADgroups.csv"
    
    # Then execute the script to generate the nested groups report

.NOTES
    - Requires the ActiveDirectory PowerShell module
    - The script uses non-recursive group member retrieval to show only direct nested groups
    - Error handling is included to capture any issues accessing group memberships
    - Output is encoded in UTF8 format for broad compatibility

.AUTHOR
    Script for analyzing nested AD group structure within organizational units
#>


# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU and output CSV file
$OU = "{Distinguished Name of OU containing AD Groups}"
# Define the output CSV file destination
$OutputCsv = "{Destination Path for CSV of Nested AD Groups}\$OU-NestedADgroups.csv"

# Initialize an array to hold the results
$results = @()

# Get all groups in the specified OU
$groups = Get-ADGroup -SearchBase $OU -Filter *

# Loop through each group and get its nested group members
foreach ($group in $groups) {
    
    Try {
        # Get group members that are groups (nested groups)
        $nestedGroups = Get-ADGroupMember -Identity $group.DistinguishedName -Recursive:$false | Where-Object { $_.objectClass -eq 'group' }
        # Check if any nested groups were found
        if ($nestedGroups) {
            # Add each nested group to the results
            foreach ($nested in $nestedGroups) {
                # Add nested group to results
                $results += [PSCustomObject]@{
                    'Group Name'        = $group.Name
                    'Nested AD Group'   = $nested.Name
                }
            }
        }
        else {
            # No nested groups found, mark as "Empty"
            $results += [PSCustomObject]@{
                    'Group Name'        = $group.Name
                    'Nested AD Group'   = "Empty"
                }
        }
    }
    Catch {
        # Handle errors (e.g., access denied)
        $results += [PSCustomObject]@{
            'Group Name'        = $group.Name
            'Nested AD Group'   = "Error: $($_.Exception.Message)"
        }
    }
}

# Export results to CSV
$results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8