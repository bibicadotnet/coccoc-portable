@echo off
setlocal
echo CocCoc Portable Updater v1.0
echo ================================
echo.

(
echo # CocCoc Updater
echo $ErrorActionPreference = "Stop"
echo $currentDir = "%~dp0"
echo $coccocPath = Join-Path $currentDir "browser.exe"
echo $apiUrl = "https://api.github.com/repos/bibicadotnet/coccoc-portable/releases"
echo $tempDir = Join-Path $env:TEMP "CocCocUpdate"
echo.
echo try {
echo    $currentVersion = if ^(Test-Path $coccocPath^) { ^(Get-Item $coccocPath^).VersionInfo.ProductVersion } else { "Not installed" }
echo    $allReleases = Invoke-RestMethod -Uri $apiUrl
echo    $channelReleases = $allReleases ^| Where-Object { $_.tag_name -like "coccoc-portable-x64_*" }
echo    $latestRelease = $channelReleases ^| Sort-Object { if ^($_.tag_name -match "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)"^) { [System.Version]$matches[1] } else { [System.Version]"0.0.0.0" } } -Descending ^| Select-Object -First 1
echo    $latestVersion = ^($latestRelease.tag_name -split "_"^)^[1^]
echo    $downloadUrl = $latestRelease.assets^[0^].browser_download_url
echo.
echo    Write-Host "Current version: $currentVersion" -ForegroundColor Yellow
echo    Write-Host "Latest version: $latestVersion" -ForegroundColor Yellow
echo.
echo    $confirm = Read-Host "Do you want to update? (y/N)"
echo    if ^($confirm -ne 'y' -and $confirm -ne 'Y'^) { exit }
echo.
echo    if ^(Test-Path $coccocPath^) {
echo      Write-Host "Stopping processes..."
echo      Stop-Process -Name browser,CocCocUpdate,CocCocCrashHandler -Force -ErrorAction SilentlyContinue
echo      Start-Sleep 2
echo    }
echo.
echo    if ^(Test-Path $tempDir^) { Remove-Item $tempDir -Recurse -Force }
echo    New-Item -ItemType Directory -Path $tempDir -Force ^| Out-Null
echo    $zipFile = Join-Path $tempDir "update.zip"
echo.
echo    Write-Host "Downloading update..."
echo    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
echo.
echo    Write-Host "Extracting..."
echo    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
echo.
echo    $extractedDir = Get-ChildItem $tempDir -Recurse -Directory ^| Where-Object { $_.Name -eq "CocCoc" } ^| Select-Object -First 1
echo.
echo    Write-Host "Updating files..."
echo    # Sửa lỗi xóa nhầm file hệ thống bằng cách trỏ chính xác vào $currentDir
echo    if ^(Test-Path ^(Join-Path $currentDir "browser.exe"^)^) { Remove-Item ^(Join-Path $currentDir "browser.exe"^) -Force }
echo    if ^(Test-Path ^(Join-Path $currentDir "version.dll"^)^) { Remove-Item ^(Join-Path $currentDir "version.dll"^) -Force }
echo    if ^(Test-Path ^(Join-Path $currentDir $currentVersion^)^) { Remove-Item ^(Join-Path $currentDir $currentVersion^) -Recurse -Force }
echo.
echo    Get-ChildItem $extractedDir.FullName -Recurse ^| ForEach-Object {
echo      $relativePath = $_.FullName.Substring^($extractedDir.FullName.Length + 1^)
echo      $destPath = Join-Path $currentDir $relativePath
echo      if ^($_.PSIsContainer^) {
echo        if ^(-not ^(Test-Path $destPath^)^) { New-Item -ItemType Directory -Path $destPath -Force ^| Out-Null }
echo      } else {
echo        $protectedFiles = @^("chrome++.ini","debloat.reg","default-apps-multi-profile.bat"^)
echo        if ^($_.Name -in $protectedFiles -and ^(Test-Path $destPath^)^) {
echo          Write-Host "Skipping: " $_.Name
echo        } else {
echo          $destFolder = Split-Path $destPath -Parent
echo          if ^(-not ^(Test-Path $destFolder^)^) { New-Item -ItemType Directory -Path $destFolder -Force ^| Out-Null }
echo          Copy-Item $_.FullName -Destination $destPath -Force
echo        }
echo      }
echo    }
echo.
echo    Remove-Item $tempDir -Recurse -Force
echo    $newCurrentVersion = if ^(Test-Path $coccocPath^) { ^(Get-Item $coccocPath^).VersionInfo.ProductVersion } else { "Not installed" }
echo    Write-Host "Update completed! Version: $newCurrentVersion" -ForegroundColor Green
echo.
echo } catch {
echo    Write-Host "Error: $_" -ForegroundColor Red
echo }
echo.
echo Read-Host "Press Enter to exit"
) > "%TEMP%\coccoc_update.ps1"

powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\coccoc_update.ps1"
del "%TEMP%\coccoc_update.ps1" 2>nul
pause
