@echo off
SETLOCAL ENABLEEXTENSIONS
set LOGFILE=C:\logs\maintenance_log.txt
set LOGDIR=%~dp0logs
set DATESTAMP=%DATE%_%TIME%


REM Check if the log directory exists, and if not, create it
if not exist %LOGDIR% (
    echo Creating log directory...
    mkdir %LOGDIR%
)

echo [%DATESTAMP%] Maintenance script started. > %LOGFILE%
echo Maintenance script started at %DATESTAMP%.

REM Check for administrative privileges
echo Checking for administrative privileges...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrative privileges confirmed.
) else (
    echo This script requires administrative privileges. Exiting.
    goto :EOF
)

REM Check Critical Services
echo Checking critical services...
sc query wuauserv >> %LOGFILE% 2>&1
sc query sppsvc >> %LOGFILE% 2>&1
echo [%DATESTAMP%] Critical services status logged. >> %LOGFILE%


REM Prompt for hardware diagnostics
echo Do you want to run hardware diagnostics? (Y/N, default is N)
set /p RUNHWDIAG=Type Y or N and press Enter (default is N): 
if "%RUNHWDIAG%"=="" set RUNHWDIAG=N
if /I "%RUNHWDIAG%" EQU "Y" (
    echo Running hardware diagnostics...
    msdt.exe /id PerformanceDiagnostic >> %LOGFILE% 2>&1
    msdt.exe /id MaintenanceDiagnostic >> %LOGFILE% 2>&1
    echo [%DATESTAMP%] Hardware diagnostics completed. >> %LOGFILE%
) else (
    echo Skipping hardware diagnostics.
    echo [%DATESTAMP%] Skipped hardware diagnostics by user. >> %LOGFILE%
)


REM Prompt for deleting temp files
echo Prompting for deletion of temporary files...
echo Do you want to delete temporary files? (Y/N, default is N)
set /p DELTEMP=Type Y or N and press Enter (default is N): 
if "%DELTEMP%"=="" set DELTEMP=N
if /I "%DELTEMP%" EQU "Y" (
    echo [%DATESTAMP%] Deleting temporary files... >> %LOGFILE%
    echo Deleting temporary files...
    del /q/f/s %TEMP%\* >> %LOGFILE% 2>&1
    echo Temporary files deleted.
    echo [%DATESTAMP%] Temporary files deleted. >> %LOGFILE%
) else (
    echo Skipping deletion of temporary files.
    echo [%DATESTAMP%] Skipped deletion of temporary files. >> %LOGFILE%
)


REM Run DISM commands
echo [%DATESTAMP%] Running DISM operations... >> %LOGFILE%


echo DISM Health Check...
DISM /Online /Cleanup-Image /CheckHealth >> %LOGFILE% 2>&1
echo Health check completed. Check %LOGFILE% for details.

echo DISM Health Scanner...
DISM /Online /Cleanup-Image /ScanHealth >> %LOGFILE% 2>&1
echo Health scan completed. Check %LOGFILE% for details.

echo DISM StartComponentCleanup...
DISM /online /Cleanup-Image /StartComponentCleanup >> %LOGFILE% 2>&1
echo StartComponentCleanup completed. Check %LOGFILE% for details.

REM Prompt for optional ResetBase
echo Do you want to run DISM ResetBase? (Y/N, default is N)
set /p DISMRESET=Type Y or N and press Enter (default is N): 
if "%DISMRESET%"=="" set DISMRESET=N
if /I "%DISMRESET%" EQU "Y" (
    echo Running StartComponentCleanup with ResetBase...
    echo [%DATESTAMP%] Running DISM StartComponentCleanup with ResetBase... >> %LOGFILE%
    DISM /online /Cleanup-Image /StartComponentCleanup /ResetBase >> %LOGFILE% 2>&1
    if errorlevel 1 (
        echo DISM StartComponentCleanup with ResetBase failed. Check %LOGFILE% for details. >> %LOGFILE%
        echo DISM StartComponentCleanup with ResetBase failed. Continuing script...
    ) else (
        echo DISM StartComponentCleanup with ResetBase completed successfully. >> %LOGFILE%
        echo StartComponentCleanup with ResetBase completed successfully.
    )
) else (
    echo Skipping StartComponentCleanup with ResetBase.
    echo [%DATESTAMP%] DISM StartComponentCleanup with ResetBase skipped by user. >> %LOGFILE%
)

