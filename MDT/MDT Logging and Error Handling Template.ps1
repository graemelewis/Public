<#
This script creates a log file in C:\MININT\SMSOSD\OSDLOGS based
on the PS script name and logs each Write-Output line to it.
The log gets copied up to the WDS\MDT server when the TS finishes.

It tries to action the PS in the "try" section and if that fails 
goes to the "catch" section which sets the Exit code to 1 (Failure).
The "finally" section adds to the log if successful or not and 
returns the Exit code back to the TS when finished. 

Save the script to your deployment share Scripts folder and 
to run, create a new command line task. For example:

Powershell.exe -ExecutionPolicy ByPass -File "%SCRIPTROOT%\Name of your script.ps1" 

Created by Graeme Lewis

Credit: https://deploymentresearch.com/Research/Post/318/Using-PowerShell-scripts-with-MDT-2013

#>

# Determine where to do the logging 
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
$logPath = $tsenv.Value("LogPath") 
$logFile = "$logPath\$($myInvocation.MyCommand).log"
 
# Start the logging 
Start-Transcript $logFile
Write-Output "Logging to $logFile"

# Set initial variables
Write-Output "`r`nSet Initial Variables"
Write-Output "Exitcode = 0"
$Exitcode = 0
Write-Output "Profile = Get-NetConnectionProfile"
$Profile = Get-NetConnectionProfile

#Main code
try
{
    Write-Output "`r`nSet-NetConnectionProfile -InputObject Profile -NetworkCategory Private"
    Set-NetConnectionProfile -InputObject $Profile -NetworkCategory "Private"
}
catch
{
    Write-Output "`r`nFailure: Exitcode = 1"
    $Exitcode = 1
}
finally
{
    Write-Output "`r`nFinished"
    If ($Exitcode -eq 0){
        Write-Output "Script successful: Exitcode = $Exitcode"
	}
    Else {
        Write-Output "Script Failed: Exitcode = $Exitcode"
    }
    Write-Output "Exit Exitcode"
	Stop-Transcript
    Exit $Exitcode
}
