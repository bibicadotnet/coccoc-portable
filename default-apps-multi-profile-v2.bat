@echo off
chcp 65001 >nul

:: ==============================================
:: CONFIGURATION SECTION - EDIT THESE VALUES
:: ==============================================
set "app=%~dp0"
set "CHROMIUM_PATH=%app%browser.exe"
set "BROWSER_NAME=Cốc Cốc Portable"
set "BROWSER_ID=CocCocPortable"
set "BROWSER_DESC=Cốc Cốc Portable default browser with custom profile"
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

:: Check if Chromium exists
if not exist "%CHROMIUM_PATH%" (
    echo ERROR: Chromium not found at:
    echo "%CHROMIUM_PATH%"
    pause
    exit /b 1
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
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" \"%%1\"" /f

:: Register file associations
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML" /ve /d "%BROWSER_NAME% Document" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\DefaultIcon" /ve /d "\"%CHROMIUM_PATH%\"" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" \"%%1\"" /f

:: Declare UI properties for File Associations (Required to display name in Windows Settings)
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\Application" /v "ApplicationName" /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\Application" /v "ApplicationIcon" /d "\"%CHROMIUM_PATH%\",0" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%HTML\Application" /v "ApplicationDescription" /d "%BROWSER_DESC%" /f

:: Register URL protocols
reg add "HKLM\Software\Classes\%BROWSER_ID%URL" /ve /d "%BROWSER_NAME% URL" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%URL" /v "URL Protocol" /d "" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%URL\DefaultIcon" /ve /d "\"%CHROMIUM_PATH%\"" /f
reg add "HKLM\Software\Classes\%BROWSER_ID%URL\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" \"%%1\"" /f

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

:: URL associations
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\URLAssociations" /v "http" /d "%BROWSER_ID%URL" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities\URLAssociations" /v "https" /d "%BROWSER_ID%URL" /f

:: Register with Windows
reg add "HKLM\Software\RegisteredApplications" /v "%BROWSER_NAME%" /d "Software\Clients\StartMenuInternet\%BROWSER_ID%\Capabilities" /f

:: ==============================================
:: TELL WINDOWS SOMETHING CHANGED
:: ==============================================
echo Notifying Windows that associations changed...
powershell -NoProfile -Command ^
  "$sig = '[DllImport(\"shell32.dll\")] public static extern void SHChangeNotify(int e, int f, IntPtr i1, IntPtr i2);';" ^
  "Add-Type -MemberDefinition $sig -Namespace Win32 -Name Shell;" ^
  "[Win32.Shell]::SHChangeNotify(0x8000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)"

:: ==============================================
:: CATCH LINKS WINDOWS OPENS IN EDGE ON PURPOSE
:: ==============================================
echo Setting up native guard for msedge.exe...

(
echo using System;
echo using System.Diagnostics;
echo using System.Linq;
echo using System.Text.RegularExpressions;
echo class Program {
echo     static void Main(string[] args^) {
echo         string browser = @"%CHROMIUM_PATH%";
echo         string edge = @"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe";
echo         if (args.Length == 0^) return;
echo         string rawCMD = string.Join(" ", args^);
echo         bool isInternal = args.Any(a =^> a.Contains("--type="^) ^|^| a.Contains("--no-startup-window"^)^);
echo         if (isInternal^) {
echo             Process.Start(edge, rawCMD^);
echo             return;
echo         }
echo         if (rawCMD.Contains("--default-search-provider="^) ^|^| rawCMD.Contains("--win-session-start"^)^) {
echo             Process.Start(edge, rawCMD^);
echo             return;
echo         }
echo         if (rawCMD.Contains(".pdf"^)^) {
echo             string pdfPath = rawCMD.Replace("--single-argument ", ""^).Trim('\u0022', ' '^);
echo             if (System.IO.File.Exists(pdfPath^)^) {
echo                 Process.Start(new ProcessStartInfo { FileName = pdfPath, UseShellExecute = true }^);
echo                 return;
echo             }
echo         }
echo         if (rawCMD.Contains("microsoft-edge:"^) ^|^| rawCMD.Contains("?url="^) ^|^| rawCMD.Contains("&url="^)^) {
echo             string decodedUrl = DecodeMicrosoftEdgeUri(rawCMD^);
echo             if (!string.IsNullOrEmpty(decodedUrl^)^) {
echo                 if (decodedUrl.Contains("bing.com/spotlight?spotlightid="^)^) {
echo                     decodedUrl = Regex.Replace(decodedUrl, @"(?i)spotlight\?spotlightid=[^&]+&", "search?"^);
echo                 }
echo                 if (IsSafeUrl(decodedUrl^)^) {
echo                     Process.Start(browser, "\"" + decodedUrl + "\""^);
echo                     return;
echo                 }
echo             }
echo         }
echo         string legacyUrl = Regex.Replace(rawCMD, @"(?i)(.*) microsoft-edge:[\/]*", ""^);
echo         legacyUrl = legacyUrl.Replace("?url=", ""^);
echo         if (legacyUrl.Contains("%%2F"^)^) legacyUrl = Uri.UnescapeDataString(legacyUrl^);
echo         legacyUrl = legacyUrl.Trim('\u0022', ' '^);
echo         if (IsSafeUrl(legacyUrl^)^) {
echo             Process.Start(browser, "\"" + legacyUrl + "\""^);
echo         } else {
echo             Process.Start(browser, rawCMD^);
echo         }
echo     }
echo     static string DecodeMicrosoftEdgeUri(string cmdLine^) {
echo         string s = cmdLine.Replace("--single-argument ", "Method=Undefined&"^);
echo         s = s.Replace("--edge-redirect", "Method"^);
echo         if (s.Contains("?url="^) ^|^| s.Contains("&url="^)^) {
echo             s = Regex.Replace(s, @"(?i)microsoft-edge:\??[\/]*", "&"^);
echo         } else {
echo             s = Regex.Replace(s, @"(?i)microsoft-edge:\??[\/]*", "&url="^);
echo         }
echo         s = s.Replace("?url", "url"^).Replace("&&", "&"^);
echo         if (s.Contains("url=--"^)^) {
echo             var idx = s.IndexOf("url="^);
echo             if (idx ^>= 0^) s = s.Substring(0, idx^).TrimEnd('^&'^);
echo         }
echo         var pairs = s.Split('^&'^);
echo         foreach (var pair in pairs^) {
echo             var parts = pair.Split('='^);
echo             if (parts.Length ^>= 2^) {
echo                 string key = parts[0];
echo                 string val = string.Join("=", parts.Skip(1^)^);
echo                 if (key == "url"^) {
echo                     if (val.Contains("%%2F"^)^) val = Uri.UnescapeDataString(val^);
echo                     return val;
echo                 }
echo             }
echo         }
echo         return null;
echo     }
echo     static bool IsSafeUrl(string url^) {
echo         Uri uri;
echo         if (Uri.TryCreate(url, UriKind.Absolute, out uri^)^) {
echo             return uri.Scheme == "http" ^|^| uri.Scheme == "https";
echo         }
echo         return false;
echo     }
echo }
) > "%CS_FILE%"

for /f "delims=" %%i in ('dir /b /s C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe') do set "CSC=%%i"
"%CSC%" /nologo /target:winexe /out:"%EXE_FILE%" "%CS_FILE%"
del "%CS_FILE%"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe" /v "Debugger" /d "\"%EXE_FILE%\"" /f

:: ==============================================
:: DONE - OPEN SETTINGS TO PICK DEFAULT BROWSER
:: ==============================================
echo Browser registered successfully!
echo.
echo Support links in Settings will now open in %BROWSER_NAME%.
echo.
echo Opening Settings - find "%BROWSER_NAME%" under Default apps and select it.
echo.
start "" "ms-settings:defaultapps"
pause