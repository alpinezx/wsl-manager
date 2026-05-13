# wsl-manager

A simple Windows batch file to start, stop, and manage WSL silently in the background — no terminal window required. Includes optional auto-start on Windows boot.

---

## The Problem

When running WSL-based tools like Docker containers, you normally need a Ubuntu terminal window open and visible on your taskbar. If you accidentally close it, everything goes down. This tool fixes that by letting you run WSL completely silently in the background with no window to worry about.

---

## Installation

No installation needed. Just download `wsl-manager.bat` and place it wherever you like — your Desktop, Documents, or any folder you prefer. That's it.

**[Download wsl-manager.bat](https://raw.githubusercontent.com/alpinezx/wsl-manager/refs/heads/main/wsl-manager.bat)**

Right-click the link and choose **Save link as** to download.

---

## Usage

Double-click `wsl-manager.bat` to open it. The menu detects your current state and shows only relevant options:

```
=============================================
 WSL Manager
=============================================

 Current status:

   [x] WSL                -- running
   [ ] Start with Windows -- disabled

 What would you like to do?

   1) Stop WSL
   2) Start WSL automatically when Windows boots (no terminal window)
   3) Exit
```

### What each option does

**Start WSL in background (no terminal window)**
Starts WSL silently with no visible terminal window. Any Docker containers or services set to auto-start will come up automatically within a few seconds.

**Stop WSL**
Shuts down WSL and all running containers cleanly.

**Start WSL automatically when Windows boots (no terminal window)**
Creates a silent startup entry so WSL launches automatically every time you log into Windows — no terminal window, no manual steps.

**Stop WSL starting automatically on boot**
Removes the startup entry. WSL will no longer start automatically on login.

---

## How it works

- **Starting WSL** is done via a PowerShell command that launches `wsl.exe` with a hidden window — no VBS file, no extra dependencies.
- **Auto-start on boot** creates a small `.vbs` file silently in your Windows startup folder (`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`). This file is invisible to normal use and is removed automatically if you disable auto-start.
- **Detecting WSL state** uses `tasklist` to check whether `wsl.exe` is running, which works reliably regardless of WSL version or output encoding.

---

## Requirements

- Windows 10 or 11
- WSL2 installed with Ubuntu

---

## Related Projects

This tool pairs well with either of these WSL-based setups:

- [openwebui-searxng](https://github.com/alpinezx/openwebui-searxng) — Open WebUI + SearXNG via Docker on WSL2
- [lmstudio-searxng](https://github.com/alpinezx/lmstudio-searxng) — LM Studio + SearXNG via Docker on WSL2
