@echo off
chcp 65001 >nul

:: ==============================================
:: CONFIGURATION SECTION - EDIT THESE VALUES
:: ==============================================
set "app=%~dp0"
set "CHROMIUM_PATH=%app%browser.exe"
set "PROFILE_PATH=%app%..\Data"
set "BROWSER_NAME=Cốc Cốc Portable"
set "BROWSER_ID=CocCocPortable"
set "BROWSER_DESC=Cốc Cốc Portable default browser with custom profile"

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

:: Check if Chromium exists
if not exist "%CHROMIUM_PATH%" (
    echo ERROR: Chromium not found at:
    echo "%CHROMIUM_PATH%"
    pause
    exit /b 1
)

:: Check if profile directory exists
if not exist "%PROFILE_PATH%" (
    echo WARNING: Profile directory doesn't exist:
    echo "%PROFILE_PATH%"
    echo Creating it now...
    mkdir "%PROFILE_PATH%"
)

:: ==============================================
:: REGISTRY CONFIGURATION
:: ==============================================
echo Configuring registry settings...

:: Clean up any existing settings first
reg delete "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%" /f >nul 2>&1
reg delete "HKLM\Software\Classes\%BROWSER_ID%HTML" /f >nul 2>&1
reg delete "HKLM\Software\Classes\%BROWSER_ID%URL" /f >nul 2>&1
:: Clean up RegisteredApplications to remove any old name or ID remnants
reg delete "HKLM\Software\RegisteredApplications" /v "%BROWSER_NAME%" /f >nul 2>&1
reg delete "HKLM\Software\RegisteredApplications" /v "%BROWSER_ID%" /f >nul 2>&1

:: Register browser capabilities
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%" /ve /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\DefaultIcon" /ve /d "\"%CHROMIUM_PATH%\"" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" --user-data-dir=\"%PROFILE_PATH%\" \"%%1\"" /f

:: Register file associations
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML" /ve /d "%BROWSER_NAME% Document" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\DefaultIcon" /ve /d "\"%CHROMIUM_PATH%\"" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" --user-data-dir=\"%PROFILE_PATH%\" \"%%1\"" /f

:: Declare UI properties for File Associations (Required to display name in Windows Settings)
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\Application" /v "ApplicationName" /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\Application" /v "ApplicationIcon" /d "\"%CHROMIUM_PATH%\",0" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\Application" /v "ApplicationDescription" /d "%BROWSER_DESC%" /f

:: Register URL protocols
reg add "HKLM\Software\Classes\%BROWSER_ID%URL" /ve /d "%BROWSER_NAME% URL" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%URL" /v "URL Protocol" /d "" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%URL\DefaultIcon" /ve /d "\"%CHROMIUM_PATH%\"" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%URL\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" --user-data-dir=\"%PROFILE_PATH%\" \"%%1\"" /f

:: Declare UI properties for URL Protocols (Required to display name in Windows Settings)
reg add "HKLM\Software\Classes\%BROWSER_ID%URL\Application" /v "ApplicationName" /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%URL\Application" /v "ApplicationIcon" /d "\"%CHROMIUM_PATH%\",0" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%URL\Application" /v "ApplicationDescription" /d "%BROWSER_DESC%" /f

:: Set capabilities
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities" /v "ApplicationName" /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities" /v "ApplicationDescription" /d "%BROWSER_DESC%" /f
:: Declare Application Icon for Capabilities
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities" /v "ApplicationIcon" /d "\"%CHROMIUM_PATH%\",0" /f

:: File associations
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\FileAssociations" /v ".htm" /d "%BROWSER_ID%HTML" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\FileAssociations" /v ".html" /d "%BROWSER_ID%HTML" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\FileAssociations" /v ".pdf" /d "%BROWSER_ID%HTML" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\FileAssociations" /v ".svg" /d "%BROWSER_ID%HTML" /f

:: URL associations
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\URLAssociations" /v "http" /d "%BROWSER_ID%URL" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\URLAssociations" /v "https" /d "%BROWSER_ID%URL" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\URLAssociations" /v "ftp" /d "%BROWSER_ID%URL" /f

:: Register with Windows
reg add "HKLM\Software\RegisteredApplications" /v "%BROWSER_NAME%" /d "Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities" /f

:: ==============================================
:: ALTERNATE APPROACH FOR DEFAULT BROWSER
:: ==============================================
echo Browser registered successfully!
echo.
echo NOTE: Due to Windows 10/11 security restrictions, automatic default browser
echo setting is not possible through registry. Please follow these steps:
echo.
echo 1. The Windows Settings app will open automatically
echo 2. Go to Apps ^> Default apps
echo 3. Look for "Web browser" section
echo 4. Click on the current default browser
echo 5. Select "%BROWSER_NAME%" from the list
echo.
echo Alternatively, you can:
echo - Right-click on any HTML file
echo - Select "Open with" ^> "Choose another app"
echo - Select "%BROWSER_NAME%" and check "Always use this app"
echo.

:: Try alternative method using assoc command (may work in some cases)
echo Attempting alternative method...
assoc .html=%BROWSER_ID%HTML >nul 2>&1
assoc .htm=%BROWSER_ID%HTML >nul 2>&1
ftype %BROWSER_ID%HTML="%CHROMIUM_PATH%" --user-data-dir="%PROFILE_PATH%" "%%1" >nul 2>&1

:: Remove the problematic lines that cause "Access denied"
:: These lines are commented out because they don't work on Windows 10/11:
:: reg add "HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" /v "ProgId" /d "%BROWSER_ID%URL" /f
:: reg add "HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" /v "ProgId" /d "%BROWSER_ID%URL" /f

:: Open default apps settings for manual configuration
start "" "ms-settings:defaultapps"

:: ==============================================
:: COMPLETION
:: ==============================================
echo.
echo Configuration complete!
echo Your browser has been registered with Windows.
echo Please manually set it as default using the Windows Settings that just opened.
echo.
pause
