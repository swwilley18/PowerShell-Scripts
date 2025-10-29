<#
.SYNOPSIS
    Renames Active Directory groups by appending a suffix to their current names.

.DESCRIPTION
    This script reads group names from a CSV file, finds the corresponding groups in Active Directory,
    and renames them by appending a specified suffix. It creates a log of successfully renamed groups
    and exports the results to a CSV file for tracking purposes.

.PARAMETER CsvPath
    Path to the input CSV file containing group names to be renamed. The CSV must have a 'GroupName' column.

.PARAMETER OutputCsvPath
    Path where the output CSV file containing renamed group information will be saved.

.INPUTS
    CSV file with the following structure:
    - GroupName: The current name of the Active Directory group to be renamed

.OUTPUTS
    CSV file containing:
    - OldName: The original group name
    - NewName: The new group name with suffix

.EXAMPLE
    Update the $CsvPath and $OutputCsvPath variables, set the desired suffix in the $newName assignment,
    then run the script to rename all groups listed in the CSV file.

.NOTES
    - Requires the ActiveDirectory PowerShell module
    - User must have appropriate permissions to rename AD groups
    - Groups that cannot be found or renamed will be skipped with warnings
    - Update the suffix placeholder "{Enter Suffix Here}" before running
    - Update the CSV path placeholders before running

.LINK
    Get-ADGroup
    Rename-ADObject
    Import-Csv
    Export-Csv
#>


# Import the Active Directory module
Import-Module ActiveDirectory

# Define the input CSV path and output CSV path
$CsvPath = "{Path to CSV of Group Names}\Rename-ADGroupsFromCSV.csv"
# Define the output CSV path
$OutputCsvPath = "{Destination Path for CSV of Renamed Groups}\BrokenGroups.csv"

# Read group names from CSV (assume column 'GroupName')
$groups = Import-Csv -Path $CsvPath
$renamedGroups = @()

# Loop through each group from the CSV
foreach ($entry in $groups) {
    # Get the current group name
    $oldName = $entry.GroupName
    # Validate the group name
    if (-not $oldName) {
        Write-Warning "Missing GroupName in CSV entry. Skipping."
        continue
    }
    # Find the group in AD
    $group = Get-ADGroup -Identity $oldName -ErrorAction SilentlyContinue
    # Check if the group was found
    if ($null -eq $group) {
        Write-Warning "Group '$oldName' not found in Active Directory. Skipping."
        continue
    }
    # Define the new name by appending a suffix
    $newName = "$oldName-{Enter Suffix Here}"
    # Attempt to rename the group
    try {
        # Define the new name by appending a suffix
        Rename-ADObject -Identity $group.DistinguishedName -NewName $newName
        Write-Host "Renamed '$oldName' to '$newName'"
        # Log the renamed group
        $renamedGroups += [PSCustomObject]@{
            OldName = $oldName
            NewName = $newName
        }
    } catch {
        Write-Warning "Failed to rename '$oldName': $_"
    }
}

# Export the renamed groups to CSV
if ($renamedGroups.Count -gt 0) {
    $renamedGroups | Export-Csv -Path $OutputCsvPath -NoTypeInformation
    Write-Host "Renamed group names exported to $OutputCsvPath"
} else {
    Write-Host "No groups were renamed. No CSV exported."
}

Write-Host "All group renames attempted."
