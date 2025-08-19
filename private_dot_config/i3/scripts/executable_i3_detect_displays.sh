#!/bin/bash

# Função para obter o nome do display conectado
get_display() {
    xrandr | grep "^$1.* connected" | awk '{print $1}'
}

# Verificar se o HDMI-1 está conectado
if xrandr | grep -q '^HDMI-1.* connected'; then
    MAIN_DISPLAY=$(get_display "HDMI-1")
    LAPTOP_DISPLAY=$(get_display "eDP-1")
    
    # Verificar se os displays foram encontrados
    if [ -z "$MAIN_DISPLAY" ]; then
        echo "Erro: Display HDMI-1 não encontrado"
        exit 1
    fi
    
    if [ -z "$LAPTOP_DISPLAY" ]; then
        echo "Aviso: Display eDP-1 não encontrado, continuando apenas com HDMI-1"
        LAPTOP_DISPLAY=""
    fi
    
    # Criar e adicionar modo personalizado se não existir
    if ! xrandr | grep -q "2560x1080x49.94"; then
        echo "Criando modo personalizado 2560x1080..."
        xrandr --newmode "2560x1080x49.94"  150.25  2560 2608 2640 2720  1080 1083 1087 1106  +HSync -VSync
        xrandr --addmode "$MAIN_DISPLAY" "2560x1080x49.94"
    fi
    
    # Configurar os displays
    if [ -n "$LAPTOP_DISPLAY" ]; then
        xrandr --output "$LAPTOP_DISPLAY" --mode 1920x1080 --pos 2561x0 --rotate normal \
               --output "$MAIN_DISPLAY" --primary --mode "2560x1080x49.94" --pos 0x0 --rotate normal
    else
        xrandr --output "$MAIN_DISPLAY" --primary --mode "2560x1080x49.94" --pos 0x0 --rotate normal
    fi
    
    echo "Configuração de monitor duplo aplicada com sucesso!"

else
    # Configuração para apenas o display laptop
    LAPTOP_DISPLAY=$(get_display "eDP-1")
    
    if [ -n "$LAPTOP_DISPLAY" ]; then
        xrandr --output "$LAPTOP_DISPLAY" --primary --mode 1920x1080 --pos 0x0 --rotate normal \
               --output DP-1 --off \
               --output DP-2 --off \
               --output HDMI-1 --off \
               --output VIRTUAL-1 --off
        echo "Configuração de monitor único aplicada com sucesso!"
    else
        echo "Erro: Nenhum display encontrado"
        exit 1
    fi
fi
