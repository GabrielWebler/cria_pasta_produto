@echo off
setlocal enabledelayedexpansion enableextensions
ECHO.
ECHO.
ECHO.
ECHO                +=============================================+
ECHO                +           DOMINIO DOMINIO.LOCAL             +
ECHO                +                S E T O R                    +
ECHO                +              L E M B R E - S E              +
ECHO                + EXECUTE O SCRIPT COM BOTAO DIREITO DO MOUSE +
ECHO                + CLIQUE NA OPCAO EXECUTAR COMO ADMINISTRADOR +
ECHO                +                                             +
ECHO                +  CASO CONTRARIO O SCRIPT NAO IRA FUNCIONAR  +
ECHO                +                                             +
ECHO                +=============================================+
ECHO.
ECHO.
pause
cls
ECHO.
ECHO.
ECHO.
ECHO                +=============================================+
ECHO                +           DOMINIO DOMINIO.LOCAL             +
ECHO                +                S E T O R                    +
ECHO                + ESCOLHA UMA OPCAO PARA INGRESSAR NO DOMINIO +
ECHO                +                                             +
ECHO                + 1) ESTACOES DE TRABALHO                     +
ECHO                + 2) SERVIDORES                               +
ECHO                +                                             +
ECHO                +=============================================+
ECHO.
set /p verif="INFORME A ESCOLHA: "

	if %verif%==1 goto pc
	if %verif%==2 goto srv

:pc
powershell.exe -noprofile -executionpolicy bypass -file "C:\setor\add-pc-domain.ps1"
PAUSE
CLS
GoTo end

:srv
powershell.exe -noprofile -executionpolicy bypass -file "C:\setor\add-srv-domain.ps1"
PAUSE
CLS
:end
ECHO.
ECHO.
ECHO ############################################################
ECHO #                                                          #
ECHO #     NAO ESQUECA DE APAGAR OS SCRIPTS DA RAIZ DO C:       #
ECHO #                                                          #
ECHO # A maquina esta no dominio, deseja reiniciar agora? (s/n) #
ECHO #                                                          #
ECHO ############################################################
set /p vsh=": "
ECHO.
	if "!vsh!"=="S" goto rein
	if "!vsh!"=="N" goto nop
	if "!vsh!"=="s" goto rein
	if "!vsh!"=="n" goto nop

:nop
exit

:rein
shutdown /r /f /t 00