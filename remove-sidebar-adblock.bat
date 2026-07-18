@echo off
setlocal EnableExtensions
title Remove Sidebar Adblock

:: ---- Self-elevate to Administrator if not already running as admin ----
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting Administrator privileges, please click Yes...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ---- Determine the folder containing this .bat file (this is %%app%%) ----
set "APP_DIR=%~dp0"
if "%APP_DIR:~-1%"=="\" set "APP_DIR=%APP_DIR:~0,-1%"

set "INI_FILE=%APP_DIR%\chrome++.ini"

if not exist "%INI_FILE%" (
    echo [ERROR] chrome++.ini not found at:
    echo       %INI_FILE%
    pause
    exit /b 1
)

:: ---- Generate a temp PowerShell script to read data_dir and resolve full path ----
set "PS1=%TEMP%\ad-block-getpath.ps1"

> "%PS1%" echo param(
>>"%PS1%" echo     [string]$AppDir,
>>"%PS1%" echo     [string]$IniFile
>>"%PS1%" echo ^)
>>"%PS1%" echo $lines = Get-Content -Path $IniFile
>>"%PS1%" echo $value = $null
>>"%PS1%" echo foreach ($line in $lines) {
>>"%PS1%" echo     $t = $line.Trim()
>>"%PS1%" echo     if ($t.ToLower().StartsWith('data_dir')) {
>>"%PS1%" echo         $idx = $t.IndexOf('=')
>>"%PS1%" echo         if ($idx -ge 0) {
>>"%PS1%" echo             $value = $t.Substring($idx + 1).Trim()
>>"%PS1%" echo         }
>>"%PS1%" echo         break
>>"%PS1%" echo     }
>>"%PS1%" echo }
>>"%PS1%" echo if (-not $value) { exit 1 }
>>"%PS1%" echo $value = $value.Replace('%%app%%', $AppDir)
>>"%PS1%" echo $resolved = [System.IO.Path]::GetFullPath($value)
>>"%PS1%" echo Write-Output $resolved

set "DATA_DIR="
for /f "usebackq delims=" %%D in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -AppDir "%APP_DIR%" -IniFile "%INI_FILE%"`) do set "DATA_DIR=%%D"

del /F /Q "%PS1%" >nul 2>&1

if "%DATA_DIR%"=="" (
    echo [ERROR] Could not read the data_dir line from chrome++.ini
    pause
    exit /b 1
)

set "SIDEBAR_DIR=%DATA_DIR%\Default\Sidebar"
set "TARGET_FILE=%SIDEBAR_DIR%\Ad Icons"

:MENU
cls
echo ================================================================
echo                    Remove Sidebar Adblock
echo ================================================================
echo ----------------------------------------------------------------
echo  1. Lock "Ad Icons" file    (block ad icons)
echo  2. Unlock "Ad Icons" file
echo  3. Exit
echo ----------------------------------------------------------------
set "CHOICE="
set /p "CHOICE=Choose (1/2/3): "

if "%CHOICE%"=="1" goto LOCK
if "%CHOICE%"=="2" goto UNLOCK
if "%CHOICE%"=="3" exit /b 0
goto MENU

:LOCK
:: Unlock the Sidebar folder first in case it was locked by a previous run,
:: otherwise creating/recreating the file inside it will fail with Access Denied.
if exist "%SIDEBAR_DIR%" (
    takeown /F "%SIDEBAR_DIR%" >nul 2>&1
    icacls "%SIDEBAR_DIR%" /reset >nul 2>&1
) else (
    mkdir "%SIDEBAR_DIR%" >nul 2>&1
)

if exist "%TARGET_FILE%" (
    takeown /F "%TARGET_FILE%" >nul 2>&1
    icacls "%TARGET_FILE%" /reset >nul 2>&1
    attrib -R -S -H "%TARGET_FILE%" >nul 2>&1
    del /F /Q "%TARGET_FILE%" >nul 2>&1
)

type nul > "%TARGET_FILE%" 2>nul

:: ---- Set attributes BEFORE locking the ACL (doing it after fails with Access Denied) ----
attrib +R +S +H "%TARGET_FILE%" >nul 2>&1

:: ---- Lock the Ad Icons file itself ----
icacls "%TARGET_FILE%" /inheritance:r >nul 2>&1
icacls "%TARGET_FILE%" /grant:r *S-1-1-0:(RX) >nul 2>&1
icacls "%TARGET_FILE%" /deny *S-1-1-0:(W,D,WDAC,WO) >nul 2>&1
icacls "%TARGET_FILE%" /deny *S-1-5-18:(W,D,WDAC,WO) >nul 2>&1
icacls "%TARGET_FILE%" /deny *S-1-5-32-544:(W,D,WDAC,WO) >nul 2>&1

:: ---- Also lock the Sidebar folder: no new files/folders, no deleting the folder ----
:: (if the whole Sidebar folder gets deleted, the app can recreate an unlocked Ad Icons)
takeown /F "%SIDEBAR_DIR%" >nul 2>&1
icacls "%SIDEBAR_DIR%" /inheritance:r >nul 2>&1
icacls "%SIDEBAR_DIR%" /grant:r *S-1-1-0:(RX) >nul 2>&1
icacls "%SIDEBAR_DIR%" /deny *S-1-1-0:(WD,AD,DE) >nul 2>&1
icacls "%SIDEBAR_DIR%" /deny *S-1-5-18:(WD,AD,DE) >nul 2>&1
icacls "%SIDEBAR_DIR%" /deny *S-1-5-32-544:(WD,AD,DE) >nul 2>&1

echo.
echo [OK] Successfully created and locked the "Ad Icons" file + "Sidebar" folder.
echo.
pause
goto MENU

:UNLOCK
if not exist "%TARGET_FILE%" (
    echo.
    echo The "Ad Icons" file does not exist yet, nothing to unlock.
    echo.
    pause
    goto MENU
)

takeown /F "%TARGET_FILE%" >nul 2>&1
icacls "%TARGET_FILE%" /reset >nul 2>&1
icacls "%TARGET_FILE%" /grant:r *S-1-1-0:(F) >nul 2>&1
attrib -R -S -H "%TARGET_FILE%" >nul 2>&1

if exist "%SIDEBAR_DIR%" (
    takeown /F "%SIDEBAR_DIR%" >nul 2>&1
    icacls "%SIDEBAR_DIR%" /reset >nul 2>&1
    icacls "%SIDEBAR_DIR%" /grant:r *S-1-1-0:(F) >nul 2>&1
)

echo.
echo [OK] Successfully unlocked the "Ad Icons" file and "Sidebar" folder.
echo.
pause
goto MENU
