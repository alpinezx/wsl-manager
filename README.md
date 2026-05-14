# WSL Manager

A simple Windows batch file to start, stop, restart, and manage WSL — with full control over whether it runs silently in the background, in a terminal window, or minimized to the taskbar. Includes optional auto-start on Windows boot.

---

## The Problem

When running WSL-based tools like Docker containers, you normally need a Ubuntu terminal window open and visible on your taskbar. If you accidentally close it, everything goes down. This tool fixes that by giving you full control over how WSL runs — silently in the background, in a visible terminal, or anywhere in between.

---

## Installation

No installation needed. Just download `wsl-manager.bat` and place it wherever you like — your Desktop, Documents, or any folder you prefer. That's it.

**[Download wsl-manager.bat](https://raw.githubusercontent.com/alpinezx/wsl-manager/refs/heads/main/wsl-manager.bat)**

Right-click the link and choose **Save link as** to download.

---

## Usage

Double-click `wsl-manager.bat` to open it. The menu detects your current state and shows only the options that are relevant. Here are two examples of what you might see:

**When WSL is not running and auto-start is disabled:**

```
=============================================
 WSL Manager
=============================================

 Current status:

   [ ] WSL                -- not running
   [ ] Start with Windows -- disabled

 What would you like to do?

   1) Start WSL (with terminal window)
   2) Start WSL in background (no terminal window)
   3) Start WSL automatically when Windows boots (with terminal window)
   4) Start WSL automatically when Windows boots (minimized to taskbar)
   5) Start WSL automatically when Windows boots (no terminal window)
   6) Exit
```

**When WSL is running and auto-start is enabled (hidden):**

```
=============================================
 WSL Manager
=============================================

 Current status:

   [x] WSL                -- running
   [x] Start with Windows -- enabled (hidden)

 What would you like to do?

   1) Restart WSL (with terminal window)
   2) Restart WSL in background (no terminal window)
   3) Stop WSL
   4) Stop WSL starting automatically on boot
   5) Exit
```

### What each option does

**Start WSL in background (no terminal window)**
Starts WSL silently with no visible terminal window. Any Docker containers or services set to auto-start will come up automatically within a few seconds.

**Start WSL (with terminal window)**
Starts WSL and opens a Ubuntu terminal window on your taskbar.

**Restart WSL in background (no terminal window)**
Shuts WSL down cleanly, waits for it to fully stop, then starts it again silently in the background.

**Restart WSL (with terminal window)**
Shuts WSL down cleanly, waits for it to fully stop, then starts it again with a terminal window.

**Stop WSL**
Shuts down WSL and all running containers cleanly. Waits to confirm everything has stopped before returning to the menu.

**Start WSL automatically when Windows boots (no terminal window)**
Creates a silent startup entry so WSL launches automatically every time you log into Windows — no terminal window, no manual steps.

**Start WSL automatically when Windows boots (with terminal window)**
Creates a startup entry that opens a Ubuntu terminal window automatically every time you log into Windows.

**Start WSL automatically when Windows boots (minimized to taskbar)**
Creates a startup entry that launches WSL minimized to the taskbar automatically every time you log into Windows.

**Stop WSL starting automatically on boot**
Removes the startup entry. WSL will no longer start automatically on login.

---

## How it works

- **Starting WSL silently** is done via a PowerShell command that launches `wsl.exe` with a hidden window.
- **Starting WSL with a terminal** uses the standard `start wsl.exe` command, opening a visible Ubuntu window.
- **Auto-start on boot** creates a small `.vbs` file silently in your Windows startup folder (`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`). Three variants exist — hidden, terminal, and minimized — and only one is ever active at a time. The file is removed automatically when you disable auto-start or switch modes.
- **Detecting WSL state** uses `tasklist` to check whether `wsl.exe` is running, which works reliably regardless of WSL version or output encoding.
- **Restart** waits in a loop for `wsl.exe` to fully disappear from the process list before starting again, so there's no risk of a premature restart.

---

## Requirements

- Windows 10 or 11
- WSL2 installed with Ubuntu

---

## Related Projects

This tool pairs well with either of these WSL-based setups:

- [openwebui-searxng](https://github.com/alpinezx/openwebui-searxng) — Open WebUI + SearXNG via Docker on WSL2
- [lmstudio-searxng](https://github.com/alpinezx/lmstudio-searxng) — LM Studio + SearXNG via Docker on WSL2
