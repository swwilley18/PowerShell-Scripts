# Set-SuperUserLocalPass
# Usage: Set-SuperUserLocalPass -AdminUsername "AdminUser" -pass "NewPassword" -server "ServerName"
# Usage: Set-SuperUserLocalPass "AdminUser" "NewPassword" "ServerName"
# Parameters:
#   -AdminUsername: The username of the local administrator account.
#   -pass: The new password to set for the local administrator account.
#   -server: The target server where the password will be updated.
# Description: This function sets the local administrator password on a remote server.

function Set-SuperUserLocalPass{
    Param(
    [Parameter(Mandatory=$true)]$AdminUsername,
    # The Get-NewPassword function can be used to generate a new password if desired.
    [Parameter(Mandatory=$true)]$pass,
    [Parameter(Mandatory=$true)]$server
    )
    $UnsecurePassword = $pass
    $SecurePassword = ConvertTo-SecureString $UnsecurePassword -AsPlainText -Force
    Try{
      Invoke-Command -ComputerName $server{Get-LocalUser -Name $AdminUsername -ea stop | Set-LocalUser -Password $using:SecurePassword -PasswordNeverExpires 1 -ea stop -Verbose}
    }
    Catch{
        Write-Host -ForegroundColor Red "Failed to set $AdminUsername password on $server"
    }
}

## Use this to To Test or if you would rather feed in a list of servers. 
## Use Import-Csv for the $server (Expand Hostname/Name property) variable if you would like to
## Feed it a CSV file of server names. 
 
<#
$ServerList='Server1','Server2','Server3'
foreach($Server in $ServerList)
{
Set-SuperUserLocalPass "NewPassword" $Server
}
#>