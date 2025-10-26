# Get-CSR
# Function Usage: Get-CSR -RemoteServer "ServerName" -SiteName "FQDN" -Organization "Org" -OrganizationalUnit "OU" -City "City" -State "State" -CountryCode "CC"
# Description: This function creates a Certificate Signing Request (CSR) on a remote server and moves it to a specified file server location.
# Parameters:
#   -RemoteServer: The target server where the CSR will be created. 
#   -SiteName: The fully qualified domain name (FQDN) of the site.
#   -Organization: The organization name.
#   -OrganizationalUnit: The organizational unit name.
#   -City: The city name.
#   -State: The state name.
#   -CountryCode: The country code (e.g., US).
# Note: Ensure that the target server has the necessary permissions and that PowerShell remoting is enabled.
# Note: This script can also be ran as a standalone script and will loop to create multiple CSRs based on user input. 
#       (Update the File Server Path variable as needed)

function Get-CSR {   
    param (
        [string]$RemoteServer,
        [string]$SiteName,
        # Comment out or remove the below parameters if you do not wish to customize the CSR details
        # These parameters can be hardcoded if desired
        [string]$Organization,
        [string]$OrganizationalUnit,
        [string]$City,
        [string]$State,
        [string]$CountryCode
    )
    
    #Create a new PowerShell Session on the server that the CSR will be created from
    $session = New-PSSession -ComputerName $RemoteServer

    #Script to be ran on the Remote Server
    Invoke-Command -Session $session -ScriptBlock {
        param ($SiteName)
        param ($Organization)
        param ($OrganizationalUnit)
        param ($City)
        param ($State)
        param ($CountryCode)

        #Path used for the Information file that is used to create the certificate on the remote server
        $infPath = "C:\$($SiteName.Replace('.', '_')).inf"

        #Path to create the CSR file on the remote server
        $csrPath = "C:\$($SiteName.Replace('.', '_')).csr"
        if (Test-Path $csrPath) {
            Remove-Item $csrPath -Force
            Write-Host "Existing CSR at $csrPath has been deleted."
        }

        #Contents of the Information File
        $infContent = @"
[NewRequest]
Subject = "CN=$SiteName, O=$Organization, OU=$OrganizationalUnit, L=$City, S=$State, C=$CountryCode"
KeySpec = 1
KeyUsage = 0xA0
KeyLength = 2048
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
MachineKeySet = $true
Exportable = $true
RequestType = "PKCS10"
"@
        Set-Content -Path $infPath -Value $infContent

        #Create a new Certificate Request
        certreq -new $infPath $csrPath

        return $csrPath
    } -ArgumentList $SiteName
}

# Loop to create multiple CSRs
do {
    # Prompt user for input
    $RemoteServer = Read-Host "Enter the remote server name"
    $SiteName = Read-Host "Enter the FQDN of the site"
    $Organization = Read-Host "Enter the Organization"
    $OrganizationalUnit = Read-Host "Enter the Organizational Unit"
    $City = Read-Host "Enter the City"
    $State = Read-Host "Enter the State"
    $CountryCode = Read-Host "Enter the Country Code (e.g., US)"
 
    # Create CSR
    $CSRPath = Get-CSR -RemoteServer $RemoteServer -SiteName $SiteName -Organization $Organization -OrganizationalUnit $OrganizationalUnit -City $City -State $State -CountryCode $CountryCode

    # Move CSR to File Server Certificate CSR Folder
    $FileServerPath = "{File Server Path}\Certificates\CSRs\"
    Move-Item -Path \\$RemoteServer\C$\$($SiteName.Replace('.', '_')).csr -Destination $FileServerPath -Force
    Write-Host "CSR created in: $FileServerPath"

    # Remove the .inf file
    $infPath = "\\$RemoteServer\C$\$($SiteName.Replace('.', '_')).inf"
    if (Test-Path $infPath) {
        Remove-Item $infPath -Force
        Write-Host "INF file at $infPath has been deleted."
    }

    # Ask the user if they want to create another CSR
    $createAnother = Read-Host "Do you want to create another CSR? (yes/no)"
} while ($createAnother -eq 'yes')