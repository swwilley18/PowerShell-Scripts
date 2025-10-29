<#
.SYNOPSIS
    Copies all members from one Active Directory group to another Active Directory group.

.DESCRIPTION
    This script retrieves all members from a source Active Directory group and adds them to a destination Active Directory group. 
    It checks for existing membership to avoid duplicate additions and provides detailed output for each operation.

.PARAMETER SourceGroup
    The name or distinguished name of the source Active Directory group from which members will be copied.

.PARAMETER DestinationGroup
    The name or distinguished name of the destination Active Directory group to which members will be added.

.EXAMPLE
    .\Copy-ADGroupMembers.ps1 -SourceGroup "Marketing Team" -DestinationGroup "All Staff"
    Copies all members from the "Marketing Team" group to the "All Staff" group.

.EXAMPLE
    .\Copy-ADGroupMembers.ps1 -SourceGroup "CN=Sales,OU=Groups,DC=contoso,DC=com" -DestinationGroup "Project Team Alpha"
    Copies all members from the Sales group (using distinguished name) to the "Project Team Alpha" group.

.NOTES
    - Requires the Active Directory PowerShell module
    - Requires appropriate permissions to read source group membership and modify destination group membership
    - Script will skip members that already exist in the destination group
    - Provides detailed output showing which members were added or skipped

.INPUTS
    None. You cannot pipe objects to this script.

.OUTPUTS
    Console output showing the status of each member addition operation.
#>


# Parameters
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceGroup,
    [Parameter(Mandatory=$true)]
    [string]$DestinationGroup
)

# Import Active Directory Module
Import-Module ActiveDirectory

# Get all members of the source group
$members = Get-ADGroupMember -Identity $SourceGroup -ErrorAction Stop

# Iterate through each member and add to the destination group if not already a member
foreach ($member in $members) {
    # Check if the member is already in the destination group
    $isMember = Get-ADGroupMember -Identity $DestinationGroup | Where-Object { $_.DistinguishedName -eq $member.DistinguishedName }

    # If not a member, add to the destination group
    if (-not $isMember) {
        try {
            Add-ADGroupMember -Identity $DestinationGroup -Members $member -ErrorAction Stop
            Write-Host "Added $($member.SamAccountName) to $DestinationGroup"
        } catch {
            Write-Warning "Failed to add $($member.SamAccountName): $_"
        }
    } else {
        Write-Host "$($member.SamAccountName) is already a member of $DestinationGroup"
    }
}

Write-Host "Copy complete."
