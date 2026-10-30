# Lottery Recon uninstaller.
# Removes the app and the desktop shortcut. Saved runs stay unless purge is requested.
#
# powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.ps1 | iex"
#
# To also delete saved runs, set LOTTERY_RECON_PURGE=1 in that same command,
# or pass -Purge or --purge when the script is run as a file.
# This script does not search the disk for a folder that was copied onto the PC by hand.

$ErrorActionPreference = "Stop"

$purge = $false
foreach ($arg in @($args)) {
    if ($arg -eq "-Purge" -or $arg -eq "--purge") {
        $purge = $true
    }
}
if ($env:LOTTERY_RECON_PURGE -eq "1") {
    $purge = $true
}

function Fail {
    param([string]$Message)
    Write-Host ""
    Write-Host " x $Message" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host " Lottery Recon uninstaller"
Write-Host " -------------------------"
Write-Host ""

if (-not $env:LOCALAPPDATA) {
    Fail "LOCALAPPDATA is not set."
}

$running = Get-Process -Name "LotteryReconLauncher" -ErrorAction SilentlyContinue
if ($running) {
    Fail "Quit Lottery Recon, then run the uninstaller again."
}

$InstallRoot = Join-Path $env:LOCALAPPDATA "LotteryRecon\app"
$DataRoot = Join-Path $env:LOCALAPPDATA "LotteryReconTool"
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Lottery Recon.lnk"

if (Test-Path -LiteralPath $shortcutPath) {
    Remove-Item -LiteralPath $shortcutPath -Force
}

if (Test-Path -LiteralPath $InstallRoot) {
    try {
        Remove-Item -LiteralPath $InstallRoot -Recurse -Force
    } catch {
        Fail "Could not remove $InstallRoot. Quit Lottery Recon, then run the uninstaller again."
    }
}

if ($purge) {
    if (Test-Path -LiteralPath $DataRoot) {
        Remove-Item -LiteralPath $DataRoot -Recurse -Force
    }
    Write-Host " Removed Lottery Recon and saved runs in $DataRoot"
} else {
    Write-Host " Removed Lottery Recon."
    Write-Host " Saved runs stay in $DataRoot"
}

Write-Host ""
