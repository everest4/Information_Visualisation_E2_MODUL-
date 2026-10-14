@echo off
REM ============================================================================
REM  Information Visualization -- one-click Python setup (Windows 10/11)
REM
REM  What it does (safe to run more than once):
REM   1. looks for conda (Miniforge, Miniconda or Anaconda);
REM      if none is found, installs Miniforge for your user (no admin needed)
REM   2. creates (or updates) the course environment "infovis"
REM   3. runs check_setup.py, which draws a test chart
REM   4. opens JupyterLab in the lecture folder
REM
REM  How to run it: double-click this file.
REM  If Windows shows "Windows protected your PC": click "More info", then "Run anyway".
REM ============================================================================
setlocal EnableExtensions
set "SETUP_DIR=%~dp0"
for %%I in ("%SETUP_DIR%..") do set "LECTURE_DIR=%%~fI"
set "ENV_NAME=infovis"

echo.
echo ==^> Information Visualization: Python setup (this can take 5 to 15 minutes)

REM ---- 1. conda ---------------------------------------------------------------
call :find_conda
if defined CONDA goto have_conda

echo.
echo ==^> No conda found. Downloading Miniforge (about 80 MB)...
REM conda does not like spaces in its install path: fall back to C:\Users\Public
set "MF_DIR=%USERPROFILE%\miniforge3"
if not "%USERPROFILE: =%"=="%USERPROFILE%" set "MF_DIR=%PUBLIC%\miniforge3"
set "MF_EXE=%TEMP%\Miniforge3-Windows-x86_64.exe"
curl.exe -fL --retry 3 -o "%MF_EXE%" https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe
if errorlevel 1 goto fail_download
echo.
echo ==^> Installing Miniforge in %MF_DIR% ...
start "" /wait "%MF_EXE%" /InstallationType=JustMe /RegisterPython=0 /AddToPath=0 /S /D=%MF_DIR%
del "%MF_EXE%" >nul 2>nul
if not exist "%MF_DIR%\Scripts\conda.exe" goto fail_install
set "CONDA=%MF_DIR%\Scripts\conda.exe"

:have_conda
echo.
echo ==^> Using conda: %CONDA%

REM ---- 2. environment -----------------------------------------------------------
call "%CONDA%" env list | findstr /b /c:"%ENV_NAME% " >nul
if errorlevel 1 (
  echo.
  echo ==^> Creating the "%ENV_NAME%" environment ^(downloads about 500 MB^)...
  call "%CONDA%" env create -n %ENV_NAME% -f "%SETUP_DIR%environment.yml"
) else (
  echo.
  echo ==^> Updating the existing "%ENV_NAME%" environment...
  call "%CONDA%" env update -n %ENV_NAME% -f "%SETUP_DIR%environment.yml"
)
if errorlevel 1 goto fail_env

REM activate the environment in this window
for %%I in ("%CONDA%\..\..") do set "CONDA_ROOT=%%~fI"
call "%CONDA_ROOT%\Scripts\activate.bat" %ENV_NAME%
if errorlevel 1 goto fail_env
python -m ipykernel install --user --name %ENV_NAME% --display-name "Python (infovis)" >nul 2>nul

REM ---- 3. check --------------------------------------------------------------------
echo.
echo ==^> Checking the installation...
python "%SETUP_DIR%check_setup.py"
if errorlevel 1 goto fail_check

REM ---- 4. JupyterLab ----------------------------------------------------------------
echo.
echo ==^> Starting JupyterLab in your browser. Keep this window open while you work;
echo     close it when you are done. Next time, double-click Start_JupyterLab_Windows.bat
echo.
jupyter lab --notebook-dir="%LECTURE_DIR%"
goto end

REM ---- helpers -----------------------------------------------------------------------
:find_conda
set "CONDA="
for %%P in ("%USERPROFILE%\miniforge3" "%PUBLIC%\miniforge3" "%USERPROFILE%\mambaforge" ^
            "%USERPROFILE%\miniconda3" "%USERPROFILE%\anaconda3" ^
            "%LOCALAPPDATA%\miniforge3" "%LOCALAPPDATA%\miniconda3" "%LOCALAPPDATA%\anaconda3" ^
            "%ProgramData%\miniforge3" "%ProgramData%\miniconda3" "%ProgramData%\anaconda3") do (
  if not defined CONDA if exist "%%~P\Scripts\conda.exe" set "CONDA=%%~P\Scripts\conda.exe"
)
if defined CONDA exit /b 0
for /f "delims=" %%C in ('where conda 2^>nul') do if not defined CONDA set "CONDA=%%C"
exit /b 0

:fail_download
echo.
echo SETUP STOPPED: the download failed. Check your internet connection and try again.
goto fail_common
:fail_install
echo.
echo SETUP STOPPED: Miniforge could not be installed in %MF_DIR%.
goto fail_common
:fail_env
echo.
echo SETUP STOPPED: the environment could not be created or updated.
goto fail_common
:fail_check
echo.
echo SETUP STOPPED: the check found a problem (see the list above).
goto fail_common
:fail_common
echo Take a screenshot of this window and bring it to the exercise session.
echo.
pause
exit /b 1

:end
pause
endlocal
