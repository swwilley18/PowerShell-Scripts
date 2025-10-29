<#
.SYNOPSIS
    Configures Dell Command Update (DCU) client with specific settings for automated system updates.

.DESCRIPTION
    This script configures the Dell Command Update CLI tool with the following settings:
    - Enables advanced driver restore functionality
    - Enables automatic BitLocker suspension during updates
    - Sets maximum retry attempts to 2
    - Schedules weekly downloads with notifications on Tuesdays at 11:00 PM
    - Runs in silent mode
    - Updates multiple device categories including audio, video, network, storage, input, chipset, and others
    - Includes BIOS, firmware, driver, application, and other update types
    - Disables user consent prompts and update notifications
    - Logs configuration output to c:\Temp Files\DCU-Config.log

.NOTES
    - Requires Dell Command Update to be installed on the system
    - Must be run with appropriate administrative privileges
    - The log directory (c:\Temp Files\) must exist or be created prior to execution
    - This configuration is suitable for managed environments where automated updates are desired
#>

# Execute Dell Command Update CLI to configure settings
c:\"Program Files"\Dell\CommandUpdate\dcu-cli.exe /Configure -advancedDriverRestore=Enable -autoSuspendBitLocker=enable -maxRetry=2 -scheduleAction=DownloadAndNotify -scheduleWeekly="Tue,23:00" -silent -updateDeviceCategory="audio,video,network,storage,input,chipset,others" -updateType="bios,firmware,driver,application,others" -userConsent=disable -updatesNotification=disable -outputLog="c:\Temp Files\DCU-Config.log"