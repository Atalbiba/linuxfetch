#!/bin/bash

# ============ КОНФИГУРАЦИЯ ============
# Цвета (0-255, или hex #RRGGBB)
COLOR_TITLE="34"           # Синий для заголовков
COLOR_VALUE="36"           # Голубой для значений
COLOR_ACCENT="35"          # Пурпурный для акцентов
COLOR_BAR="32"             # Зеленый для прогресс-баров

# Символы для отображения
SEPARATOR=":"              # Разделитель названия и значения
TITLE_PREFIX="╭─"         # Префикс для заголовков
TITLE_SUFFIX="─╮"         # Суффикс для заголовков

# Флаги отображения (true/false)
SHOW_LOGO=true            # Показывать ASCII-логотип
SHOW_OS=true              # Информация об ОС
SHOW_HOST=true            # Информация о хосте
SHOW_KERNEL=true          # Информация о ядре
SHOW_UPTIME=true          # Время работы
SHOW_PACKAGES=true        # Количество пакетов
SHOW_SHELL=true           # Информация об оболочке
SHOW_CPU=true             # Информация о процессоре
SHOW_GPU=true             # Информация о GPU
SHOW_MEMORY=true          # Использование памяти
SHOW_DISK=true            # Использование диска
SHOW_BATTERY=true         # Информация о батарее
SHOW_COLOR_BLOCKS=true    # Цветовые блоки
SHOW_BAR=true             # Прогресс-бары для памяти/диска

# Настройка логотипа
LOGO_TYPE="arch"          # auto, arch, debian, fedora, ubuntu, tux
LOGO_COLOR="34"           # Цвет логотипа
LOGO_WIDTH=20             # Ширина логотипа (символов)

# Порог для цветов в прогресс-барах
MEMORY_WARN=80            # Порог предупреждения для памяти (%)
DISK_WARN=80              # Порог предупреждения для диска (%)

# ============ ФУНКЦИИ ============

