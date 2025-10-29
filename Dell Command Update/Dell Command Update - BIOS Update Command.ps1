<#
.SYNOPSIS
    Executes Dell Command Update CLI to apply BIOS and firmware updates silently.

.DESCRIPTION
    This script runs the Dell Command Update command-line interface (dcu-cli.exe) to automatically
    apply BIOS and firmware updates for specified device categories. The process runs silently
    without user interaction and automatically reboots the system when updates are complete.

.PARAMETER None
    This script does not accept parameters.

.NOTES
    - Requires Dell Command Update to be installed at the default location
    - Updates are applied for: audio, video, network, storage, input, chipset, and other device categories
    - System will automatically reboot after updates are applied
    - Script runs in silent mode with no user prompts
    - Only BIOS and firmware updates are applied (drivers excluded)

.EXAMPLE
    .\Dell Command Update - BIOS Update Command.ps1
    Runs the script to apply available BIOS and firmware updates silently.

.LINK
    https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update
#>

# Execute Dell Command Update CLI to apply BIOS and firmware updates silently
Start-Process "c:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/applyUpdates -Silent -updateType=bios,firmware -updateDeviceCategory=audio,video,network,storage,input,chipset,others -reboot=Enable"