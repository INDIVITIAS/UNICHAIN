#!/bin/bash

# Определения цветов и форматирования
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Иконки для пунктов меню
ICON_TELEGRAM="🚀"
ICON_INSTALL="🛠️"
ICON_LOGS="📄"
ICON_STOP="⏹️"
ICON_START="▶️"
ICON_WALLET="💰"
ICON_EXIT="❌"
ICON_CHANGE_RPC="🔄"
ICON_DELETE="🗑️"
ICON_KEFIR="🍼"

# Функции для рисования границ
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
}
print_telegram_icon() {
    echo -e "          ${MAGENTA}${ICON_TELEGRAM} Подписывайтесь на наш Telegram!${RESET}"
}

# Логотип и информация
display_ascii() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\ \  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
    echo -e ""
    echo -e "${YELLOW}Подписывайтесь на Telegram: https://t.me/CryptalikBTC${RESET}"
    echo -e "${YELLOW}Подписывайтесь на YouTube: https://www.youtube.com/@Cryptalik${RESET}"
    echo -e "${YELLOW}Здесь про аирдропы и ноды: https://t.me/indivitias${RESET}"
    echo -e "${YELLOW}Купи мне крипто бутылочку... ${ICON_KEFIR}кефира 😏${RESET} ${MAGENTA} 👉  https://bit.ly/4eBbfIr  👈 ${MAGENTA}"
    echo -e ""
    echo -e "${CYAN}Полезные команды:${RESET}"
    echo -e "  - ${YELLOW}Просмотр файлов директории:${RESET} ll"
    echo -e "  - ${YELLOW}Вход в директорию:${RESET} cd ocean"
    echo -e "  - ${YELLOW}Выход из директории:${RESET} cd .."
    echo -e "  - ${YELLOW}Запуск меню скрипта (не установка) из директории ocean:${RESET} bash OCEAN1.sh"
    echo -e ""
}

# Функция для получения IP-адреса
get_ip_address() {
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi
    echo "$ip_address"
}

show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    echo -e "    ${BLUE}Криптан, подпишись!: ${YELLOW}https://t.me/indivitias${RESET}"
    draw_middle_border

    # Отображаем текущую рабочую директорию и IP-адрес
    current_dir=$(pwd)
    ip_address=$(get_ip_address)
    echo -e "    ${GREEN}Текущая директория:${RESET} ${current_dir}"
    echo -e "    ${GREEN}IP-адрес:${RESET} ${ip_address}"
    draw_middle_border

# Функция для проверки портов
check_ports() {
    local all_ports_ok=true

    echo -e "${GREEN}Проверка TCP и UDP портов...${RESET}"

    # Проверяем TCP порты
    for port in "${TCP_PORTS[@]}"; do
        if ss -tln | grep -q ":$port "; then
            echo -e "${RED}❌ TCP порт $port занят.${RESET}"
            all_ports_ok=false
        else
            echo -e "${GREEN}✔ TCP порт $port свободен.${RESET}"
        fi
    done

    # Проверяем UDP порты
    for port in "${UDP_PORTS[@]}"; do
        if ss -uln | grep -q ":$port "; then
            echo -e "${RED}❌ UDP порт $port занят.${RESET}"
            all_ports_ok=false
        else
            echo -e "${GREEN}✔ UDP порт $port свободен.${RESET}"
        fi
    done

    if [ "$all_ports_ok" = false ]; then
        echo -e "${RED}Некоторые порты заняты. Освободите их перед выполнением скрипта.${RESET}"
        exit 1
    else
        echo -e "${GREEN}✅ Все порты свободны. Продолжаем выполнение скрипта.${RESET}"
    fi
}

# Функция для установки ноды
install_node() {
    cd
    if docker ps -a --format '{{.Names}}' | grep -q "^unichain-node-execution-client-1$"; then
        echo -e "${YELLOW}🟡 Нода уже установлена.${RESET}"
    else
        echo -e "${GREEN}🛠️ Установка ноды...${RESET}"
        sudo apt update && sudo apt upgrade -y
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker

        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        git clone https://github.com/Uniswap/unichain-node
        cd unichain-node || { echo -e "${RED}❌ Не удалось зайти в директорию unichain-node.${RESET}"; return; }

        if [[ -f .env.sepolia ]]; then
            sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://ethereum-sepolia-rpc.publicnode.com|' .env.sepolia
            sed -i 's|^OP_NODE_L1_BEACON=.*$|OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|' .env.sepolia
        else
            echo -e "${RED}❌ Файл .env.sepolia не найден!${RESET}"
            return
        fi

        sudo docker-compose up -d
        echo -e "${GREEN}✅ Нода успешно установлена.${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

# Остальные функции остаются без изменений (перезапуск, проверка, смена RPC, просмотр логов и т.д.)

# Функция для отображения меню
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_RESTART} Перезапустить ноду"
    echo -e "    ${CYAN}3.${RESET} ${ICON_CHECK} Проверить ноду"
    echo -e "    ${CYAN}4.${RESET} ${ICON_LOG_OP_NODE} Логи OP Node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_LOG_EXEC_CLIENT} Логи Execution Client"
    echo -e "    ${CYAN}6.${RESET} ${ICON_DISABLE} Отключить ноду"
    echo -e "    ${CYAN}7.${RESET} ${ICON_CHANGE_RPC} Сменить RPC"
    echo -e "    ${CYAN}8.${RESET} ${ICON_PRIVATE_KEY} Показать приватный ключ"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выход"
    draw_bottom_border
    echo
    read -p "Выберите действие [0-8]: " choice
}

# Основной цикл меню
while true; do
    check_ports # Проверяем порты перед каждым запуском меню
    show_menu
    case $choice in
        1) install_node ;;
        2) restart_node ;;
        3) check_node ;;
        4) check_logs_op_node ;;
        5) check_logs_execution_client ;;
        6) disable_node ;;
        7) change_rpc ;;
        8) display_private_key ;;
        0)
            echo -e "${GREEN}❌ Выход...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Неверный выбор, попробуйте снова.${RESET}"
            read -p "Нажмите Enter, чтобы продолжить..."
            ;;
    esac
done
