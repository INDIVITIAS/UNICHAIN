#!/bin/bash

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Иконки
ICON_INSTALL="🛠️"
ICON_RESTART="🔄"
ICON_CHECK="✅"
ICON_LOG_OP_NODE="📜"
ICON_LOG_EXEC_CLIENT="📜"
ICON_DISABLE="⏹️"
ICON_UPDATE="🔄"
ICON_PRIVATE_KEY="🔑"
ICON_EXIT="❌"

# Рисование границ
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
}

# Отображение ASCII-логотипа
display_ascii() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \\  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\\ \\  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
    echo
    echo -e "${YELLOW}Telegram: https://t.me/CryptalikBTC${RESET}"
    echo -e "${YELLOW}YouTube: https://www.youtube.com/@Cryptalik${RESET}"
    echo -e "${YELLOW}Airdrops и ноды: https://t.me/indivitias${RESET}"
}

# Меню
show_menu() {
    clear
    draw_top_border
    echo -e "${CYAN}|                          ${YELLOW}UNICHAIN NODE MANAGER                          ${CYAN}|${RESET}"
    draw_middle_border
    echo -e "${CYAN}| ${ICON_INSTALL}  1) Установить Ноду                                                 ${CYAN}|${RESET}"
    echo -e "${CYAN}| ${ICON_RESTART}  2) Перезапустить Ноду                                              ${CYAN}|${RESET}"
    echo -e "${CYAN}| ${ICON_CHECK}  3) Проверить статус Ноды                                           ${CYAN}|${RESET}"
    echo -e "${CYAN}| ${ICON_LOG_OP_NODE}  4) Логи OP Node                                              ${CYAN}|${RESET}"
    echo -e "${CYAN}| ${ICON_LOG_EXEC_CLIENT}  5) Логи Execution Client                                  ${CYAN}|${RESET}"
    echo -e "${CYAN}| ${ICON_DISABLE}  6) Отключить Ноду                                               ${CYAN}|${RESET}"
    echo -e "${CYAN}| ${ICON_UPDATE}  7) Обновить Ноду                                                 ${CYAN}|${RESET}"
    echo -e "${CYAN}| ${ICON_PRIVATE_KEY}  8) Показать приватный ключ                                  ${CYAN}|${RESET}"
    echo -e "${CYAN}| ${ICON_EXIT}  0) Выход                                                          ${CYAN}|${RESET}"
    draw_bottom_border
    echo
    echo -e "${YELLOW}Выберите опцию: ${RESET}"
}

# Функции
install_node() {
    cd
    if docker ps -a --format '{{.Names}}' | grep -q "^unichain-node-execution-client-1$"; then
        echo -e "${YELLOW}🟡 Нода уже установлена.${RESET}"
    else
        echo -e "${GREEN}🟢 Установка Ноды...${RESET}"
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
    read -p "Нажмите Enter для возврата в главное меню..."
}

restart_node() {
    echo -e "${GREEN}🔄 Перезапуск узла...${RESET}"
    sudo docker-compose -f "$HOME/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "$HOME/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Нода перезапущена.${RESET}"
    echo
    read -p "Нажмите Enter для возврата в главное меню..."
}

# Аналогично реализуйте остальные функции:
# update_node, check_node, check_logs_op_node, check_logs_execution_client, disable_node, cat_private

# Основной цикл
while true; do
    show_menu
    read -p "> " choice
    case $choice in
        1) install_node ;;
        2) restart_node ;;
        3) check_node ;;
        4) check_logs_op_node ;;
        5) check_logs_execution_client ;;
        6) disable_node ;;
        7) update_node ;;
        8) cat_private ;;
        0) echo -e "${GREEN}❌ Выход...${RESET}"; exit 0 ;;
        *) echo -e "${RED}❌ Неверный выбор. Попробуйте снова.${RESET}" ;;
    esac
done
