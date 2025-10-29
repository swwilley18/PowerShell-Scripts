<#
.SYNOPSIS
    Executes Dell Command Update CLI to apply system updates silently with automatic reboot.

.DESCRIPTION
    This command runs the Dell Command Update command-line interface (dcu-cli.exe) to automatically
    download and install available updates for Dell systems. The command is configured to:
    - Run silently without user interaction
    - Apply all update types (firmware, drivers, applications, and others)
    - Update all device categories (audio, video, network, storage, input, chipset, and others)
    - Enable automatic reboot when required
    - Log the update process to a specified file

.PARAMETER updateType
    Specifies the types of updates to apply: firmware, driver, application, others

.PARAMETER updateDeviceCategory
    Specifies device categories to update: audio, video, network, storage, input, chipset, others

.PARAMETER reboot
    Controls reboot behavior - set to Enable for automatic reboot when required

.PARAMETER OutputLog
    Specifies the path where the update log will be written (c:\TempFiles\DCU-Updates.log)

.NOTES
    - Requires Dell Command Update to be installed
    - Must be run with administrative privileges
    - The TempFiles directory must exist or be created before execution
    - System may reboot automatically if updates require it

.EXAMPLE
    This command will silently check for and install all available Dell updates,
    automatically rebooting if necessary and logging results to the specified file.
#>

# Execute Dell Command Update CLI to apply all updates silently with automatic reboot
c:\"Program Files"\Dell\CommandUpdate\dcu-cli.exe /applyUpdates -Silent -updateType="firmware,driver,application,others" -updateDeviceCategory="audio,video,network,storage,input,chipset,others" -reboot=Enable -OutputLog="c:\TempFiles\DCU-Updates.log"
