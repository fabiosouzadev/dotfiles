#!/bin/sh

# Only start this up when this isn't already going.
if xrandr | grep '^HDMI-1.* connected'; then
    MAIN_DISPLAY=$(xrandr | grep '^HDMI-1.* connected' | awk '{print $1;}')
    LAPTOP_DISPLAY=$(xrandr | grep '^eDP-1.* connected' | awk '{print $1;}')

    # Garante que o mode existe (remove se já existir para evitar erro)
    xrandr | grep -q '2560x1080x49.94' && xrandr --rmmode 2560x1080x49.94
    xrandr --rmmode "2560x1080x49.94"
    xrandr --newmode "2560x1080x49.94"  150.25  2560 2608 2640 2720  1080 1083 1087 1106  +HSync -VSync
    xrandr --addmode $MAIN_DISPLAY 2560x1080x49.94
    sleep 1
    xrandr --output $LAPTOP_DISPLAY --mode 1920x1080 --pos 2561x0 --rotate normal --output $MAIN_DISPLAY --primary --mode 2560x1080x49.94 --pos 0x0 --rotate normal
else

  xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output DP-2 --off --output HDMI-1 --off --output VIRTUAL-1 --off
fi
