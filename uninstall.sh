#!/bin/sh
# Lottery Recon uninstaller.
# Removes the app and the shortcut or menu entry. Saved runs stay unless --purge
# or -Purge is set, or LOTTERY_RECON_PURGE=1.
#
# curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.sh | sh
# curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/uninstall.sh | sh -s -- --purge
#
# Mac removes ~/Applications/Lottery Recon.app and the Desktop shortcut.
# Linux removes the LotteryRecon/app directory and the application menu entry.
# Saved runs stay in the LotteryReconTool folder unless purge is set.

set -eu

fail() {
  echo ""
  echo " x $1" >&2
  exit 1
}

purge=0
for arg in "$@"; do
  if [ "$arg" = "--purge" ] || [ "$arg" = "-Purge" ]; then
    purge=1
  fi
done
if [ "${LOTTERY_RECON_PURGE:-}" = "1" ]; then
  purge=1
fi

echo ""
echo " Lottery Recon uninstaller"
echo " -------------------------"
echo ""

os_name=$(uname -s)
if [ "$os_name" = "Darwin" ]; then
  app_path="$HOME/Applications/Lottery Recon.app"
  shortcut_path="$HOME/Desktop/Lottery Recon.app"
  data_root="$HOME/Library/Application Support/LotteryReconTool"
elif [ "$os_name" = "Linux" ]; then
  data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  app_path="$data_home/LotteryRecon/app"
  shortcut_path="$data_home/applications/lottery-recon.desktop"
  data_root="$data_home/LotteryReconTool"
else
  fail "This uninstaller supports macOS and Linux. This machine is $os_name."
fi

if command -v pgrep >/dev/null 2>&1; then
  if pgrep -x LotteryReconLauncher >/dev/null 2>&1; then
    fail "Quit Lottery Recon, then run the uninstaller again."
  fi
fi

if [ -e "$shortcut_path" ] || [ -L "$shortcut_path" ]; then
  rm -rf -- "$shortcut_path"
fi

if [ -e "$app_path" ] || [ -L "$app_path" ]; then
  if ! rm -rf -- "$app_path"; then
    fail "Could not remove $app_path. Quit Lottery Recon, then run the uninstaller again."
  fi
fi

if [ "$purge" -eq 1 ]; then
  if [ -e "$data_root" ] || [ -L "$data_root" ]; then
    rm -rf -- "$data_root"
  fi
  echo " Removed Lottery Recon and saved runs in $data_root"
else
  echo " Removed Lottery Recon."
  echo " Saved runs stay in $data_root"
fi
echo ""
