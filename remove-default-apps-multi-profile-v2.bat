@echo off
chcp 65001 >nul

:: ==============================================
:: CONFIGURATION SECTION
:: ==============================================
set "app=%~dp0"
set "BROWSER_NAME=Cốc Cốc Portable"
set "BROWSER_ID=CocCocPortable"
set "EXE_FILE=%app%edge-guard.exe"
set "CS_FILE=%app%edge-guard.cs"

:: ==============================================
:: SYSTEM CHECKS
:: ==============================================
:: Check if running as administrator
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs"
    EXIT /B
)

:: ==============================================
:: REGISTRY CLEANUP
:: ==============================================
echo Cleaning up registry settings...

:: Remove Image File Execution Options for msedge.exe
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe" /v "Debugger" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe" /f >nul 2>&1

:: Remove Browser registration
reg delete "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%" /f >nul 2>&1

:: Remove File associations
reg delete "HKLM\Software\Classes\%BROWSER_ID%HTML" /f >nul 2>&1

:: Remove URL protocols
reg delete "HKLM\Software\Classes\%BROWSER_ID%URL" /f >nul 2>&1

:: Remove Registered Applications
reg delete "HKLM\Software\RegisteredApplications" /v "%BROWSER_NAME%" /f >nul 2>&1
reg delete "HKLM\Software\RegisteredApplications" /v "%BROWSER_ID%" /f >nul 2>&1

:: ==============================================
:: FILE CLEANUP
:: ==============================================
echo Cleaning up files...
if exist "%EXE_FILE%" (
    del "%EXE_FILE%"
    echo Deleted "%EXE_FILE%"
)
if exist "%CS_FILE%" (
    del "%CS_FILE%"
    echo Deleted "%CS_FILE%"
)

:: ==============================================
:: TELL WINDOWS SOMETHING CHANGED
:: ==============================================
echo Notifying Windows that associations changed...
powershell -NoProfile -Command ^
  "$sig = '[DllImport(\"shell32.dll\")] public static extern void SHChangeNotify(int e, int f, IntPtr i1, IntPtr i2);';" ^
  "Add-Type -MemberDefinition $sig -Namespace Win32 -Name Shell;" ^
  "[Win32.Shell]::SHChangeNotify(0x8000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)"

echo.
echo Everything created by default-apps-multi-profile-v2.bat has been removed successfully!
echo MS Edge should launch normally now.
echo.
pause
