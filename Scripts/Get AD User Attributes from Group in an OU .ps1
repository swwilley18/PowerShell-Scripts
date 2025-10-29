<#
.SYNOPSIS
    Exports Active Directory user attributes from all groups within a specified Organizational Unit (OU) to a CSV file.

.DESCRIPTION
    This script retrieves all Active Directory groups from a specified OU, gets all user members from each group (including nested groups), 
    and exports detailed user attributes to a CSV file. The script includes progress tracking and error handling, and eliminates duplicate 
    user entries in the final output.

.PARAMETER OU
    The Distinguished Name of the Organizational Unit containing the AD Groups to process.
    Must be manually configured in the script before execution.

.PARAMETER outputCSV
    The destination file path for the CSV output containing user attributes.
    Must be manually configured in the script before execution.

.OUTPUTS
    CSV file containing the following user attributes:
    - UserName (SamAccountName)
    - City
    - Department
    - DisplayName
    - GivenName
    - HomePage
    - isDeleted
    - lastLogon (formatted as MM/dd/yyyy)
    - Manager
    - PasswordLastSet
    - PasswordNeverExpires
    - PrincipalsAllowedtoDelegatetoAccount
    - publicDelegatesBL
    - Title
    - UserPrincipalName

.EXAMPLE
    # Configure the variables in the script:
    $OU = "OU=Groups,OU=Company,DC=domain,DC=com"
    $outputCSV = "C:\Reports\Groups-ADUserAttributes.csv"
    
    # Then run the script
    .\Get-AD-User-Attributes-from-Group-in-an-OU.ps1

.NOTES
    - Requires the ActiveDirectory PowerShell module
    - Script must be run with appropriate permissions to read AD groups and users
    - The script processes groups recursively to include nested group memberships
    - Duplicate users across multiple groups are automatically removed from the final output
    - Progress bar displays current processing status
    - Errors are captured and included in the output for troubleshooting

.LINK
    Get-ADGroup
    Get-ADGroupMember
    Get-ADUser
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU and the output CSV file
$OU = "{Distinguished Name of OU containing AD Groups}"
# Define the output CSV file destination
$outputCSV = "{Destination Path for CSV of User objects in OU}\$OU-ADUserAttributes.csv"

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all groups in the specified OU
$groups = Get-ADGroup -Filter * -SearchBase $OU -Properties Name

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
            foreach ($member in $members) {
                # Get full user attributes
                $user = Get-ADUser -Identity $member.SamAccountName -Properties * 
                # Add user attributes to results
                $results += [PSCustomObject]@{
                    UserName         = $user.SamAccountName
                    City             = $user.City
                    Department       = $user.Department
                    DisplayName      = $user.DisplayName
                    GivenName        = $user.GivenName
                    HomePage         = $user.HomePage
                    isDeleted        = $user.isDeleted
                    # Format lastLogon date
                    lastLogon        = if ($user.lastLogon) { [datetime]::FromFileTime($user.lastLogon).ToString("MM/dd/yyyy") } else { "" }
                    Manager          = $user.Manager
                    PasswordLastSet  = $user.PasswordLastSet
                    PasswordNeverExpires = $user.PasswordNeverExpires
                    PrincipalsAllowedtoDelegatetoAccount = $user.PrincipalsAllowedtoDelegatetoAccount
                    publicDelegatesBL = $user.publicDelegatesBL
                    Title            = $user.Title
                    UserPrincipalName = $user.UserPrincipalName
                }
            }
        } else {
            # Group has no user members
            # Do Nothing
        }
    } catch {
        $results += [PSCustomObject]@{
            UserName  = "Error: $($_.Exception.Message)"
        }
    }
}

# Eliminate duplicate entries based on UserName
$uniqueResults = $results | Sort-Object UserName | Get-Unique -AsString

# Export the results to a CSV file
$uniqueResults | Export-Csv -Path $outputCSV -NoTypeInformation

Write-Output "Export complete. The CSV file is located at $outputCSV"