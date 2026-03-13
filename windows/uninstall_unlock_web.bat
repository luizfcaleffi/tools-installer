@echo off
:: Caminhos prováveis de instalação
set "P1=C:\Program Files\xOne\unins000.exe"
set "P2=C:\Program Files (x86)\xOne\unins000.exe"

echo Verificando instalacao do xOne...

if exist "%P1%" (
    start /wait "" "%P1%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
) else if exist "%P2%" (
    start /wait "" "%P2%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
)

:: Remove a pasta de logs e arquivos temporários da instalação anterior
rd /s /q "C:\temp\xone" 2>nul

exit