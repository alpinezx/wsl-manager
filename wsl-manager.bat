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
set "STARTUP_VBS_WIN=%STARTUP_DIR%\wsl-autostart-window.vbs"
set "STARTUP_VBS_MIN=%STARTUP_DIR%\wsl-autostart-minimized.vbs"

:MENU

:: --- Detect WSL running state ---
set "wsl_running=false"
tasklist /fi "imagename eq wsl.exe" 2>nul | find /i "wsl.exe" >nul 2>&1 && set "wsl_running=true"

:: --- Detect startup entry ---
set "has_startup=false"
set "startup_mode="
if exist "%STARTUP_VBS%"     (set "has_startup=true" & set "startup_mode=hidden")
if exist "%STARTUP_VBS_WIN%" (set "has_startup=true" & set "startup_mode=window")
if exist "%STARTUP_VBS_MIN%" (set "has_startup=true" & set "startup_mode=minimized")

:: --- Header ---
echo.
echo =============================================
echo  WSL Manager
echo =============================================
echo.
echo  Current status:
echo.
if "%wsl_running%"=="true" (
  echo    [x] WSL                -- running
) else (
  echo    [ ] WSL                -- not running
)
if "%has_startup%"=="true" (
  if "%startup_mode%"=="hidden"   echo    [x] Start with Windows -- enabled (hidden)
  if "%startup_mode%"=="window"   echo    [x] Start with Windows -- enabled (with terminal)
  if "%startup_mode%"=="minimized" echo    [x] Start with Windows -- enabled (minimized to taskbar)
) else (
  echo    [ ] Start with Windows -- disabled
)
echo.

:: --- Build dynamic menu ---
set "opt_count=0"

if "%wsl_running%"=="false" (
  set /a opt_count+=1
  set "opt_!opt_count!=Start WSL (with terminal window)"
  set /a opt_count+=1
  set "opt_!opt_count!=Start WSL in background (no terminal window)"
)

if "%wsl_running%"=="true" (
  set /a opt_count+=1
  set "opt_!opt_count!=Restart WSL (with terminal window)"
  set /a opt_count+=1
  set "opt_!opt_count!=Restart WSL in background (no terminal window)"
  set /a opt_count+=1
  set "opt_!opt_count!=Stop WSL"
)

if "%has_startup%"=="false" (
  set /a opt_count+=1
  set "opt_!opt_count!=Start WSL automatically when Windows boots (with terminal window)"
  set /a opt_count+=1
  set "opt_!opt_count!=Start WSL automatically when Windows boots (minimized to taskbar)"
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

if "!selected!"=="Start WSL in background (no terminal window)"                    goto DO_START
if "!selected!"=="Start WSL (with terminal window)"                                goto DO_START_WINDOW
if "!selected!"=="Restart WSL (with terminal window)"                              goto DO_RESTART_WINDOW
if "!selected!"=="Restart WSL in background (no terminal window)"                  goto DO_RESTART
if "!selected!"=="Stop WSL"                                                        goto DO_STOP
if "!selected!"=="Start WSL automatically when Windows boots (no terminal window)" goto DO_ENABLE_STARTUP
if "!selected!"=="Start WSL automatically when Windows boots (with terminal window)" goto DO_ENABLE_STARTUP_WINDOW
if "!selected!"=="Start WSL automatically when Windows boots (minimized to taskbar)" goto DO_ENABLE_STARTUP_MIN
if "!selected!"=="Stop WSL starting automatically on boot"                         goto DO_DISABLE_STARTUP
if "!selected!"=="Exit"                                                            goto DO_EXIT
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

:DO_START_WINDOW
start wsl.exe --cd ~
echo  [x] WSL is launching in a new terminal window.
timeout /t 2 /nobreak >nul
goto MENU

:DO_RESTART_WINDOW
set "restart_mode=window"
goto DO_RESTART_SHUTDOWN

:DO_RESTART
set "restart_mode=hidden"
goto DO_RESTART_SHUTDOWN

:DO_RESTART_SHUTDOWN
echo.
wsl.exe --shutdown
echo  Waiting for WSL to shut down...
:WAIT_RESTART
timeout /t 2 /nobreak >nul
set "still_running=false"
tasklist /fi "imagename eq wsl.exe" 2>nul | find /i "wsl.exe" >nul 2>&1 && set "still_running=true"
if "%still_running%"=="true" goto WAIT_RESTART
echo  [x] WSL has shut down. Starting again...
timeout /t 1 /nobreak >nul
if "%restart_mode%"=="window" goto DO_START_WINDOW
goto DO_START

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
set /p "confirm= WSL will start hidden automatically every time Windows boots. Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
  echo  Cancelled. Nothing was changed.
  goto MENU
)
echo.
echo  Setting up auto-start (hidden)...
if exist "%STARTUP_VBS_WIN%" del "%STARTUP_VBS_WIN%"
if exist "%STARTUP_VBS_MIN%" del "%STARTUP_VBS_MIN%"
(
  echo Set objShell = CreateObject^("WScript.Shell"^)
  echo objShell.Run "wsl.exe", 0, False
) > "%STARTUP_VBS%"
echo  [x] Done. WSL will now start hidden automatically on next Windows boot.
timeout /t 2 /nobreak >nul
goto MENU

:DO_ENABLE_STARTUP_WINDOW
set /p "confirm= WSL will start with a terminal window automatically every time Windows boots. Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
  echo  Cancelled. Nothing was changed.
  goto MENU
)
echo.
echo  Setting up auto-start (with terminal)...
if exist "%STARTUP_VBS%"     del "%STARTUP_VBS%"
if exist "%STARTUP_VBS_MIN%" del "%STARTUP_VBS_MIN%"
(
  echo Set objShell = CreateObject^("WScript.Shell"^)
  echo objShell.Run "wsl.exe --cd ~", 1, False
) > "%STARTUP_VBS_WIN%"
echo  [x] Done. WSL will now start with a terminal window automatically on next Windows boot.
timeout /t 2 /nobreak >nul
goto MENU

:DO_ENABLE_STARTUP_MIN
set /p "confirm= WSL will start minimized to the taskbar automatically every time Windows boots. Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
  echo  Cancelled. Nothing was changed.
  goto MENU
)
echo.
echo  Setting up auto-start (minimized)...
if exist "%STARTUP_VBS%"     del "%STARTUP_VBS%"
if exist "%STARTUP_VBS_WIN%" del "%STARTUP_VBS_WIN%"
(
  echo Set objShell = CreateObject^("WScript.Shell"^)
  echo objShell.Run "wsl.exe --cd ~", 2, False
) > "%STARTUP_VBS_MIN%"
echo  [x] Done. WSL will now start minimized to the taskbar automatically on next Windows boot.
timeout /t 2 /nobreak >nul
goto MENU

:DO_DISABLE_STARTUP
set /p "confirm= WSL will no longer start automatically when Windows boots. Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
  echo  Cancelled. Nothing was changed.
  goto MENU
)
echo.
if exist "%STARTUP_VBS%"     del "%STARTUP_VBS%"
if exist "%STARTUP_VBS_WIN%" del "%STARTUP_VBS_WIN%"
if exist "%STARTUP_VBS_MIN%" del "%STARTUP_VBS_MIN%"
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
