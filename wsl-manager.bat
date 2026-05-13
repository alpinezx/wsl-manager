@echo off
setlocal EnableDelayedExpansion

:: =============================================================
:: wsl-manager.bat
:: A simple WSL control panel. Start, stop, and manage whether
:: WSL launches automatically when Windows boots.
:: Place this file wherever you like.
:: =============================================================

set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "STARTUP_VBS=%STARTUP_DIR%\wsl-autostart.vbs"

:MENU

:: --- Detect WSL running state ---
set "wsl_running=false"
tasklist /fi "imagename eq wsl.exe" 2>nul | find /i "wsl.exe" >nul 2>&1 && set "wsl_running=true"

:: --- Detect startup entry ---
set "has_startup=false"
if exist "%STARTUP_VBS%" set "has_startup=true"

:: --- Header ---
echo.
echo =============================================
echo  WSL Manager
echo =============================================
echo.
echo  Current status:
echo.
if "%wsl_running%"=="true"  (echo    [x] WSL                -- running)   else (echo    [ ] WSL                -- not running)
if "%has_startup%"=="true"  (echo    [x] Start with Windows -- enabled)   else (echo    [ ] Start with Windows -- disabled)
echo.

:: --- Build dynamic menu ---
set "opt_count=0"

if "%wsl_running%"=="false" (
  set /a opt_count+=1
  set "opt_!opt_count!=Start WSL in background (no terminal window)"
)

if "%wsl_running%"=="true" (
  set /a opt_count+=1
  set "opt_!opt_count!=Stop WSL"
)

if "%has_startup%"=="false" (
  set /a opt_count+=1
  set "opt_!opt_count!=Start WSL automatically when Windows boots (no terminal window)"
)

if "%has_startup%"=="true" (
  set /a opt_count+=1
  set "opt_!opt_count!=Stop WSL starting automatically on boot"
)

set /a opt_count+=1
set "opt_!opt_count!=Exit"

:: --- Print menu ---
echo  What would you like to do?
echo.
for /l %%i in (1,1,%opt_count%) do (
  echo    %%i^) !opt_%%i!
)
echo.
set /p "choice= Enter choice [1-%opt_count%]: "
echo.

:: --- Validate input ---
if "%choice%"=="" goto INVALID
set /a "choice_num=%choice%" 2>nul
if %choice_num% lss 1 goto INVALID
if %choice_num% gtr %opt_count% goto INVALID

:: --- Handle selection ---
set "selected=!opt_%choice_num%!"

if "!selected!"=="Start WSL in background (no terminal window)" goto DO_START
if "!selected!"=="Stop WSL" goto DO_STOP
if "!selected!"=="Start WSL automatically when Windows boots (no terminal window)" goto DO_ENABLE_STARTUP
if "!selected!"=="Stop WSL starting automatically on boot" goto DO_DISABLE_STARTUP
if "!selected!"=="Exit" goto DO_EXIT
goto INVALID

:: =============================================================
:: Actions
:: =============================================================

:DO_START
powershell -NoProfile -Command "Start-Process wsl.exe -WindowStyle Hidden"
echo  [x] WSL is starting in the background.
echo      Your containers will be ready in a few seconds.
timeout /t 4 /nobreak >nul
goto MENU

:DO_STOP
echo.
wsl.exe --shutdown
echo  Waiting for WSL to shut down...
:WAIT_STOP
timeout /t 2 /nobreak >nul
set "still_running=false"
tasklist /fi "imagename eq wsl.exe" 2>nul | find /i "wsl.exe" >nul 2>&1 && set "still_running=true"
if "%still_running%"=="true" goto WAIT_STOP
echo  [x] WSL has been shut down.
timeout /t 1 /nobreak >nul
goto MENU

:DO_ENABLE_STARTUP
set /p "confirm= WSL will start automatically every time Windows boots. Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
  echo  Cancelled. Nothing was changed.
  goto MENU
)
echo.
echo  Setting up auto-start...
(
  echo Set objShell = CreateObject^("WScript.Shell"^)
  echo objShell.Run "wsl.exe", 0, False
) > "%STARTUP_VBS%"
echo  [x] Done. WSL will now start automatically on next Windows boot.
timeout /t 2 /nobreak >nul
goto MENU

:DO_DISABLE_STARTUP
set /p "confirm= WSL will no longer start automatically when Windows boots. Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
  echo  Cancelled. Nothing was changed.
  goto MENU
)
echo.
del "%STARTUP_VBS%"
echo  [x] Auto-start has been disabled.
timeout /t 2 /nobreak >nul
goto MENU

:INVALID
echo  Invalid choice. Please try again.
goto MENU

:DO_EXIT
echo  Exiting.
echo.
exit /b
