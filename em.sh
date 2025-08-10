#!/bin/bash
# ⚡ MX Linux 環境構築スクリプト（選択式）⚡
# i3 + LXQt + XFCE + LightDM + Polybar + Rofi + feh + Xorg
# Waylandを封印しつつログイン時にセッション選択可能

set -e

echo "==> 🛠 システム更新"
sudo apt update && sudo apt full-upgrade -y

echo "==> 📦 必須パッケージインストール"
sudo apt install -y \
    i3 lxqt-core xfce4 \
    lightdm lightdm-gtk-greeter \
    polybar rofi feh \
    xorg xserver-xorg x11-xserver-utils \
    network-manager-gnome \
    pulseaudio pavucontrol \
    vim git curl

echo "==> 🔒 Wayland封印（LightDM設定）"
if grep -q '^#WaylandEnable=false' /etc/lightdm/lightdm.conf; then
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/lightdm/lightdm.conf
elif ! grep -q '^WaylandEnable=false' /etc/lightdm/lightdm.conf; then
    echo 'WaylandEnable=false' | sudo tee -a /etc/lightdm/lightdm.conf
fi

# デフォルトセッション固定は行わない（選択式）
sudo rm -f /etc/lightdm/lightdm.conf.d/10-i3-default.conf 2>/dev/null || true

echo "==> 🎨 i3設定作成"
mkdir -p ~/.config/i3
[ ! -f ~/.config/i3/config ] && cp /etc/i3/config ~/.config/i3/config

echo "==> 📊 Polybar設定作成"
mkdir -p ~/.config/polybar
cat > ~/.config/polybar/config << 'EOF'
[bar/example]
width = 100%
height = 24
background = #222
foreground = #fff
modules-left = date
EOF

echo "==> 🖼 壁紙設定"
mkdir -p ~/Pictures/wallpapers
: > ~/Pictures/wallpapers/default.jpg
feh --bg-scale ~/Pictures/wallpapers/default.jpg || true

echo "==> 🔄 i3起動時にPolybarと壁紙を自動起動"
grep -qxF "exec --no-startup-id polybar example" ~/.config/i3/config || \
    echo 'exec --no-startup-id polybar example' >> ~/.config/i3/config
grep -qxF "exec --no-startup-id feh --bg-scale ~/Pictures/wallpapers/default.jpg" ~/.config/i3/config || \
    echo 'exec --no-startup-id feh --bg-scale ~/Pictures/wallpapers/default.jpg' >> ~/.config/i3/config

echo "✅ 完了！再起動後にLightDMでi3 / LXQt / XFCEを自由に選べる"
