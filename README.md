# PowerShell-Scripts
A collection of PowerShell Scripts used to complete a variety of Administrative tasks. It includes a set of reusable functions as well that can be called from other powershell scripts


# Functions
- Most of these can be used as standalone scripts and also as reusable functions that can be called from other scripts.

## Get-ADInactiveUsers.ps1
- Usage: Get-InactiveADUsers -OU "OU=Users,DC=domain,DC=com"
- Description: This function retrieves Active Directory users who have been inactive for more than 60 days
- Note: Ensure you have the Active Directory module installed and imported to use this function.
### Parameters:
   - OU: The distinguished name of the Organizational Unit (OU) to search within.

## Get-BadLogins.ps1
- Usage: Get-BadLogins -Hostname "RemoteComputerName"
- Example: Get-BadLogins -Hostname "Server01"
- Description: This function connects to a remote computer's Security event log and retrieves failed login attempts (Event ID 4625) from the last 12 hours.
### Parameters:
   - Hostname: The Hostname of the server to retrieve logs from

## Get-CSR.ps1
- Usage: Get-CSR -RemoteServer "ServerName" -SiteName "FQDN" -Organization "Org" -OrganizationalUnit "OU" -City "City" -State "State" -CountryCode "CC"
- Description: This function creates a Certificate Signing Request (CSR) on a remote server and moves it to a specified file server location.
### Parameters:
  -RemoteServer: The target server where the CSR will be created. 
  -SiteName: The fully qualified domain name (FQDN) of the site.
  -Organization: The organization name.
  -OrganizationalUnit: The organizational unit name.
  -City: The city name.
  -State: The state name.
  -CountryCode: The country code (e.g., US).
   
Note: Ensure that the target server has the necessary permissions and that PowerShell remoting is enabled.
 
Note: This script can also be ran as a standalone script and will loop to create multiple CSRs based on user input. 

(Update the File Server Path variable as needed)

## Get-IsAdmin.ps1
- Usage: Get-IsAdmin
- Description: This function checks if the current PowerShell session is running with elevated administrator privileges. 
- If not Admin, it prompts the user to run the script as an administrator and exits the script.
- Useful for scripts that require admin rights to execute certain commands or access specific system resources.

## Get-NewPassword.ps1
- Usage: Get-NewPassword
- Description: Prompts the user to enter and confirm a new password, ensuring they match.
- If the passwords match, it stores the password in the global variable $Script:Pass.
- If they do not match, it prompts the user to try again.

## Get-ServerList.ps1
- Usage: Get-ServerList -OU "OU=Servers,DC=domain,DC=com"
- Description: This function retrieves a list of all servers from a specified Active Directory OU and exports the list to a CSV file. 
- Requires the Active Directory module for PowerShell.
- Replace {Server Name} and {Path to File} in the $OutFile variable with actual values before running the script.
- This script can be modified to return the server list instead of exporting to a file if needed.
### parameters:
  -OU: The distinguished name of the Organizational Unit containing the servers.

## Set-Proxy.ps1
- Usage: Set-Proxy -ProxyServerIP "proxyserverIPAddress" -ProxyBypassList "<local>;*.domain.com"
- Description: This function sets the system proxy settings for WinHTTP and Internet Explorer.
- This script modifies registry settings and uses netsh to configure proxy settings.
- This script can be run as a standalone script or as a function within other scripts.
### parameters:
   -ProxyServerIP: The IP address of the proxy server.
   -ProxyBypassList: A list of domains to bypass the proxy. Example: "<local>;*.domain.com"

## Set-SuperUserLocalPass.ps1
- Usage: Set-SuperUserLocalPass -AdminUsername "AdminUser" -pass "NewPassword" -server "ServerName"
- Usage: Set-SuperUserLocalPass "AdminUser" "NewPassword" "ServerName"
- Description: This function sets the local administrator password on a remote server.
- Note: The Get-NewPassword function can be used to generate a new password if desired and then passed into this function as a parameter.
### Parameters:
   -AdminUsername: The username of the local administrator account.
   -pass: The new password to set for the local administrator account.
   -server: The target server where the password will be updated.
  