# Функция для окрашивания текста
colorize() {
    local color="$1"
    local text="$2"
    if [[ $color =~ ^[0-9]+$ ]]; then
        echo -e "\033[38;5;${color}m${text}\033[0m"
    elif [[ $color =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        local r=$((16#${color:1:2}))
        local g=$((16#${color:3:2}))
        local b=$((16#${color:5:2}))
        echo -e "\033[38;2;${r};${g};${b}m${text}\033[0m"
    else
        echo "$text"
    fi
}

# Функция прогресс-бара
progress_bar() {
    local percent=$1
    local width=20
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    local bar="["
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    bar+="]"
    
    if [ $percent -ge ${3:-80} ]; then
        colorize "196" "$bar $2%"
    elif [ $percent -ge ${4:-60} ]; then
        colorize "214" "$bar $2%"
    else
        colorize "46" "$bar $2%"
    fi
}

# Функция получения информации об ОС
get_os_info() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    elif command -v lsb_release &> /dev/null; then
        lsb_release -ds
    else
        echo "Unknown OS"
    fi
}

# Функция получения информации о хосте
get_host_info() {
    if [ -f /sys/devices/virtual/dmi/id/product_name ]; then
        cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "Unknown"
    else
        echo "Unknown"
    fi
}

# Функция получения времени работы
get_uptime() {
    local uptime_seconds=$(awk '{print int($1)}' /proc/uptime)
    local days=$((uptime_seconds / 86400))
    local hours=$(( (uptime_seconds % 86400) / 3600 ))
    local minutes=$(( (uptime_seconds % 3600) / 60 ))
    
    if [ $days -gt 0 ]; then
        echo "${days}d ${hours}h ${minutes}m"
    elif [ $hours -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

# Функция получения количества пакетов
get_package_count() {
    if command -v pacman &> /dev/null; then
        pacman -Q | wc -l
    elif command -v dpkg &> /dev/null; then
        dpkg -l | grep -c '^ii'
    elif command -v rpm &> /dev/null; then
        rpm -qa | wc -l
    elif command -v emerge &> /dev/null; then
        qlist -I | wc -l
    elif command -v xbps-query &> /dev/null; then
        xbps-query -l | grep -c '^ii'
    elif command -v apk &> /dev/null; then
        apk info | wc -l
    else
        echo "0"
    fi
}

# Функция получения информации о памяти
get_memory_info() {
    local mem_total=$(free -b | awk '/^Mem:/ {print $2}')
    local mem_used=$(free -b | awk '/^Mem:/ {print $3}')
    local mem_percent=$((mem_used * 100 / mem_total))
    
    local used_gb=$(echo "scale=1; $mem_used/1073741824" | bc)
    local total_gb=$(echo "scale=1; $mem_total/1073741824" | bc)
    
    echo "${used_gb}GB / ${total_gb}GB ($mem_percent%)"
}

# Функция получения информации о диске
get_disk_info() {
    local disk_used=$(df -h / | awk 'NR==2 {print $3}' | sed 's/G/GB/')
    local disk_total=$(df -h / | awk 'NR==2 {print $2}' | sed 's/G/GB/')
    local disk_percent=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    echo "${disk_used} / ${disk_total} ($disk_percent%)"
}

# Функция получения информации о батарее
get_battery_info() {
    if [ -d /sys/class/power_supply/BAT0 ]; then
        local capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        local status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        
        if [ -n "$capacity" ]; then
            if [ "$status" = "Charging" ]; then
                echo "⚡ $capacity%"
            else
                echo "🔋 $capacity%"
            fi
        else
            echo "N/A"
        fi
    else
        echo "N/A"
    fi
}

# Функция отображения цветовых блоков
show_color_blocks() {
    echo -n "  "
    for i in {0..7}; do
        echo -en "\033[48;5;${i}m  \033[0m"
    done
    echo -n " "
    for i in {8..15}; do
        echo -en "\033[48;5;${i}m  \033[0m"
    done
    echo
}

# Функция отображения ASCII-логотипа
show_logo() {
    case $LOGO_TYPE in
        "arch")
            echo -e "$(colorize $LOGO_COLOR '      /\\\\       ')"
            echo -e "$(colorize $LOGO_COLOR '     /  \\\\      ')"
            echo -e "$(colorize $LOGO_COLOR '    / /\\ \\\\     ')"
            echo -e "$(colorize $LOGO_COLOR '   / /  \\ \\\\    ')"
            echo -e "$(colorize $LOGO_COLOR '  / /    \\ \\\\   ')"
            echo -e "$(colorize $LOGO_COLOR ' / / _____\\ \\\\  ')"
            echo -e "$(colorize $LOGO_COLOR '/_/  \`----.\\_\\\\ ')"
            ;;
        "debian")
            echo -e "$(colorize $LOGO_COLOR '  _____      ')"
            echo -e "$(colorize $LOGO_COLOR ' /  __ \\\\     ')"
            echo -e "$(colorize $LOGO_COLOR '|  /    |    ')"
            echo -e "$(colorize $LOGO_COLOR '|  \\\\___-    ')"
            echo -e "$(colorize $LOGO_COLOR '-_          ')"
            echo -e "$(colorize $LOGO_COLOR '  --_       ')"
            ;;
        "fedora")
            echo -e "$(colorize $LOGO_COLOR '     ______     ')"
            echo -e "$(colorize $LOGO_COLOR '   /   __  \\\\   ')"
            echo -e "$(colorize $LOGO_COLOR '  /  |  |  \\\\  ')"
            echo -e "$(colorize $LOGO_COLOR ' /  /    \\  \\\\ ')"
            echo -e "$(colorize $LOGO_COLOR ' \\  \\____/  / ')"
            echo -e "$(colorize $LOGO_COLOR '  \\\\______/   ')"
            ;;
        "ubuntu")
            echo -e "$(colorize $LOGO_COLOR '   _////   ')"
            echo -e "$(colorize $LOGO_COLOR ' _\\\\( )   ')"
            echo -e "$(colorize $LOGO_COLOR '//(__)    ')"
            echo -e "$(colorize $LOGO_COLOR '  )(      ')"
            echo -e "$(colorize $LOGO_COLOR ' (_)      ')"
            ;;
        "tux")
            echo -e "$(colorize $LOGO_COLOR '   .--.      ')"
            echo -e "$(colorize $LOGO_COLOR '  |o_o |     ')"
            echo -e "$(colorize $LOGO_COLOR '  |:_/ |     ')"
            echo -e "$(colorize $LOGO_COLOR ' //   \\ \\    ')"
            echo -e "$(colorize $LOGO_COLOR '(|     | )   ')"
            echo -e "$(colorize $LOGO_COLOR '/ \\\\_  _/ \\\\  ')"
            echo -e "$(colorize $LOGO_COLOR '\\\\(__)(__)/   ')"
            ;;
        *)
            # Автоопределение
            if [ -f /etc/arch-release ]; then
                LOGO_TYPE="arch"
                show_logo
            elif [ -f /etc/debian_version ]; then
                LOGO_TYPE="debian"
                show_logo
            elif [ -f /etc/fedora-release ]; then
                LOGO_TYPE="fedora"
                show_logo
            elif [ -f /etc/lsb-release ] && grep -q Ubuntu /etc/lsb-release; then
                LOGO_TYPE="ubuntu"
                show_logo
            else
                LOGO_TYPE="tux"
                show_logo
            fi
            ;;
    esac
}

# ============ ОСНОВНОЙ ВЫВОД ============

echo "$(colorize $COLOR_TITLE "${TITLE_PREFIX} System Information ${TITLE_SUFFIX}")"
echo

# Логотип и информация в две колонки
if [ "$SHOW_LOGO" = true ]; then
    echo -n "$(show_logo)"
fi

# Информация в колонке
info_lines=()

[ "$SHOW_OS" = true ] && info_lines+=("$(colorize $COLOR_ACCENT "OS")${SEPARATOR} $(colorize $COLOR_VALUE "$(get_os_info)")")
[ "$SHOW_HOST" = true ] && info_lines+=("$(colorize $COLOR_ACCENT "Host")${SEPARATOR} $(colorize $COLOR_VALUE "$(get_host_info)")")
[ "$SHOW_KERNEL" = true ] && info_lines+=("$(colorize $COLOR_ACCENT "Kernel")${SEPARATOR} $(colorize $COLOR_VALUE "$(uname -r)")")
[ "$SHOW_UPTIME" = true ] && info_lines+=("$(colorize $COLOR_ACCENT "Uptime")${SEPARATOR} $(colorize $COLOR_VALUE "$(get_uptime)")")

if [ "$SHOW_PACKAGES" = true ]; then
    pkg_count=$(get_package_count)
    info_lines+=("$(colorize $COLOR_ACCENT "Packages")${SEPARATOR} $(colorize $COLOR_VALUE "$pkg_count")")
fi

[ "$SHOW_SHELL" = true ] && info_lines+=("$(colorize $COLOR_ACCENT "Shell")${SEPARATOR} $(colorize $COLOR_VALUE "$SHELL")")

if [ "$SHOW_CPU" = true ]; then
    cpu_info=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
    info_lines+=("$(colorize $COLOR_ACCENT "CPU")${SEPARATOR} $(colorize $COLOR_VALUE "${cpu_info:0:50}")")
fi

if [ "$SHOW_GPU" = true ] && command -v lspci &> /dev/null; then
    gpu_info=$(lspci | grep -i vga | head -1 | cut -d: -f3 | sed 's/^[ \t]*//')
    [ -n "$gpu_info" ] && info_lines+=("$(colorize $COLOR_ACCENT "GPU")${SEPARATOR} $(colorize $COLOR_VALUE "${gpu_info:0:40}")")
fi

# Вывод информации
for line in "${info_lines[@]}"; do
    if [ "$SHOW_LOGO" = true ]; then
        # Выравнивание с логотипом
        printf "%-40s\n" "$line"
    else
        echo "  $line"
    fi
done

echo

# Прогресс-бары и дополнительная информация
if [ "$SHOW_BAR" = true ]; then
    if [ "$SHOW_MEMORY" = true ]; then
        mem_info=$(free -b)
        mem_total=$(echo "$mem_info" | awk '/^Mem:/ {print $2}')
        mem_used=$(echo "$mem_info" | awk '/^Mem:/ {print $3}')
        mem_percent=$((mem_used * 100 / mem_total))
        
        echo -n "  $(colorize $COLOR_ACCENT "Memory")${SEPARATOR} "
        progress_bar $mem_percent $mem_percent $MEMORY_WARN
    fi
    
    if [ "$SHOW_DISK" = true ]; then
        disk_percent=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        
        echo -n "  $(colorize $COLOR_ACCENT "Disk")${SEPARATOR} "
        progress_bar $disk_percent $disk_percent $DISK_WARN
    fi
else
    [ "$SHOW_MEMORY" = true ] && echo "  $(colorize $COLOR_ACCENT "Memory")${SEPARATOR} $(colorize $COLOR_VALUE "$(get_memory_info)")"
    [ "$SHOW_DISK" = true ] && echo "  $(colorize $COLOR_ACCENT "Disk")${SEPARATOR} $(colorize $COLOR_VALUE "$(get_disk_info)")"
fi

[ "$SHOW_BATTERY" = true ] && echo "  $(colorize $COLOR_ACCENT "Battery")${SEPARATOR} $(colorize $COLOR_VALUE "$(get_battery_info)")"

echo

# Цветовые блоки
[ "$SHOW_COLOR_BLOCKS" = true ] && show_color_blocks

echo "$(colorize $COLOR_TITLE "╰───────────────────────────────╯")"
