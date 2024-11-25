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
ICON_RESTART="🔄"
ICON_CHECK="✅"
ICON_LOG_OP_NODE="📄"
ICON_LOG_EXEC_CLIENT="📄"
ICON_DISABLE="⏹️"
ICON_EXIT="❌"

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
    echo -e ""
}

# Функция для отображения меню
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    draw_middle_border
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_RESTART} Перезапустить ноду"
    echo -e "    ${CYAN}3.${RESET} ${ICON_CHECK} Проверить статус ноды"
    echo -e "    ${CYAN}4.${RESET} ${ICON_LOG_OP_NODE} Логи OP Node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_LOG_EXEC_CLIENT} Логи Execution Client"
    echo -e "    ${CYAN}6.${RESET} ${ICON_DISABLE} Отключить ноду"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выход"
    draw_bottom_border
    echo
    read -p "Выберите действие [0-6]: " choice
}

# Установка ноды
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
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

# Перезапуск ноды
restart_node() {
    echo -e "${GREEN}🔄 Перезапуск ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Нода была перезапущена.${RESET}"
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

# Проверка статуса ноды
check_node() {
    echo -e "${GREEN}✅ Проверка статуса ноды...${RESET}"
    response=$(curl -s -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
      -H "Content-Type: application/json" http://localhost:8545)
    echo -e "${BLUE}Ответ:${RESET} $response"
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

# Логи OP Node
check_logs_op_node() {
    echo -e "${GREEN}📄 Логи OP Node...${RESET}"
    sudo docker logs unichain-node-op-node-1
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

# Логи Execution Client
check_logs_execution_client() {
    echo -e "${GREEN}📄 Логи Execution Client...${RESET}"
    sudo docker logs unichain-node-execution-client-1
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

# Отключение ноды
disable_node() {
    echo -e "${GREEN}⏹️ Отключение ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    echo -e "${GREEN}✅ Нода была отключена.${RESET}"
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

# Основной цикл меню
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) restart_node ;;
        3) check_node ;;
        4) check_logs_op_node ;;
        5) check_logs_execution_client ;;
        6) disable_node ;;
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