@echo off
setlocal enabledelayedexpansion
title CSDROP

if "%~1"=="" (
    echo.
    echo  CSDROP - C# Auto-Compiler
    echo  -------------------------
    echo  Drag one or more .cs files onto this script to compile.
    echo.
    pause
    exit /b 0
)

echo.
echo  CSDROP - C# Auto-Compiler
echo  -------------------------
echo.

set "COMPILER="
set "MODE="

where csc >nul 2>&1
if %errorlevel%==0 (
    set "COMPILER=csc"
    set "MODE=roslyn"
    echo  [OK] Compiler: csc.exe (Roslyn)
    goto :collect
)

for %%V in (v4.0.30319 v3.5 v2.0.50727) do (
    if exist "%WINDIR%\Microsoft.NET\Framework64\%%V\csc.exe" (
        set "COMPILER=%WINDIR%\Microsoft.NET\Framework64\%%V\csc.exe"
        set "MODE=framework"
        echo  [OK] Compiler: .NET Framework csc.exe (%%V)
        goto :collect
    )
    if exist "%WINDIR%\Microsoft.NET\Framework\%%V\csc.exe" (
        set "COMPILER=%WINDIR%\Microsoft.NET\Framework\%%V\csc.exe"
        set "MODE=framework"
        echo  [OK] Compiler: .NET Framework csc.exe (%%V)
        goto :collect
    )
)

where dotnet >nul 2>&1
if %errorlevel%==0 (
    set "COMPILER=dotnet"
    set "MODE=dotnet"
    echo  [OK] Compiler: dotnet CLI
    goto :collect
)

echo.
echo  [ERROR] No C# compiler found.
echo.
echo  To fix this, install one of the following:
echo    - .NET SDK:       https://dotnet.microsoft.com/download
echo    - Visual Studio:  https://visualstudio.microsoft.com
echo.
pause
exit /b 1

:collect
echo.

set "FILES="
set "OUTNAME="
set "OUTDIR="
set "SKIPPED="
set "FILECOUNT=0"

for %%F in (%*) do (
    if /i "%%~xF"==".cs" (
        set "FILES=!FILES! "%%~F""
        if "!OUTNAME!"=="" (
            set "OUTNAME=%%~nF"
            set "OUTDIR=%%~dpF"
        )
        set /a FILECOUNT+=1
    ) else (
        set "SKIPPED=!SKIPPED! %%~nxF"
    )
)

if defined SKIPPED (
    echo  [WARN] Skipped non-.cs files:!SKIPPED!
    echo.
)

if "!FILES!"=="" (
    echo  [ERROR] No valid .cs files were provided.
    echo.
    echo  Make sure you are dragging .cs files onto this script.
    echo.
    pause
    exit /b 1
)

set "OUTPUT=!OUTDIR!!OUTNAME!.exe"

echo  Files:   !FILECOUNT! .cs file(s)
echo  Output:  !OUTPUT!
echo.
echo  Compiling...
echo.

if "!MODE!"=="dotnet" (
    set "TMPDIR=!OUTDIR!_cstmp_%RANDOM%"
    mkdir "!TMPDIR!" >nul 2>&1

    if errorlevel 1 (
        echo  [ERROR] Could not create temp folder: !TMPDIR!
        echo  Check that you have write access to !OUTDIR!
        echo.
        pause
        exit /b 1
    )

    dotnet new console -n _build --output "!TMPDIR!" --force >nul 2>&1

    if errorlevel 1 (
        echo  [ERROR] Failed to create dotnet project.
        echo  Make sure the .NET SDK is installed correctly.
        rmdir /s /q "!TMPDIR!" >nul 2>&1
        echo.
        pause
        exit /b 1
    )

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
        echo  [ERROR] Compilation failed.
        echo.
        echo  Common causes:
        echo    - Syntax errors in your .cs file
        echo    - Missing using statements
        echo    - Method or class not found
        echo.
        echo  Check the errors printed above for the exact line numbers.
        echo.
        pause
        exit /b 1
    )
) else (
    if "!MODE!"=="roslyn" (
        csc /out:"!OUTPUT!" /optimize+ /nologo !FILES!
    ) else (
        "!COMPILER!" /out:"!OUTPUT!" /optimize+ /nologo !FILES!
    )

    if errorlevel 1 (
        echo.
        echo  [ERROR] Compilation failed.
        echo.
        echo  Common causes:
        echo    - Syntax errors in your .cs file
        echo    - Missing using statements
        echo    - Method or class not found
        echo.
        echo  Check the errors printed above for the exact line numbers.
        echo.
        pause
        exit /b 1
    )
)

if not exist "!OUTPUT!" (
    echo.
    echo  [ERROR] Compilation reported success but no .exe was produced.
    echo  Expected output: !OUTPUT!
    echo.
    echo  This may happen with dotnet CLI on .NET 5+ (outputs a .dll instead).
    echo  Try installing the .NET Framework SDK for classic .exe output.
    echo.
    pause
    exit /b 1
)

echo.
echo  [SUCCESS] Build complete.
echo  Output:   !OUTPUT!
echo.
set /p "DORUN= Run now? (Y/N): "
if /i "!DORUN!"=="Y" (
    echo.
    echo  --- Program Output ---
    echo.
    "!OUTPUT!"
    set "EXITCODE=!errorlevel!"
    echo.
    echo  --- End of Output ---
    echo.
    if !EXITCODE! neq 0 (
        echo  [WARN] Program exited with code !EXITCODE!
        echo.
    )
)

pause
exit /b 0
