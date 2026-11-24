# Builds HowlStore from the folder this file is in: makepkg -s, then pacman -U the howlstore file.
# It also builds woofstore, the same files under the store's old package name: WoofStore's updater installs the
# woofstore-*.pkg.tar.* file it builds, and HowlStore then swaps that package for howlstore on its own.
pkgbase=howlstore
pkgname=(howlstore woofstore)
pkgver=2.1.0
pkgrel=1
pkgdesc="Software store and system updater for CachyOS and Arch: Flathub, pacman repositories, AUR and AppImages"
arch=(x86_64)
url="https://github.com/LaskyWolf/howlstore"
license=(GPL-3.0-or-later)
depends=(qt6-base qt6-declarative qqc2-desktop-style libnotify polkit pacman-contrib expac git diffutils breeze-icons archlinux-appstream-data)
makedepends=(cargo)
optdepends=(
  'flatpak: Flathub apps and their updates'
  'paru: AUR packages and their updates'
  'devtools: build AUR packages in a clean chroot'
  'kdialog: password prompts for sudo (zenity works too)'
)
options=(!lto !debug)

build() {
  cd "$startdir"
  export CARGO_TARGET_DIR="$srcdir/target"
  cargo build --release --locked -p howlstore-app
}

_files() {
  install -Dm755 "$srcdir/target/release/howl-store" "$pkgdir/usr/bin/howl-store"
  # The steps that need root, and the polkit actions that give their password dialog HowlStore's messages
  install -Dm755 "$startdir/packaging/howlstore-root" "$pkgdir/usr/lib/howlstore/howlstore-root"
  install -Dm644 "$startdir/packaging/io.github.laskywolf.howlstore.policy" "$pkgdir/usr/share/polkit-1/actions/io.github.laskywolf.howlstore.policy"
  install -Dm644 "$startdir/io.github.laskywolf.HowlStore.desktop" "$pkgdir/usr/share/applications/io.github.laskywolf.HowlStore.desktop"
  install -Dm644 "$startdir/icons/io.github.laskywolf.HowlStore.svg" "$pkgdir/usr/share/icons/hicolor/scalable/apps/io.github.laskywolf.HowlStore.svg"
  install -d "$pkgdir/usr/share/howlstore"
  cp -r "$startdir/metadata" "$pkgdir/usr/share/howlstore/metadata"
  install -Dm644 "$startdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}

package_howlstore() {
  conflicts=(woofstore)
  replaces=(woofstore)
  _files
}

package_woofstore() {
  pkgdesc="WoofStore is now HowlStore: this package brings existing installs over and is replaced by howlstore"
  conflicts=(howlstore)
  _files
  # WoofStore restarts itself from this path after its update
  ln -s howl-store "$pkgdir/usr/bin/woof-store"
}
