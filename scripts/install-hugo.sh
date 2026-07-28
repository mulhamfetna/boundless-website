#!/usr/bin/env bash
#
# Downloads the exact Hugo version named in .hugoversion into .tools/.
#
# Why a project-local binary rather than the system package: the theme declares a
# supported Hugo range, and a distribution package drifts independently of this
# repository. Pinning the binary here means you, a future volunteer, and Cloudflare
# all build with the identical version.
#
# Idempotent — exits immediately if the correct binary is already present.
set -euo pipefail

cd "$(dirname "$0")/.."

version="$(cat .hugoversion)"
target_dir=".tools/hugo-${version}"
binary="${target_dir}/hugo"

if [ -x "$binary" ]; then
  exit 0
fi

case "$(uname -s)" in
  Linux)  os="linux" ;;
  Darwin) os="darwin" ;;
  *) echo "Unsupported OS: $(uname -s). Install Hugo ${version} extended manually." >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64)  arch="amd64" ;;
  aarch64|arm64) arch="arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)." >&2; exit 1 ;;
esac

# macOS builds ship as a single universal binary.
if [ "$os" = "darwin" ]; then
  asset="hugo_extended_${version}_darwin-universal.tar.gz"
else
  asset="hugo_extended_${version}_${os}-${arch}.tar.gz"
fi

url="https://github.com/gohugoio/hugo/releases/download/v${version}/${asset}"

echo "Downloading Hugo ${version} extended (${os}-${arch})..."
mkdir -p "$target_dir"
curl -fsSL "$url" | tar -xz -C "$target_dir" hugo
chmod +x "$binary"

echo "Installed: $("$binary" version)"
