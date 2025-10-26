# Get-ADInactiveUsers
# Usage: Get-InactiveADUsers -OU "OU=Users,DC=domain,DC=com"
# Description: This function retrieves Active Directory users who have been inactive for more than 60 days
# Parameters:
#   -OU: The distinguished name of the Organizational Unit (OU) to search within.
# Note: Ensure you have the Active Directory module installed and imported to use this function.

function Get-InactiveADUsers {
    param (
        [string]$OU
    )
    #This can be modified to change the inactivity period
    $When = ((Get-Date).AddDays(-60)).Date
    Get-ADUser -Filter {LastLogonDate -lt $When} -SearchBase $OU -Properties * | select-object samaccountname,givenname,surname,LastLogonDate
}