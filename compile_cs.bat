@echo off
setlocal enabledelayedexpansion
title CSDROP

if "%~1"=="" (
    echo.
    echo ������������������������������������������������ͻ
    echo �  CSDROP // C# AUTO-COMPILER                  �
    echo �  Drag .cs files onto this script to compile   �
    echo ������������������������������������������������ͼ
    echo.
    pause
    exit /b 0
)

echo.
echo ������������������������������������������������ͻ
echo �  CSDROP // C# AUTO-COMPILER                  �
echo ������������������������������������������������ͼ
echo.

set "COMPILER="
set "MODE="

where csc >nul 2>&1
if %errorlevel%==0 (
    set "COMPILER=csc"
    set "MODE=roslyn"
    echo  [COMPILER]  csc.exe (Roslyn)
    goto :build
)

for %%V in (v4.0.30319 v3.5 v2.0.50727) do (
    if exist "%WINDIR%\Microsoft.NET\Framework64\%%V\csc.exe" (
        set "COMPILER=%WINDIR%\Microsoft.NET\Framework64\%%V\csc.exe"
        set "MODE=framework"
        echo  [COMPILER]  .NET Framework csc.exe (%%V)
        goto :build
    )
    if exist "%WINDIR%\Microsoft.NET\Framework\%%V\csc.exe" (
        set "COMPILER=%WINDIR%\Microsoft.NET\Framework\%%V\csc.exe"
        set "MODE=framework"
        echo  [COMPILER]  .NET Framework csc.exe (%%V)
        goto :build
    )
)

where dotnet >nul 2>&1
if %errorlevel%==0 (
    set "COMPILER=dotnet"
    set "MODE=dotnet"
    echo  [COMPILER]  dotnet CLI
    goto :build
)

echo.
echo  [ERROR]  No C# compiler found.
echo.
echo  Install the .NET SDK:  https://dotnet.microsoft.com/download
echo.
pause
exit /b 1

:build
echo.

set "FILES="
set "OUTNAME="
set "OUTDIR="
set "SKIPPED="

for %%F in (%*) do (
    if /i "%%~xF"==".cs" (
        set "FILES=!FILES! "%%~F""
        if "!OUTNAME!"=="" (
            set "OUTNAME=%%~nF"
            set "OUTDIR=%%~dpF"
        )
    ) else (
        set "SKIPPED=!SKIPPED! %%~nxF"
    )
)

if defined SKIPPED (
    echo  [SKIP]    !SKIPPED!
    echo.
)

if "!FILES!"=="" (
    echo  [ERROR]  No valid .cs files provided.
    echo.
    pause
    exit /b 1
)

set "OUTPUT=!OUTDIR!!OUTNAME!.exe"

echo  [INPUT]   !FILES!
echo  [OUTPUT]  !OUTPUT!
echo.
echo  Compiling...
echo.

if "!MODE!"=="dotnet" (
    set "TMPDIR=!OUTDIR!_cstmp_%RANDOM%"
    mkdir "!TMPDIR!" >nul 2>&1
    dotnet new console -n _build --output "!TMPDIR!" --force >nul 2>&1
    del "!TMPDIR!\Program.cs" >nul 2>&1
    for %%F in (%*) do (
        if /i "%%~xF"==".cs" (
            copy /y "%%F" "!TMPDIR!\" >nul 2>&1
        )
    )
    dotnet build "!TMPDIR!" -o "!TMPDIR!\out" --nologo -c Release 2>&1
    set "RESULT=!errorlevel!"
    if !RESULT!==0 (
        copy /y "!TMPDIR!\out\_build.exe" "!OUTPUT!" >nul 2>&1
        if errorlevel 1 (
            for /r "!TMPDIR!\out" %%X in (*.exe) do (
                copy /y "%%X" "!OUTPUT!" >nul 2>&1
            )
        )
    )
    rmdir /s /q "!TMPDIR!" >nul 2>&1
    if !RESULT! neq 0 (
        echo.
        echo  [FAIL]  Compilation failed. See errors above.
        echo.
        pause
        exit /b 1
    )
) else (
    "!COMPILER!" /out:"!OUTPUT!" /optimize+ /nologo !FILES!
    if errorlevel 1 (
        echo.
        echo  [FAIL]  Compilation failed. See errors above.
        echo.
        pause
        exit /b 1
    )
)

echo.
echo ������������������������������������������������ͻ
echo �  SUCCESS                                        �
echo �  !OUTPUT!                                        
echo ������������������������������������������������ͼ
echo.
set /p "DORUN= Run now? (Y/N): "
if /i "!DORUN!"=="Y" (
    echo.
    echo  ������������������������������������������������
    echo.
    "!OUTPUT!"
    echo.
    echo  ������������������������������������������������
    echo.
)

pause
exit /b 0
