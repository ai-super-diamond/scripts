# Windows Fix Scripts Collection

## Overview

This collection contains scripts to fix common Windows issues that occur after reinstallation or system cleaning.

---

## 🖥️ Desktop Folder Fix

**Problem:** Desktop folder shows "Downloads" icon and name after Windows reinstall.

**Files:**

- `fix_desktop_folder.bat` - Simple batch solution
- `fix_desktop_folder.ps1` - Advanced PowerShell solution with registry fixes

**Usage:** Right-click → "Run as administrator"

---

## 🏃‍♂️ Win+R Command History Manager

**Problem:** Win+R command history gets cleared by system cleaners or Windows resets.

**Solution:** Automatically populate Win+R with your favorite commands!

### Files:

1. **`populate_run_commands.ps1`** - Main script with built-in commands
2. **`populate_run_commands_from_file.ps1`** - Reads from config file (recommended)
3. **`run_commands.txt`** - Easy-to-edit configuration file
4. **`populate_run_commands.bat`** - Simple launcher (just double-click!)
5. **`setup_run_commands_startup.ps1`** - Set up automatic startup population

### Quick Start:

1. **Edit commands:** Open `run_commands.txt` and add your favorite commands
2. **Run once:** Double-click `populate_run_commands.bat`
3. **Test it:** Press Win+R and start typing - your commands appear!

### Auto-Startup Setup:

1. Run `setup_run_commands_startup.ps1` 
2. Choose "Yes" to set up automatic population at login
3. Your commands will be available after every restart!

### Adding New Commands:

**Super Easy Method:**

1. Open `run_commands.txt` in Notepad
2. Add your command on a new line (no quotes needed)
3. Save the file
4. Run `populate_run_commands.bat` or wait for next login

**Examples of useful commands to add:**

```
# Your development tools
code
git status
python

# Your project folders  
C:\MyProjects
D:\Development

# Custom shortcuts
cmd /k cd /d C:\MyProjects
powershell -noexit -command "cd C:\MyProjects"

# Quick admin tools
eventvwr.msc
perfmon.msc
taskschd.msc
```

### Advanced Features:

- **Preserves existing commands** - Won't delete your current Win+R history
- **Deduplication** - Automatically removes duplicates
- **Priority system** - Your custom commands appear first
- **Startup automation** - Set once, works forever
- **Easy editing** - Just modify the text file

---

## 📁 File Structure

```
fixes/
├── fix_desktop_folder.bat              # Desktop folder fix (batch)
├── fix_desktop_folder.ps1              # Desktop folder fix (PowerShell)
├── populate_run_commands.ps1           # Win+R populator (built-in commands)
├── populate_run_commands_from_file.ps1 # Win+R populator (from file)
├── populate_run_commands.bat           # Easy launcher
├── run_commands.txt                    # Your command configuration
├── setup_run_commands_startup.ps1     # Startup automation setup
└── README.md                          # This file
```

---

## 🚀 Quick Actions

| What you want to do          | How to do it                                      |
| ---------------------------- | ------------------------------------------------- |
| Fix Desktop folder           | Run `fix_desktop_folder.bat` as admin             |
| Add Win+R commands once      | Double-click `populate_run_commands.bat`          |
| Set up auto Win+R population | Run `setup_run_commands_startup.ps1`              |
| Add new Win+R commands       | Edit `run_commands.txt`, then run the bat file    |
| Remove startup automation    | Run `setup_run_commands_startup.ps1` → Choose "R" |

---

## 💡 Pro Tips

1. **After Windows reinstall:** Run both scripts to get everything back to normal
2. **Backup your commands:** Keep a copy of `run_commands.txt` in cloud storage
3. **Share commands:** Copy `run_commands.txt` to other computers
4. **System cleaners:** Set up startup automation so commands persist after cleaning
5. **Portable setup:** Copy the entire `fixes` folder to USB for quick setup on any PC

---

## 🛠️ Troubleshooting

**PowerShell Execution Policy Issues:**

- The batch file automatically bypasses execution policy
- Or run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

**Win+R commands not appearing:**

- Make sure you're typing the exact command
- Try logging off and back on
- Check if antivirus blocked the registry changes

**Desktop fix not working:**

- Try the PowerShell version instead of batch
- Restart computer after running the script
- Some systems may need multiple runs

---

## 🔄 Adding More Fix Scripts

To add new fix scripts to this collection:

1. Create your script in this folder
2. Update this README with usage instructions
3. Follow the same naming pattern and structure

---

*Last updated: $(Get-Date)*
