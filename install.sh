#!/bin/sh
# Lottery Recon installer.
# Downloads the latest checksum-verified Mac or Linux build and installs it for the current user.
#
# curl -fsSL https://raw.githubusercontent.com/AmirS0hail/lottery-recon-releases/main/install.sh | sh
#
# On Mac this replaces ~/Applications/Lottery Recon.app only.
# On Linux this replaces the LotteryRecon/app directory only.
# It does not read or delete the saved-runs folder:
#   Mac: ~/Library/Application Support/LotteryReconTool
#   Linux: $XDG_DATA_HOME/LotteryReconTool, or ~/.local/share/LotteryReconTool

set -eu

REPO="AmirS0hail/lottery-recon-releases"

fail() {
  echo ""
  echo " x $1" >&2
  exit 1
}

if ! command -v curl >/dev/null 2>&1; then
  fail "curl is required."
fi

os_name=$(uname -s)
arch=$(uname -m)

case "$os_name:$arch" in
  Darwin:arm64)
    asset="LotteryReconLauncher-macos-arm64.zip"
    ;;
  Linux:x86_64)
    asset="LotteryReconLauncher-linux-x64.zip"
    ;;
  Darwin:*)
    fail "This release is built for Apple Silicon (arm64). This Mac is $arch."
    ;;
  Linux:*)
    fail "This release is built for 64-bit Intel/AMD Linux (x86_64). This machine is $arch."
    ;;
  *)
    fail "This installer supports macOS Apple Silicon and 64-bit Linux. This machine is $os_name $arch."
    ;;
esac

echo ""
echo " Lottery Recon installer"
echo " -----------------------"
echo ""

if [ "$os_name" = "Darwin" ]; then
  install_app="$HOME/Applications/Lottery Recon.app"
  data_root="$HOME/Library/Application Support/LotteryReconTool"
else
  data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  install_root="$data_home/LotteryRecon/app"
  data_root="$data_home/LotteryReconTool"
fi

echo " Fetching latest release..."
if ! release_json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest"); then
  fail "Could not read the latest release from https://github.com/$REPO/releases"
fi
tag=$(printf '%s\n' "$release_json" | awk -F '"' '/"tag_name"/ { print $4; exit }')
if [ -z "$tag" ]; then
  fail "The latest release has no tag."
fi
echo " Version: $tag"

download_base="https://github.com/$REPO/releases/download/$tag"
tmp=$(mktemp -d)
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

zip_path="$tmp/$asset"
sum_path="$tmp/SHA256SUMS"

echo " Downloading $asset..."
if ! curl -fsSL "$download_base/$asset" -o "$zip_path"; then
  fail "Could not download $asset."
fi
echo " Downloading SHA256SUMS..."
if ! curl -fsSL "$download_base/SHA256SUMS" -o "$sum_path"; then
  fail "Could not download SHA256SUMS."
fi

expected=$(awk -v asset="$asset" '
  $1 ~ /^[0-9a-fA-F]{64}$/ {
    name = $2
    sub(/\r$/, "", name)
    sub(/^\*/, "", name)
    if (name == asset) {
      print tolower($1)
      exit
    }
  }
' "$sum_path")

if [ -z "$expected" ]; then
  fail "SHA256SUMS has no entry for $asset. Refusing to install an unverified zip."
fi

if command -v shasum >/dev/null 2>&1; then
  actual=$(shasum -a 256 "$zip_path" | awk '{ print tolower($1) }')
elif command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$zip_path" | awk '{ print tolower($1) }')
else
  fail "sha256sum or shasum is required."
fi

if [ "$actual" != "$expected" ]; then
  fail "Checksum verification failed."
fi
echo " Checksum verified."

extract_dir="$tmp/extracted"
mkdir -p "$extract_dir"

if [ "$os_name" = "Darwin" ]; then
  if ! command -v ditto >/dev/null 2>&1; then
    fail "ditto is required to install the Mac app."
  fi
  ditto -x -k "$zip_path" "$extract_dir"
  extracted_app="$extract_dir/Lottery Recon.app"
  if [ ! -d "$extracted_app" ]; then
    fail "The release zip did not contain Lottery Recon.app."
  fi
  mkdir -p "$HOME/Applications"
  if [ -e "$install_app" ] || [ -L "$install_app" ]; then
    if ! rm -rf "$install_app"; then
      fail "Could not replace $install_app. Quit Lottery Recon, then run the installer again."
    fi
  fi
  if ! ditto "$extracted_app" "$install_app"; then
    fail "Could not install $install_app. Quit Lottery Recon, then run the installer again."
  fi
  if ! xattr -dr com.apple.quarantine "$install_app"; then
    echo " Could not clear the quarantine flag. macOS may ask you to allow Lottery Recon under Privacy and Security."
  fi
  desktop_link="$HOME/Desktop/Lottery Recon.app"
  mkdir -p "$HOME/Desktop"
  if [ -L "$desktop_link" ] || [ -e "$desktop_link" ]; then
    if ! rm -rf "$desktop_link"; then
      fail "Could not replace the desktop shortcut at $desktop_link. Quit Lottery Recon, then run the installer again."
    fi
  fi
  ln -s "$install_app" "$desktop_link"
  echo ""
  echo " Installed to $install_app"
  echo " Shortcut: $desktop_link"
  echo " Saved runs stay in $data_root"
  echo ""
  echo " Open Lottery Recon from the desktop shortcut."
  echo ""
else
  if command -v unzip >/dev/null 2>&1; then
    unzip -q "$zip_path" -d "$extract_dir"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' "$zip_path" "$extract_dir"
  else
    fail "unzip or python3 is required to extract the release."
  fi
  binary="$extract_dir/LotteryReconLauncher/LotteryReconLauncher"
  if [ ! -f "$binary" ]; then
    fail "The release zip did not contain LotteryReconLauncher."
  fi
  mkdir -p "$(dirname "$install_root")"
  if [ -e "$install_root" ] || [ -L "$install_root" ]; then
    if ! rm -rf "$install_root"; then
      fail "Could not replace $install_root. Quit Lottery Recon, then run the installer again."
    fi
  fi
  mkdir -p "$install_root"
  if ! mv "$extract_dir/LotteryReconLauncher" "$install_root/LotteryReconLauncher"; then
    fail "Could not install $install_root. Quit Lottery Recon, then run the installer again."
  fi
  installed_binary="$install_root/LotteryReconLauncher/LotteryReconLauncher"
  chmod +x "$installed_binary"
  applications_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  desktop_file="$applications_dir/lottery-recon.desktop"
  mkdir -p "$applications_dir"
  cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=Lottery Recon
Exec="${installed_binary}"
Path="$(dirname "$installed_binary")"
Terminal=false
Categories=Office;
EOF
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir" >/dev/null 2>&1 || true
  fi
  echo ""
  echo " Installed to $installed_binary"
  echo " Menu entry: $desktop_file"
  echo " Saved runs stay in $data_root"
  echo ""
  echo " Open Lottery Recon from the application menu."
  echo ""
fi
