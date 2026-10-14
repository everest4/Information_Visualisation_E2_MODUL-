@echo off
REM Information Visualization -- start JupyterLab in this folder (Windows).
REM Double-click this file. Run setup\Setup_Python_Windows.bat once before.
REM Keep the black window open while you work; close it when you are done.
setlocal EnableExtensions
for %%I in ("%~dp0.") do set "LECTURE_DIR=%%~fI"
set "CONDA="
for %%P in ("%USERPROFILE%\miniforge3" "%PUBLIC%\miniforge3" "%USERPROFILE%\mambaforge" ^
            "%USERPROFILE%\miniconda3" "%USERPROFILE%\anaconda3" ^
            "%LOCALAPPDATA%\miniforge3" "%LOCALAPPDATA%\miniconda3" "%LOCALAPPDATA%\anaconda3" ^
            "%ProgramData%\miniforge3" "%ProgramData%\miniconda3" "%ProgramData%\anaconda3") do (
  if not defined CONDA if exist "%%~P\Scripts\conda.exe" set "CONDA=%%~P\Scripts\conda.exe"
)
if not defined CONDA for /f "delims=" %%C in ('where conda 2^>nul') do if not defined CONDA set "CONDA=%%C"
if not defined CONDA (
  echo conda was not found. Run setup\Setup_Python_Windows.bat first.
  pause
  exit /b 1
)
for %%I in ("%CONDA%\..\..") do set "CONDA_ROOT=%%~fI"
call "%CONDA_ROOT%\Scripts\activate.bat" infovis
if errorlevel 1 goto failed
jupyter lab --notebook-dir="%LECTURE_DIR%"
if errorlevel 1 goto failed
goto done
:failed
echo.
echo JupyterLab did not start. Run setup\Setup_Python_Windows.bat again.
pause
:done
endlocal
