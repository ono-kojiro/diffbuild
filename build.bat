@ECHO OFF
@SETLOCAL ENABLEDELAYEDEXPANSION

SET PATH=%SYSTEMROOT%\System32

SET TOP_DIR=%~dp0
CD /D !TOP_DIR!

IF NOT DEFINED BUILD_DIR (
	ECHO ERROR : environment variable BUILD_DIR is not defined.
	EXIT /B 1
)

IF "x%1" == "x" (
	CALL :ALL
	REM disable echo because subroutine might enable echo
	@ECHO OFF
	IF NOT !ERRORLEVEL! == 0 (
		ECHO ERROR : ALL returned !ERRORLEVEL!
		EXIT /B !ERRORLEVEL!
	)
) else (
	FOR %%i IN (%*) DO (
		CALL :_CHECK_LABEL %%i
		IF !ERRORLEVEL! == 0 (
			CALL :%%i %%i
			REM disable echo because subroutine might enable echo
			@ECHO OFF

			IF NOT !ERRORLEVEL! == 0 (
				ECHO ERROR : %%i returned !ERRORLEVEL!
				EXIT /B !ERRORLEVEL!
			)
		) ELSE (
			CALL :_DEFAULT %%i
		)
		
	)
)

@ECHO ON
@EXIT /B !ERRORLEVEL!

REM ===============================
REM === All
REM ===============================
:ALL
CALL :BUILD
@GOTO :EOF

REM ===============================
REM === List-Target
REM ===============================
:LIST-TARGET
PUSHD %BUILD_DIR%
CALL build.bat help
@ECHO OFF
POPD

@GOTO :EOF

REM ===============================
REM === Config
REM ===============================
:CONFIG
PUSHD %BUILD_DIR%
CALL build.bat config
@ECHO OFF
POPD

@GOTO :EOF

REM ===============================
REM === Build
REM ===============================
:BUILD
PUSHD %BUILD_DIR%
CALL build.bat build
@ECHO OFF
POPD
@GOTO :EOF

REM ===============================
REM === Clean
REM ===============================
:CLEAN
PUSHD %BUILD_DIR%
CALL build.bat clean
@ECHO OFF
POPD
@GOTO :EOF

REM ===============================
REM === _DEFAULT
REM ===============================
:_DEFAULT
PUSHD %BUILD_DIR%
CALL build.bat %1
@ECHO OFF
POPD

CALL :UPLOAD %1
@ECHO OFF

@GOTO :EOF

REM ===============================
REM === Upload
REM ===============================
:UPLOAD
PUSHD %BUILD_DIR%
robocopy ^
	%1 ^
	\\192.168.0.93\c$\home\share\cellos_cmake ^
	/E
POPD
@GOTO :EOF


REM ===============================
REM === _CHECK_LABEL
REM ===============================
:_CHECK_LABEL
FINDSTR /I /R /C:"^[ ]*:%1\>" "%~f0" >NUL 2>NUL
@GOTO :EOF
