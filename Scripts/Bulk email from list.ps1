<#
.SYNOPSIS
    Sends bulk emails from a CSV file containing email addresses, subjects, and body content using Outlook automation.

.DESCRIPTION
    This script reads a CSV file containing email data and sends individual emails through Microsoft Outlook COM automation.
    The script validates the input file exists before processing and sends emails sequentially to each recipient.

.PARAMETER None
    This script uses hardcoded file paths and does not accept parameters.

.INPUTS
    CSV file with columns: EmailAddress, Subject, Body
    File location: \\{Path to CSV containing Email Addresses}\Email-Values.csv

.OUTPUTS
    Console output indicating successful email transmission for each recipient.

.EXAMPLE
    .\Bulk email from list.ps1
    Reads the CSV file and sends emails to all recipients listed.

.NOTES
    - Requires Microsoft Outlook to be installed and configured
    - CSV file must contain EmailAddress, Subject, and Body columns
    - Script will exit if the input CSV file is not found
    - Creates a new Outlook COM object for each email (inefficient for large lists)

.LINK
    https://docs.microsoft.com/en-us/office/vba/api/outlook.application
#>


#Import-CSV of test values for Subject Line and Body
$inputFile = '\\{Path to CSV containing Email Addresses}\Email-Values.csv'

#Test to verify the Server List Exists
if (!(Test-Path $InputFile)) {
    Write-Error "File ($InputFile) not found. Script is exiting."
    exit
}

#Imports the  CSV file that contains the email addresses, subject lines, and body content
$Contents = Get-Content -Path $inputFile

ForEach ($Content in $Contents) {


    # Create an Outlook application object
    $Outlook = New-Object -ComObject Outlook.Application

    # Create a new mail item
    $Mail = $Outlook.CreateItem(0)

    # Set the recipient, subject, and body of the email
    $Mail.To = "$Content.EmailAddress"
    $Mail.Subject = "$Content.Subject"
    $Mail.Body = "$Content.Body"

    # Send the email
    $Mail.Send()

    Write-Output "Email sent successfully to $($Content.EmailAddress)!"
}