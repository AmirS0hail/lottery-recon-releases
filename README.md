# Lottery Recon

Lottery Recon is a desktop tool for checking lottery pack records on your own computer. You give it exported spreadsheets, such as a vendor portal report and invoice lines. It compares activations, settlements, and invoices, shows the rows that need attention, and writes a workbook you can review or download.

The app runs locally. It does not sign in to a lottery system, and it does not upload the spreadsheets.

This repository is the public download page. It holds the installers and the release files for Windows, Mac, and Linux. The application source stays private.

## What you can do with it

- Start the app from a desktop shortcut. It opens in your browser on this computer.
- Reconcile a combined workbook, separate export files, or a small bundle of files.
- Review exceptions such as packs missing from one source, duplicates, late settlements, and invoice lines with no matching portal activation.
- Look up one pack reference across runs already saved on this computer.
- Download the result workbook.

Saved runs stay on this computer. Updating or removing the app does not delete them.

## Who this is for

This is a focused release for someone reconciling lottery packs from files they already export. It is one person, on a computer they trust. It is not a hosted service and it does not write back into a live system.

## Install on Windows

On the PC that will run the tool:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/install.ps1 | iex"
```

The script downloads the latest release, checks `SHA256SUMS`, and stops if the checksum does not match. It installs under `%LOCALAPPDATA%\LotteryRecon\app`, adds a desktop shortcut named Lottery Recon, and opens the app.

The launcher is not code-signed. Windows may show an unsigned-app warning the first time it opens.

## Install on Mac

On an Apple Silicon Mac:

```bash
curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/install.sh | sh
```

The script downloads the latest release, checks `SHA256SUMS`, and stops if the checksum does not match. It installs `~/Applications/Lottery Recon.app`, adds a desktop shortcut to that app, and opens it. Saved runs stay in `~/Library/Application Support/LotteryReconTool`.

The app is not notarized. The first open can require approval under Privacy and Security. This release is for Apple Silicon only.

## Install on Linux

On 64-bit Intel or AMD Linux with a desktop session:

```bash
curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/install.sh | sh
```

The script downloads the latest release, checks `SHA256SUMS`, and stops if the checksum does not match. It installs under `~/.local/share/LotteryRecon/app`, or under `$XDG_DATA_HOME/LotteryRecon/app` when that variable is set, adds a Lottery Recon application menu entry, and opens the app. Saved runs stay in `~/.local/share/LotteryReconTool`, or in `$XDG_DATA_HOME/LotteryReconTool` when that variable is set.

The launcher opens a window on a normal desktop session. A machine without a display cannot start it.

## Update

Open Lottery Recon. When a newer release exists, the page shows that version and an Update button. Click Update once. The page shows the download and the check. Lottery Recon then closes, a window shows the install, and the new version opens. The update notice is gone after that version opens. Saved runs stay on this computer.

A copy that does not show the button, including one unpacked by hand, is updated by running the install command for this computer again.

A copy from before this release, including one whose Update button never finishes, is updated once with the install command. Later updates use the button.

## What the app reports

The app sends five usage events after it is installed from this repository: the app started, a reconciliation finished, a reconciliation failed, a reference was investigated, and a result workbook was downloaded. Each event includes an install id, the release version, the event name, the time, and sometimes a short code such as the run mode. It does not send workbooks, file names, store names, site ids, pack numbers, review notes, or the text typed into an investigation search.

## Replacing an older copy

An older folder that was copied onto a Windows PC by hand is not registered with Windows. The installer does not search for it. Mac and Linux do not have that older copy.

1. Quit the old launcher.
2. Delete the folder that was originally copied onto this PC, and delete any shortcut that still points at it.
3. Leave `%LOCALAPPDATA%\LotteryReconTool` in place. That folder holds saved runs.
4. Run the Windows install command above. It opens Lottery Recon when the install finishes.
5. Use the new Lottery Recon shortcut the next time.

## Remove this install

Quit Lottery Recon first. The uninstaller removes the app and the shortcut or menu entry. Saved runs stay unless purge is set.

### Windows

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.ps1 | iex"
```

That deletes the Lottery Recon shortcut and `%LOCALAPPDATA%\LotteryRecon\app`. Saved runs remain in `%LOCALAPPDATA%\LotteryReconTool`.

To delete the app and saved runs, pass `-Purge` or `--purge` when the script is run as a file, or set `LOTTERY_RECON_PURGE` in the same command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:LOTTERY_RECON_PURGE='1'; irm https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.ps1 | iex"
```

### Mac

```bash
curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.sh | sh
```

That deletes the Desktop shortcut and `~/Applications/Lottery Recon.app`. Saved runs remain in `~/Library/Application Support/LotteryReconTool`.

```bash
curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.sh | sh -s -- --purge
```

`--purge` and `-Purge` also delete that saved-runs folder.

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.sh | sh
```

That deletes `lottery-recon.desktop` and the `LotteryRecon/app` directory under `~/.local/share`, or under `$XDG_DATA_HOME` when that variable is set. Saved runs remain in the `LotteryReconTool` folder next to it.

```bash
curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.sh | sh -s -- --purge
```

`--purge` and `-Purge` also delete that saved-runs folder. `LOTTERY_RECON_PURGE=1` does the same on Mac and Linux.

The installed app also has a Remove control on its launcher window. That removes the app and the shortcut, and it leaves saved runs in place. It does not purge.

## This repository

The installers on this page download the latest build from [Releases](https://github.com/AmirS0hail/lottery-recon-releases/releases). That list stays empty until the first build is published. The explanation and the installer scripts are already here.

| Path | What it is |
|---|---|
| `install.ps1` | Windows installer |
| `install.sh` | Mac and Linux installer |
| `uninstall.ps1` | Windows uninstaller |
| `uninstall.sh` | Mac and Linux uninstaller |
| [Releases](https://github.com/AmirS0hail/lottery-recon-releases/releases) | `LotteryReconLauncher-windows-x64.zip`, `LotteryReconLauncher-macos-arm64.zip`, `LotteryReconLauncher-linux-x64.zip`, and `SHA256SUMS` |

Source code is not published here.
