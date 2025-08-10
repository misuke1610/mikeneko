#!/bin/bash
# 💀 破壊→再構築 MX Linux 合体儀式 💀

set -e

echo "⚠ GUI環境を完全削除します（Xorg / LightDM / XFCE）"
sudo apt remove --purge -y xorg xserver-xorg* lightdm lightdm-gtk-greeter xfce4 xfce4-*  
sudo apt autoremove --purge -y
sudo apt clean

echo "==> 🛠 システム更新"
sudo apt update && sudo apt full-upgrade -y

echo "==> 📦 必須パッケージ再インストール"
sudo apt install -y \
    i3 lxqt-core xfce4 \
    lightdm lightdm-gtk-greeter \
    polybar rofi feh \
    xorg xserver-xorg x11-xserver-utils \
    network-manager-gnome \
    pulseaudio pavucontrol \
    openssh-server \
    fonts-noto fonts-noto-color-emoji fonts-noto-mono \
    vim git curl

echo "==> 🔒 Wayland封印（LightDM設定）"
if grep -q '^#WaylandEnable=false' /etc/lightdm/lightdm.conf; then
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/lightdm/lightdm.conf
elif ! grep -q '^WaylandEnable=false' /etc/lightdm/lightdm.conf; then
    echo 'WaylandEnable=false' | sudo tee -a /etc/lightdm/lightdm.conf
fi

sudo rm -f /etc/lightdm/lightdm.conf.d/10-i3-default.conf 2>/dev/null || true

echo "==> 🔑 SSH自動起動とファイアウォール設定"
sudo systemctl enable ssh
sudo systemctl start ssh
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow 22/tcp
fi

echo "==> 🎨 i3設定作成"
mkdir -p ~/.config/i3
[ ! -f ~/.config/i3/config ] && cp /etc/i3/config ~/.config/i3/config

echo "==> 📊 Polybar設定作成（ランチャー付き）"
mkdir -p ~/.config/polybar
cat > ~/.config/polybar/config << 'EOF'
[bar/example]
width = 100%
height = 24
background = #222
foreground = #fff
font-0 = "Noto Sans:size=10;2"

modules-left = launcher date

[module/launcher]
type = custom/text
content = ""
click-left = rofi -show drun

[module/date]
type = internal/date
interval = 1
date = %Y-%m-%d %H:%M:%S
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

echo "==> 🌐 SSH接続情報"
ip addr show | grep "inet " | grep -v 127.0.0.1

echo "✅ 儀式完了！再起動後はLightDMでセッション選択可能＆Polybarランチャー動作OK"
