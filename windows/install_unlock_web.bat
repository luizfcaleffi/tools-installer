@echo off
:: ============================================================
:: install_unlock_web.bat — Instalacao do xOne Agent (Windows)
:: Baixa o .exe do GitHub Releases e instala silenciosamente
:: Deploy via GPO startup script
:: ============================================================

set "VERSION=2.6.1"
set "LOCAL_PATH=C:\temp\xone"
set "EXE_NAME=unlockusert-setup-%VERSION%-x64.exe"
set "RELEASE_URL=https://github.com/luizfcaleffi/tools-installer/releases/download/v%VERSION%"

set "TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbiI6IjUxYmYxOTc1LWYxYTAtNGM4OC1iMDhiLTdkNTA2ZjZlMWZmMSIsImNvbXBhbnlfaWQiOjI0MCwiZGF0ZSI6IjIwMjYtMDEtMjBUMTI6MDQ6NDIuMTUzWiIsImlhdCI6MTc2ODkxMDY4Mn0.Fl41RP01qcue4r41rXnDhbKbGArWp_CqyfJDrXVXJr1K8ANs_u854vIMANRN_DjnfsYBdTW44UBP3scsqVyQzcyN2z_GeP-ZzVzdpCWIap4obhur5cQjsyyvUdm-dMbUvUoPasNHCo5ftirkyffuIBBA_b9HNG_-M-Af-VyXOJ3Yoq3iNETwcj2qpq1jJMPrbdVNgauUkaRwcJbaLW661tBA_adzeJTCVU_68LYRdxB7-WoS9jn1K7JcBUuaoRFKHcOY8tvKqYrb8ZpHJU4sJzpLj2AEOGaTOE3TTw5c5bho6mE8jsJpkoqit28cy5PixPZtEFNydN47CoczFWa27g"

:: 1. Cria a pasta local se nao existir
if not exist "%LOCAL_PATH%" mkdir "%LOCAL_PATH%"

:: 2. Baixa o instalador do GitHub Releases
curl -L "%RELEASE_URL%/%EXE_NAME%" -o "%LOCAL_PATH%\%EXE_NAME%"

:: 3. Executa a instalacao silenciosa com token
cd /d "%LOCAL_PATH%"
start /wait "" "%EXE_NAME%" /VERYSILENT /SILENT /SUPPRESSMSGBOXES /LOG="%LOCAL_PATH%\install.log" /TOKEN=%TOKEN%

:: 4. Limpeza — remove o instalador (140MB)
del "%LOCAL_PATH%\%EXE_NAME%" /Q

:EOF
exit
