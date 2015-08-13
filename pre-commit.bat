@echo off
setlocal

:: Subversion sends through the path to the repository and transaction id
set REPOS=%1
set TXN=%2

:: Verifica se foi informado alguma mensagem se log para o commit
svnlook log %REPOS% -t %TXN% | findstr . > nul
if %errorlevel% gtr 0 (
	echo. 1>&2
	echo *************************************************** 1>&2
	echo Preencha um comentario para realizar o commit 1>&2
	echo *************************************************** 1>&2
	echo. 1>&2
	exit 1
)

:: Verifica se os arquivos PHP que estão sendo commitados estão com error de sintaxe
for /f "tokens=2" %%i in ('svnlook changed %REPOS% -t %TXN% ^| findstr .php') do (
	echo. 1>&2
	echo ************************************************************** 1>&2
	echo FILE: %%i 1>&2
	for /f  "tokens=*" %%s in ('svnlook cat %REPOS% -t %TXN% %%i ^| C:\xampp\php\php -l ^| findstr "Parse error:"') do ( 
		echo %%s 1>&2	
		echo ************************************************************** 1>&2
		exit 1
	)	
)

:: Verifica log do codesniffer
php C:\xampp\php\scripts\phpcs-svn-pre-commit %REPOS% -t %TXN%  --warning-severity=0 --standard=IW
if %errorlevel% gtr 0 (
	php C:\xampp\php\scripts\phpcs-svn-pre-commit %REPOS% -t %TXN%  --warning-severity=0 --standard=IW >&2
	exit 1
)
exit 0