# Retrieve Bad Logins from Remote Computer's Event Log
# Usage: Get-BadLogins -Hostname "RemoteComputerName"
# Example: Get-BadLogins -Hostname "Server01"
# Description: This function connects to a remote computer's Security event log and retrieves failed login attempts (Event ID 4625) from the last 12 hours. 

Function Get-BadLogins {
    Param(
        [string]$Hostname
    )

    Try{Get-WinEvent -ComputerName $Hostname -FilterHashtable @{LogName = 'Security';Id = 4625;StartTime = (Get-Date).AddHours( -12) } -ErrorAction SilentlyContinue | 
        Select-Object TimeCreated,@{n='Target Username';e={$_.Properties[5].value}},@{n='Target Domain Name';e={$_.Properties[6].Value}}}
    Finally {read-host "Press enter to Exit"}
}
