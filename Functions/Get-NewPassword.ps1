# Get-NewPassword
# Usage: Get-NewPassword
# Description: Prompts the user to enter and confirm a new password, ensuring they match.
# If the passwords match, it stores the password in the global variable $Script:Pass.
# If they do not match, it prompts the user to try again.

function Get-NewPassword {

    # Prompt user for new password and confirmation
    $newPassword = Read-Host "Enter your new password" -AsSecureString
    $confirmPassword = Read-Host "Confirm your new password" -AsSecureString

    # Convert secure strings to plain text
    $Script:Pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword))
    $confirmPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword))
    
    # Check if passwords match
    if ($Pass -ceq $confirmPasswordText) {
        Write-host "Passwords Match"
    } else {
        Write-Host "Password does not match. Please try again."
    }
}