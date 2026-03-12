@ECHO OFF

SET SCRIPT_NAME=jasypt.bat

IF "%~1" == "" GOTO usage

SET COMMAND=%~1
SHIFT

SET EXECUTABLE_CLASS=
IF /I "%COMMAND%" == "encrypt" SET EXECUTABLE_CLASS=org.jasypt.intf.cli.JasyptPBEStringEncryptionCLI
IF /I "%COMMAND%" == "decrypt" SET EXECUTABLE_CLASS=org.jasypt.intf.cli.JasyptPBEStringDecryptionCLI
IF /I "%COMMAND%" == "encrypt-file" SET EXECUTABLE_CLASS=org.jasypt.intf.cli.JasyptPBEFileTokenEncryptionCLI
IF /I "%COMMAND%" == "decrypt-file" SET EXECUTABLE_CLASS=org.jasypt.intf.cli.JasyptPBEFileTokenDecryptionCLI

IF "%EXECUTABLE_CLASS%" == "" GOTO usage

SET EXEC_ARGS=
:collectargs
IF "%~1" == "" GOTO applyDefaults
SET "CURRENT_ARG=%~1"
ECHO(%CURRENT_ARG%| FINDSTR /c:"=" >nul
IF %ERRORLEVEL% == 0 GOTO appendAsIs
IF "%~2" == "" GOTO appendAsIs
SET EXEC_ARGS=%EXEC_ARGS% %1="%~2"
SHIFT
SHIFT
GOTO collectargs

:appendAsIs
SET EXEC_ARGS=%EXEC_ARGS% %1
SHIFT
GOTO collectargs

:applyDefaults
ECHO(%EXEC_ARGS%| FINDSTR /i /c:"algorithm=" >nul
IF %ERRORLEVEL% neq 0 SET EXEC_ARGS=%EXEC_ARGS% algorithm="PBEWITHHMACSHA512ANDAES_256"

ECHO(%EXEC_ARGS%| FINDSTR /i /c:"keyObtentionIterations=" >nul
IF %ERRORLEVEL% neq 0 SET EXEC_ARGS=%EXEC_ARGS% keyObtentionIterations="1000"

ECHO(%EXEC_ARGS%| FINDSTR /i /c:"saltGeneratorClassName=" >nul
IF %ERRORLEVEL% neq 0 SET EXEC_ARGS=%EXEC_ARGS% saltGeneratorClassName="org.jasypt.salt.RandomSaltGenerator"

ECHO(%EXEC_ARGS%| FINDSTR /i /c:"ivGeneratorClassName=" >nul
IF %ERRORLEVEL% neq 0 SET EXEC_ARGS=%EXEC_ARGS% ivGeneratorClassName="org.jasypt.iv.RandomIvGenerator"

:classpath
SET EXEC_CLASSPATH=.
IF "%JASYPT_CLASSPATH%" == "" GOTO computeclasspath
SET EXEC_CLASSPATH=%EXEC_CLASSPATH%;%JASYPT_CLASSPATH%

:computeclasspath
IF "%OS%" == "Windows_NT" SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%c in (%~dp0..\lib\*.jar) DO SET EXEC_CLASSPATH=!EXEC_CLASSPATH!;%%c
FOR %%c in (%~dp0*.jar) DO set EXEC_CLASSPATH=!EXEC_CLASSPATH!;%%c
IF "%OS%" == "Windows_NT" SETLOCAL DISABLEDELAYEDEXPANSION

SET JAVA_EXECUTABLE=java
IF "%JAVA_HOME%" == "" GOTO execute
SET JAVA_EXECUTABLE="%JAVA_HOME%\bin\java"

:execute
@REM ECHO %JAVA_EXECUTABLE% -classpath %EXEC_CLASSPATH% %EXECUTABLE_CLASS% %SCRIPT_NAME% %EXEC_ARGS%
%JAVA_EXECUTABLE% -classpath %EXEC_CLASSPATH% %EXECUTABLE_CLASS% %SCRIPT_NAME% %EXEC_ARGS%
GOTO end

:usage
ECHO Usage: %SCRIPT_NAME% ^<encrypt^|decrypt^|encrypt-file^|decrypt-file^> [arguments]
ECHO(
ECHO Required arguments:
ECHO ^<encrypt^|decrypt^> [input, password]
ECHO ^<encrypt-file^|decrypt-file^> [filePath, password]
ECHO(
ECHO Optional arguments:
ECHO [verbose, algorithm, keyObtentionIterations, saltGeneratorClassName, providerName, providerClassName, stringOutputType, ivGeneratorClassName, fileCharset]
EXIT /b 1

:end