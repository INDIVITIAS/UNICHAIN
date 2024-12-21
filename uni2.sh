#!/bin/bash

# ----------------------------
# Цвета и иконки
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

ICON_INSTALL="🛠️"
ICON_RESTART="🔄"
ICON_CHECK="✅"
ICON_LOG_OP_NODE="📜"
ICON_LOG_EXEC_CLIENT="📜"
ICON_DISABLE="⏹️"
ICON_UPDATE="🔄"
ICON_PRIVATE_KEY="🔑"
ICON_EXIT="❌"

# ----------------------------
# Рисование границ
# ----------------------------
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
}

# ----------------------------
# Отображение ASCII-логотипа и социальных ссылок
# ----------------------------
display_ascii() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \\  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\\ \\  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
    echo
    echo -e "${YELLOW}Telegram: https://t.me/CryptalikBTC${RESET}"
    echo -e "${YELLOW}YouTube: https://www.youtube.com/@Cryptalik${RESET}"
    echo -e "${YELLOW}Airdrops и ноды: https://t.me/indivitias${RESET}"
    echo -e ""
    echo -e "${GREEN}Добро пожаловать в интерфейс управления узлом Unichain (Uniswap)!${RESET}"
    echo -e ""
}

# ----------------------------
# Показ меню
# ----------------------------
show_menu() {
    display_ascii
    draw_top_border
    echo -e "    ${YELLOW}Пожалуйста, выберите опцию:${RESET}"
    draw_middle_border
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_RESTART} Перезапустить ноду"
    echo -e "    ${CYAN}3.${RESET} ${ICON_CHECK} Проверить ноду"
    echo -e "    ${CYAN}4.${RESET} ${ICON_LOG_OP_NODE} Проверить логи Uniswap OP Node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_LOG_EXEC_CLIENT} Проверить логи Uniswap Execution Client"
    echo -e "    ${CYAN}6.${RESET} ${ICON_DISABLE} Отключить ноду"
    echo -e "    ${CYAN}7.${RESET} ${ICON_UPDATE} Обновить ноду"
    echo -e "    ${CYAN}8.${RESET} ${ICON_PRIVATE_KEY} Показать приватный ключ"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выход"
    draw_bottom_border
    echo -ne "${YELLOW}Введите ваш выбор [0-8]: ${RESET}"
}

# ----------------------------
# Установить нода
# ----------------------------
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
        cd unichain-node || { echo -e "${RED}❌ Не удалось войти в каталог unichain-node.${RESET}"; return; }

        if [[ -f .env.sepolia ]]; then
            sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://ethereum-sepolia-rpc.publicnode.com|' .env.sepolia
            sed -i 's|^OP_NODE_L1_BEACON=.*$|OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|' .env.sepolia
        else
            echo -e "${RED}❌ Файл .env.sepolia не найден!${RESET}"
            return
        fi

        sudo docker-compose up -d

        echo -e "${GREEN}✅ Нода успешно установлен.${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# ----------------------------
# Обновить ноду
# ----------------------------
update_node() {
    echo -e "${GREEN}🔄 Обновление ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    git -C ${HOMEDIR}/unichain-node/ pull
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Нода обновлена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# ----------------------------
# Показать приватный ключ
# ----------------------------
cat_private() {
    echo -e "${GREEN}🔑 Приватный ключ${RESET}"
    HOMEDIR="$HOME"
    cat ${HOMEDIR}/unichain-node/geth-data/geth/nodekey; echo
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# ----------------------------
# Перезапустить ноду
# ----------------------------
restart_node() {
    echo -e "${GREEN}🔄 Перезапуск ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Нода перезапущен.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# ----------------------------
# Проверить ноду
# ----------------------------
check_node() {
    echo -e "${GREEN}✅ Проверка ноды...${RESET}"
    response=$(curl -s -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
      -H "Content-Type: application/json" http://localhost:8545)
    echo -e "${BLUE}Ответ:${RESET} $response"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# ----------------------------
# Проверить логи OP Node
# ----------------------------
check_logs_op_node() {
    echo -e "${GREEN}📜 Получение логов для unichain-node-op-node-1...${RESET}"
    sudo docker logs unichain-node-op-node-1
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# ----------------------------
# Проверить логи Execution Client
# ----------------------------
check_logs_execution_client() {
    echo -e "${GREEN}📜 Получение логов для unichain-node-execution-client-1...${RESET}"
    sudo docker logs unichain-node-execution-client-1
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# ----------------------------
# Отключить ноду
# ----------------------------
disable_node() {
    echo -e "${GREEN}⏹️ Отключение ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    echo -е "${GREEN}✅ Нода отключена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# ----------------------------
# Основной цикл
# ----------------------------
while true; do
    show_menu
    read choice
    case $choice in
        1)
            install_node
            ;;
        2)
            restart_node
            ;;
        3)
            check_node
            ;;
        4)
            check_logs_op_node
            ;;
        5)
            check_logs_execution_client
            ;;
        6)
            disable_node
            ;;
        7)
            update_node
            ;;
        8)
            cat_private
            ;;
        0)
            echo -е "${GREEN}❌ Выход...${RESET}"
            exit 0
            ;;
        *)
            echo -е "${RED}❌ Неверный вариант. Пожалуйста, попробуйте снова.${RESET}"
            echo
            read -p "Нажмите Enter, чтобы продолжить..."
            ;;
    esac
done
