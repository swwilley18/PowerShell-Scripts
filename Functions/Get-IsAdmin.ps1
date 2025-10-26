# Get-IsAdmin
# Usage: Get-IsAdmin
# Description: This function checks if the current PowerShell session is running with elevated administrator privileges. 
#              If not, it prompts the user to run the script as an administrator and exits the script.
# Useful for scripts that require admin rights to execute certain commands or access specific system resources.

function get-IsAdmin {

    # get current Windows Identity
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    # create Windows Principal object
    $prp = new-object System.Security.Principal.WindowsPrincipal($wid)
    
    # define the Administrator role
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    
    # check if the current principal has Administrator role
    $IsAdmin = $prp.IsInRole($adm)
    if ( ! $IsAdmin ) {
        write-host "You must Run-As administrator when running this script"
        exit 1
    }
}