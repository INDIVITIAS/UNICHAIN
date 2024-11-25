#!/bin/bash

# Определение цветов
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Иконки для меню
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

# Функция для вывода информации о Telegram
print_telegram_icon() {
    echo -e "          ${MAGENTA}${ICON_TELEGRAM} Подписывайтесь на наш Telegram!${RESET}"
}

# Вывод ASCII-логотипа и ссылок
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
    echo -e "  - ${YELLOW}Просмотр файлов директории:${RESET} ls"
    echo -e "  - ${YELLOW}Вход в директорию:${RESET} cd docker-browser"
    echo -e "  - ${YELLOW}Выход из директории:${RESET} cd .."
    echo -e ""
}

# Получение IP-адреса
get_ip_address() {
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi
    echo "$ip_address"
}

# Функция установки ноды
install_node() {
    cd
    if docker ps -a --format '{{.Names}}' | grep -q "^unichain-node-execution-client-1$"; then
        echo -e "${YELLOW}🟡 Нода уже установлена.${RESET}"
    else
        echo -e "${GREEN}🟢 Установка ноды...${RESET}"
        sudo apt update && sudo apt upgrade -y
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker

        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        git clone https://github.com/Uniswap/unichain-node
        cd unichain-node || { echo -e "${RED}❌ Не удалось войти в директорию unichain-node.${RESET}"; return; }

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
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция остановки ноды
stop_node() {
    echo -e "${GREEN}⏹️ Остановка ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    echo -e "${GREEN}✅ Нода остановлена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция запуска ноды
start_node() {
    echo -e "${GREEN}▶️ Запуск ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Нода запущена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция изменения RPC
change_rpc() {
    echo -e "${CYAN}🔄 Изменение RPC...${RESET}"
    HOMEDIR="$HOME"
    if [[ -f "${HOMEDIR}/unichain-node/.env.sepolia" ]]; then
        sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://new-rpc-url|' "${HOMEDIR}/unichain-node/.env.sepolia"
        echo -e "${GREEN}✅ RPC изменен.${RESET}"
    else
        echo -e "${RED}❌ Файл .env.sepolia не найден!${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция удаления ноды
delete_node() {
    echo -e "${RED}🗑️ Удаление ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo rm -rf "${HOMEDIR}/unichain-node"
    echo -e "${GREEN}✅ Нода удалена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция отображения приватного ключа
display_private_key() {
    HOMEDIR="$HOME"
    echo -e "${YELLOW}Ваш приватный ключ:${RESET}"
    if [[ -f "${HOMEDIR}/unichain-node/geth-data/geth/nodekey" ]]; then
        cat "${HOMEDIR}/unichain-node/geth-data/geth/nodekey"
    else
        echo -e "${RED}❌ Файл с приватным ключом не найден!${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Основное меню
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    echo -e "    ${BLUE}Криптан, подпишись!: ${YELLOW}https://t.me/indivitias${RESET}"
    draw_middle_border

    # Текущая директория и IP-адрес
    current_dir=$(pwd)
    ip_address=$(get_ip_address)
    echo -e "    ${GREEN}Текущая директория:${RESET} ${current_dir}"
    echo -e "    ${GREEN}IP-адрес:${RESET} ${ip_address}"
    draw_middle_border

    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_START} Запустить ноду"
    echo -e "    ${CYAN}3.${RESET} ${ICON_STOP} Остановить ноду"
    echo -e "    ${CYAN}4.${RESET} ${ICON_LOGS} Просмотреть логи"
    echo -e "    ${CYAN}5.${RESET} ${ICON_CHANGE_RPC} Изменить RPC"
    echo -e "    ${CYAN}6.${RESET} ${ICON_DELETE} Удалить ноду"
    echo -e "    ${CYAN}7.${RESET} ${ICON_WALLET} Показать приватный ключ"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выход"
    echo
    draw_bottom_border
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}   ${YELLOW}Введите ваш выбор [0-7]:${RESET}           ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    read -p " " choice
}

# Основной цикл
while true; do
    show_menu
    case $choice in
        1)
            install_node
            ;;
        2)
            start_node
            ;;
        3)
            stop_node
            ;;
        4)
            check_logs_op_node
            ;;
        5)
            change_rpc
            ;;
        6)
            delete_node
            ;;
        7)
            display_private_key
            ;;
        0)
            echo -e "${GREEN}❌ Выход...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Неверный выбор. Попробуйте снова.${RESET}"
            echo
            read -p "Нажмите Enter для продолжения..."
            ;;
    esac
done
