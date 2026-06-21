@echo off
setlocal enabledelayedexpansion
title CSDROP

if "%~1"=="" (
    echo.
    echo  CSDROP - C# Auto-Compiler
    echo  -------------------------
    echo  Drag one or more .cs files onto this script to compile.
    echo.
    echo  CameronCodesStuff
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
    set "MODE=csc"
    echo  [OK] Compiler: csc.exe ^(Roslyn^)
    goto :collect
)

if exist "%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" (
    set "COMPILER=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    set "MODE=csc"
    echo  [OK] Compiler: .NET Framework csc.exe ^(v4.0.30319^)
    goto :collect
)

if exist "%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe" (
    set "COMPILER=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
    set "MODE=csc"
    echo  [OK] Compiler: .NET Framework csc.exe ^(v4.0.30319^)
    goto :collect
)

if exist "%WINDIR%\Microsoft.NET\Framework64\v3.5\csc.exe" (
    set "COMPILER=%WINDIR%\Microsoft.NET\Framework64\v3.5\csc.exe"
    set "MODE=csc"
    echo  [OK] Compiler: .NET Framework csc.exe ^(v3.5^)
    goto :collect
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
echo  Install one of the following:
echo    - .NET SDK:      https://dotnet.microsoft.com/download
echo    - Visual Studio: https://visualstudio.microsoft.com
echo.
pause
exit /b 1

:collect
echo.

set "OUTNAME=%~n1"
set "OUTDIR=%~dp1"
set "OUTPUT=%~dp1%~n1.exe"
set "FILECOUNT=0"
set "INVALID="

for %%F in (%*) do (
    if /i "%%~xF"==".cs" (
        set /a FILECOUNT+=1
    ) else (
        set "INVALID=1"
    )
)

if defined INVALID (
    echo  [WARN] Some dropped files are not .cs and will be ignored.
    echo.
)

if %FILECOUNT%==0 (
    echo  [ERROR] No valid .cs files were provided.
    echo  Make sure you are dragging .cs files onto this script.
    echo.
    pause
    exit /b 1
)

echo  Files:   %FILECOUNT% .cs file^(s^)
echo  Output:  %OUTPUT%
echo.
echo  Compiling...
echo.

if "%MODE%"=="dotnet" goto :build_dotnet
goto :build_csc


:build_csc
set "RSPFILE=%OUTDIR%_csdrop_files.rsp"
if exist "%RSPFILE%" del "%RSPFILE%" >nul 2>&1
for %%F in (%*) do (
    if /i "%%~xF"==".cs" echo "%%~F">> "%RSPFILE%"
)

if "%COMPILER%"=="csc" (
    csc /out:"%OUTPUT%" /optimize+ /nologo @"%RSPFILE%"
) else (
    "%COMPILER%" /out:"%OUTPUT%" /optimize+ /nologo @"%RSPFILE%"
)
set "RESULT=%errorlevel%"
del "%RSPFILE%" >nul 2>&1

if %RESULT% neq 0 goto :fail_compile
goto :verify


:build_dotnet
set "TMPDIR=%OUTDIR%_cstmp_%RANDOM%"
mkdir "%TMPDIR%" >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] Could not create temp folder.
    echo  Check write access to: %OUTDIR%
    echo.
    pause
    exit /b 1
)

dotnet new console -n _build --output "%TMPDIR%" --force >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] Failed to scaffold dotnet project.
    echo  Make sure the .NET SDK is installed correctly.
    rmdir /s /q "%TMPDIR%" >nul 2>&1
    echo.
    pause
    exit /b 1
)

del "%TMPDIR%\Program.cs" >nul 2>&1

for %%F in (%*) do (
    if /i "%%~xF"==".cs" copy /y "%%~F" "%TMPDIR%\" >nul 2>&1
)

dotnet build "%TMPDIR%" -o "%TMPDIR%\out" --nologo -c Release
set "RESULT=%errorlevel%"

if %RESULT%==0 (
    copy /y "%TMPDIR%\out\_build.exe" "%OUTPUT%" >nul 2>&1
    if errorlevel 1 (
        for /r "%TMPDIR%\out" %%X in (*.exe) do copy /y "%%X" "%OUTPUT%" >nul 2>&1
    )
)

rmdir /s /q "%TMPDIR%" >nul 2>&1

if %RESULT% neq 0 goto :fail_compile
goto :verify


:fail_compile
echo.
echo  [ERROR] Compilation failed.
echo.
echo  Common causes:
echo    - Syntax errors in your .cs file
echo    - Missing using statements
echo    - Class or method not found
echo.
echo  See the errors printed above for exact line numbers.
echo.
pause
exit /b 1


:verify
if not exist "%OUTPUT%" (
    echo.
    echo  [ERROR] Build reported success but no .exe was found.
    echo  Expected: %OUTPUT%
    echo.
    echo  On .NET 5+ dotnet CLI may produce a .dll instead of an .exe.
    echo  Try installing .NET Framework for classic .exe output.
    echo.
    pause
    exit /b 1
)

echo.
echo  [SUCCESS] %OUTPUT%
echo.
set /p "DORUN= Run now? (Y/N): "
if /i "%DORUN%"=="Y" (
    echo.
    echo  --- Program Output ---
    echo.
    "%OUTPUT%"
    set "EXITCODE=!errorlevel!"
    echo.
    echo  --- End of Output ---
    echo.
    if !EXITCODE! neq 0 echo  [WARN] Program exited with code !EXITCODE!
)

echo.
pause
exit /b 0