echo Restoring health...
DISM /Online /Cleanup-Image /RestoreHealth >> %LOGFILE% 2>&1
if errorlevel 1 (
    echo DISM RestoreHealth failed. Check %LOGFILE% for details. >> %LOGFILE%
    echo DISM RestoreHealth failed. Continuing script...
) else (
    echo RestoreHealth completed successfully. >> %LOGFILE%
    echo RestoreHealth completed successfully.
)


REM Schedule Check Disk on reboot
if not exist C:\logs\chkdsk_scheduled.flag (
    echo Scheduling Check Disk on next reboot...
    echo [%DATESTAMP%] Scheduling Check Disk on next reboot... >> %LOGFILE%
    echo y | chkdsk /r >> %LOGFILE% 2>&1
    echo > C:\logs\chkdsk_scheduled.flag
) else (
    echo Check Disk already scheduled. Skipping.
    echo [%DATESTAMP%] Check Disk already scheduled. Skipping. >> %LOGFILE%
)

REM Resetting Network Components
echo Resetting network components...
echo [%DATESTAMP%] Resetting Winsocket... >> %LOGFILE%
netsh winsock reset >> %LOGFILE% 2>&1
echo [%DATESTAMP%] Resetting IP stack... >> %LOGFILE%
netsh int ip reset >> %LOGFILE% 2>&1
ipconfig /flushdns >> %LOGFILE% 2>&1
ipconfig /registerdns >> %LOGFILE% 2>&1
ipconfig /release >> %LOGFILE% 2>&1
ipconfig /renew >> %LOGFILE% 2>&1
echo [%DATESTAMP%] Network components reset completed. >> %LOGFILE%

REM Prompt for clearing event logs
if not exist C:\logs\event_logs_cleared.flag (
    echo Do you want to clear Windows Event Logs? (Y/N, default is N)
    set /p CLEAREVENTS=Type Y or N and press Enter (default is N): 
    if "%CLEAREVENTS%"=="" set CLEAREVENTS=N
    if /I "%CLEAREVENTS%" EQU "Y" (
        echo Clearing Event Logs...
        echo [%DATESTAMP%] Clearing Event Logs... >> %LOGFILE%
        wevtutil el | for /F "tokens=*" %%G in ('more') DO wevtutil cl "%%G" >> %LOGFILE% 2>&1
        echo Event Logs cleared.
        echo [%DATESTAMP%] Event Logs cleared. >> %LOGFILE%
        echo > C:\logs\event_logs_cleared.flag
    ) else (
        echo Skipping Event Log clearance.
        echo [%DATESTAMP%] Event Log clearance skipped by user. >> %LOGFILE%
    )
) else (
    echo Event Logs already cleared. Skipping.
    echo [%DATESTAMP%] Event Logs already cleared. >> %LOGFILE%
)

REM Check Driver Status
echo Checking driver status...
powershell -Command "Get-WindowsDriver -Online" >> %LOGFILE% 2>&1
echo Driver status logged. >> %LOGFILE%

REM Prompt for Disk Cleanup
echo Do you want to run Disk Cleanup? (Y/N, default is N)
set /p DISKCLEAN=Type Y or N and press Enter (default is N): 
if "%DISKCLEAN%"=="" set DISKCLEAN=N
if /I "%DISKCLEAN%" EQU "Y" (
    echo Running Disk Cleanup...
    echo [%DATESTAMP%] Running Disk Cleanup... >> %LOGFILE%
    cleanmgr /sagerun:1 >> %LOGFILE% 2>&1
    echo Disk Cleanup completed.
    echo [%DATESTAMP%] Disk Cleanup completed. >> %LOGFILE%
) else (
    echo Skipping Disk Cleanup.
    echo [%DATESTAMP%] Disk Cleanup skipped by user. >> %LOGFILE%
)

REM Prompt for system restart
echo Do you want to restart the system to perform scheduled tasks? (Y/N, default is N)
set /p RESTART=Type Y or N and press Enter (default is N): 
if "%RESTART%"=="" set RESTART=N
if /I "%RESTART%" EQU "Y" (
    echo System will restart in 7 seconds to perform scheduled tasks.
    echo [%DATESTAMP%] System will restart in 7 seconds to perform scheduled tasks. >> %LOGFILE%
    shutdown /r /t 7
) else (
    echo Restart skipped. Please reboot manually to complete maintenance tasks.
    echo [%DATESTAMP%] Restart skipped by user. >> %LOGFILE%
)

echo [%DATESTAMP%] Maintenance tasks completed. Check %LOGFILE% and C:\Windows\Logs\DISM\dism.log for details.
ENDLOCAL
pause
