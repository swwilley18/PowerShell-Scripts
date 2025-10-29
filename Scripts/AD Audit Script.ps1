<#
.SYNOPSIS
    Active Directory Organizational Unit membership audit script that identifies AD groups containing mixed object types.

.DESCRIPTION
    This script audits specified Active Directory Organizational Units (OUs) to identify groups that contain 
    combinations of users, computers, and/or nested groups. It provides an interactive menu to select from 
    5 predefined OUs, generates detailed reports, and flags groups that may need review based on membership criteria.

.PARAMETER None
    This script uses interactive prompts for user input.

.INPUTS
    Interactive user selection (1-6) to choose which OU to audit or exit.

.OUTPUTS
    - CSV report: Contains detailed group membership counts for all groups in selected OU
    - Text report: Contains names of groups that meet flagging criteria 
    - Error log: Contains any errors encountered during processing

.EXAMPLE
    .\AD-Audit-Script.ps1
    
    Runs the script interactively, prompting user to select an OU to audit.

.NOTES
    - Requires Active Directory PowerShell module
    - User must have appropriate permissions to read AD group membership
    - Script validates input and handles errors gracefully
    - Progress bar shows completion status during processing
    - Currently configured to flag groups with users AND computers, or groups with only nested groups
    - Alternative flagging criteria available in commented code

.FUNCTIONALITY
    1. Displays interactive menu for OU selection
    2. Validates user input with error handling
    3. Retrieves all AD groups from selected OU
    4. Counts users, computers, and nested groups for each AD group
    5. Exports raw data to CSV file
    6. Processes data to identify groups meeting review criteria
    7. Exports flagged groups to text file
    8. Creates error log for troubleshooting

.REQUIREMENTS
    - Active Directory PowerShell Module
    - Read permissions on target OUs
    - Write permissions to report destination paths
#>



#Import Active Directory Module
Import-Module ActiveDirectory

#Clears Window
Clear-Host

##VARIABLES##
#Variable for User Prompt
$PromptForNum = "Please enter a number between 1-6 to select which Sub-OU to audit"
$ValidationPrompt = "Please enter a valid number between 1-6."
 


$Filter = '*'

#Options Menu Displayed in Powershell window
write-host "======================== Active Directory Memebrship Audit ================================"
Write-Host ""
write-host "This script checks the selected Sub-OU for User's, Computers, or groups that are contained within a single Active Directory group."
Write-Host ""
write-host "1: Audit {OU 1}"
write-host "2: Audit {OU 2}"
write-host "3: Audit {OU 3}"
write-host "4: Audit {OU 4}"
write-host "5: Audit {OU 5}"
write-host "6: Exit"
Write-Host ""

##Catches the error thrown when entering a letter
Try{
    [int]$OUselection = (Read-Host $PromptForNum)
}
Catch{
    "Invalid Input. $ValidationPrompt" 
    $OUselection = 0
}

#Validates and Cleans user Input
While($OUselection -isnot [int] -or $OUselection -le 0 -or $OUselection -ge 7){
    #Catches Error thrown when entering a letter
    Try{
        if($OUselection -isnot [int] -or $OUselection -le 0 -or $OUselection -ge 7){
            $OUselection = (Read-Host $PromptForNum)
        }
       
    }
    Catch{
        read-host $PromptForNum
    }
}

#  Contains AD Distinguished Names for the selected Sub-OUs
Switch($OUselection)
{
    1 {$SearchBase = '{OU 1 Distinguished Name}'}
    1 {$OU = "{OU 1}"}
    2 {$SearchBase = '{OU 2 Distinguished Name}'}
    2 {$OU = "{OU 2}"}
    3 {$SearchBase = '{OU 3 Distinguished Name}'}
    3 {$OU = "{OU 3}"}
    4 {$SearchBase = '{OU 4 Distinguished Name}'}
    4 {$OU = "{OU 4}"}
    5 {$SearchBase = '{OU 5 Distinguished Name}'}
    5 {$OU = "{OU 5}"}
    6 {Exit}
}

# Path for exporting & Importing the Raw Report
$ReportPath = "{Path to report destination}\$OU-AD-audit.csv"

#Variables for Progress Bar
$AllGroups = Get-ADGroup -Filter $Filter -SearchBase $SearchBase 
$TotalGroups = $AllGroups.Count
$Complete = 0
$PercentComplete = (($complete/$TotalGroups)*100)
$ErrorLog = "{Path to error log}\$OU-AD-Audit-Error log.txt"

# Get all AD groups in specified OU
Get-ADGroup -Filter $Filter -SearchBase $SearchBase |


# Iterate through each AD Group
ForEach-Object {
    Try{
    [pscustomobject]@{
        
            #Display Canonical Group Name
            Name         = $_.name

            #Display User Count in AD group
            Users        = Get-ADGroupMember -identity $_.name | Where-Object { $_.objectclass -eq "user"} | Measure-Object  | Select-Object -ExpandProperty Count

            #Displays Computer count for AD Group 
            Computers    = Get-ADGroupMember -identity $_.name | Where-Object { $_.objectclass -eq "computer"} | Measure-Object | Select-Object -ExpandProperty Count

            #Displays count for Nested Groups
            NestedGroups = Get-ADGroupMember -identity $_.name | Where-Object { $_.objectclass -eq "group"} | Measure-Object | Select-Object -ExpandProperty Count         
      }
      }
      Catch{
        $Errors += "$_.Exception.message `n"
      }

    #Progress Bar
    $complete += 1
    Write-Progress -Activity "Retrieving Groups" -Status "$complete/$totalGroups Completed" -PercentComplete (($complete/$TotalGroups)*100)
   
  # Export to a CSV file to clean the data 
} | export-csv -Path $ReportPath -NoTypeInformation;

Write-Output "$complete Groups Scanned"

#Output Error Log to a txt file
$Errors | Out-file -FilePath $ErrorLog

# Variable for the Output file path of the cleaned report
$ExportPath = "{Path to Final Report Destination}\$OU-AD-audit-Final-Result.txt"

# Imports the CSV file made in the top section
$csvfile = Import-csv $ReportPath

# Initiates a variable to store the AD group name that needs reviewed
[String]$ADGroupName = "" 

#Reset progress Bar counter
$Complete = 0

# Iterate through each row of the original report
$csvfile | ForEach-Object {

# Assign columns to variables
$StrName = $_.Name
$intUser = $_.Users -as [int]
$intComp = $_.Computers -as [int]
$intGrp  = $_.NestedGroups -as [int]



    # This statement checks each row of the report to see if there are a combination of users, groups, and computers in an AD group
    #Uncomment this IF statement and comment out the next one to check for groups, users, and computers in a single AD gorup
    #if(($intUser -gt 0 -and $intComp -gt 0) -or ($intUser -gt 0 -and $intGrp -gt 0) -or ($intComp -gt 0 -and $intGrp -gt 0))

    #This checks if there are users and computers in a single AD group
    if(($intUser -gt 0 -and $intComp -gt 0) -or ($intComp -eq 0 -and $intuser -eq 0 -and $intGrp -gt 0))    
        {
        #If so, add it to the AD Group Name Variable with line break `n
        $ADGroupName += "$StrName `n" 
        }
        #If not, do nothing
}

# ExportGroup names that pass the criteria to a txt file.
$ADGroupName | Out-file -FilePath $ExportPath;

read-host "The script has finished running. Press Enter to Exit"