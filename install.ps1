# Lottery Recon installer.
# Downloads the latest checksum-verified Windows build and installs it for the current user.
#
# powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/install.ps1 | iex"
#
# This script replaces %LOCALAPPDATA%\LotteryRecon\app only.
# It does not read or delete %LOCALAPPDATA%\LotteryReconTool, and it does not search
# the disk for an older folder that was copied onto the PC by hand.

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Repo = "AmirS0hail/lottery-recon-releases"
$AssetName = "LotteryReconLauncher-windows-x64.zip"
$InstallRoot = Join-Path $env:LOCALAPPDATA "LotteryRecon\app"
$DataRoot = Join-Path $env:LOCALAPPDATA "LotteryReconTool"

function Fail {
    param([string]$Message)
    Write-Host ""
    Write-Host " x $Message" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host " Lottery Recon installer"
Write-Host " -----------------------"
Write-Host ""

if (-not $env:LOCALAPPDATA) {
    Fail "LOCALAPPDATA is not set."
}

Write-Host " Fetching latest release..."
try {
    $release = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/$Repo/releases/latest"
} catch {
    Fail "Could not read the latest release from https://github.com/$Repo/releases"
}

$tag = [string]$release.tag_name
if (-not $tag) {
    Fail "The latest release has no tag."
}
Write-Host " Version: $tag"

$downloadBase = "https://github.com/$Repo/releases/download/$tag"
$zipUrl = "$downloadBase/$AssetName"
$sumUrl = "$downloadBase/SHA256SUMS"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("lottery-recon-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot | Out-Null

try {
    $zipPath = Join-Path $tempRoot $AssetName
    $sumPath = Join-Path $tempRoot "SHA256SUMS"

    Write-Host " Downloading $AssetName..."
    Invoke-WebRequest -UseBasicParsing -Uri $zipUrl -OutFile $zipPath
    Write-Host " Downloading SHA256SUMS..."
    Invoke-WebRequest -UseBasicParsing -Uri $sumUrl -OutFile $sumPath

    $expected = $null
    foreach ($line in Get-Content -LiteralPath $sumPath) {
        if ($line -match '([0-9a-fA-F]{64})\s+\*?LotteryReconLauncher-windows-x64\.zip') {
            $expected = $Matches[1].ToLower()
        }
    }
    if (-not $expected) {
        Fail "SHA256SUMS has no entry for $AssetName. Refusing to install an unverified zip."
    }

    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash.ToLower()
    if ($actual -ne $expected) {
        Fail "Checksum verification failed."
    }
    Write-Host " Checksum verified."

    if (Test-Path -LiteralPath $InstallRoot) {
        try {
            Remove-Item -LiteralPath $InstallRoot -Recurse -Force
        } catch {
            Fail "Could not replace $InstallRoot. Quit Lottery Recon, then run the installer again."
        }
    }

    New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
    Expand-Archive -LiteralPath $zipPath -DestinationPath $InstallRoot -Force

    $exe = Join-Path $InstallRoot "LotteryReconLauncher\LotteryReconLauncher.exe"
    if (-not (Test-Path -LiteralPath $exe)) {
        Fail "The release zip did not contain LotteryReconLauncher.exe."
    }

    $desktop = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktop "Lottery Recon.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $exe
    $shortcut.WorkingDirectory = Split-Path -Parent $exe
    $shortcut.Description = "Lottery Recon"
    $shortcut.Save()

    Write-Host ""
    Write-Host " Installed to $exe"
    Write-Host " Shortcut: $shortcutPath"
    Write-Host " Saved runs stay in $DataRoot"
    Write-Host ""
    Write-Host " Open Lottery Recon from the desktop shortcut."
    Write-Host ""
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
