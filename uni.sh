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
ICON_RESTART="🔄"
ICON_CHECK="✅"
ICON_LOG_OP_NODE="📜"
ICON_LOG_EXEC_CLIENT="📜"
ICON_DISABLE="⏹️"
ICON_PRIVATE_KEY="🔑"

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

# Вывод ASCII-логотипа и ссылок
display_ascii() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \\  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\\ \\  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
    echo -e ""
    echo -e "${YELLOW}Подписывайтесь на Telegram: https://t.me/CryptalikBTC${RESET}"
    echo -e "${YELLOW}Подписывайтесь на YouTube: https://www.youtube.com/@Cryptalik${RESET}"
    echo -e "${YELLOW}Здесь про аирдропы и ноды: https://t.me/indivitias${RESET}"
    echo -e "${YELLOW}Купи мне крипто бутылочку... ${ICON_KEFIR}кефира 😏${RESET} ${MAGENTA} 👉  https://bit.ly/4eBbfIr  👈 ${MAGENTA}"
    echo -e ""
}

# Проверка зависимостей
check_dependencies() {
    for cmd in curl docker docker-compose git; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}❌ Необходимая зависимость '$cmd' не установлена. Пожалуйста, установите её.${RESET}"
            exit 1
        fi
    done
}

# Функции
download_node() {
    echo 'Начинаю установку...'
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install make build-essential unzip lz4 gcc git jq -y
    sudo apt install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    git clone https://github.com/Uniswap/unichain-node || { echo -e "${RED}Не удалось клонировать репозиторий.${RESET}"; return; }
    cd unichain-node || { echo -e "${RED}Не получилось зайти в директорию.${RESET}"; return; }
    if [[ -f .env.sepolia ]]; then
        sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://ethereum-sepolia-rpc.publicnode.com|' .env.sepolia
        sed -i 's|^OP_NODE_L1_BEACON=.*$|OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|' .env.sepolia
    else
        echo -e "${RED}Sepolia ENV не было найдено.${RESET}"
        return
    fi
    sudo docker-compose up -d || { echo -e "${RED}Не удалось запустить docker-compose.${RESET}"; return; }
    echo -e "${GREEN}✅ Нода успешно установлена.${RESET}"
    read -p "Нажми Enter для возврата в меню..."
}

restart_node() {
    echo -e "${GREEN}🔄 Перезапуск ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Нода перезапущена.${RESET}"
    read -p "Нажми Enter для возврата в меню..."
}

check_node() {
    echo -e "${GREEN}✅ Проверка статуса ноды...${RESET}"
    response=$(curl -s -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
      -H "Content-Type: application/json" http://localhost:8545)
    if [[ -n "$response" ]]; then
        echo -e "${BLUE}Ответ:${RESET} $response"
    else
        echo -e "${RED}❌ Нода не отвечает.${RESET}"
    fi
    read -p "Нажми Enter для возврата в меню..."
}

check_logs_op_node() {
    echo -e "${GREEN}📄 Проверка логов для unichain-node-op-node-1...${RESET}"
    sudo docker logs unichain-node-op-node-1 || { echo -e "${RED}❌ Не удалось получить логи.${RESET}"; }
    read -p "Нажми Enter для возврата в меню..."
}

check_logs_execution_client() {
    echo -e "${GREEN}📄 Проверка логов для unichain-node-execution-client-1...${RESET}"
    sudo docker logs unichain-node-execution-client-1 || { echo -e "${RED}❌ Не удалось получить логи.${RESET}"; }
    read -p "Нажми Enter для возврата в меню..."
}

disable_node() {
    echo -e "${GREEN}⏹️ Остановка ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down || { echo -e "${RED}❌ Не удалось остановить ноду.${RESET}"; }
    echo -e "${GREEN}✅ Нода была остановлена.${RESET}"
    read -p "Нажми Enter для возврата в меню..."
}

display_private_key() {
    if [[ -f "$HOME/unichain-node/geth-data/geth/nodekey" ]]; then
        echo -e "${YELLOW}Ваш приватник:${RESET} \n"
        cat "$HOME/unichain-node/geth-data/geth/nodekey"
    else
        echo -e "${RED}❌ Приватный ключ не найден.${RESET}"
    fi
    read -p "Нажми Enter для возврата в меню..."
}

# Основной цикл меню
check_dependencies
while true; do
    draw_top_border
    display_ascii
    draw_middle_border
    echo -e "    ${YELLOW}Сделай свой выбор:${RESET}"
    echo
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_RESTART} Перезапустить ноду"
    echo -e "    ${CYAN}3.${RESET} ${ICON_CHECK} Проверить ноду"
    echo -e "    ${CYAN}4.${RESET} ${ICON_LOG_OP_NODE} Проверить логи для unichain node op node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_LOG_EXEC_CLIENT} Проверить логи для unichain node execution client"
    echo -e "    ${CYAN}6.${RESET} ${ICON_DISABLE} Остановить ноду"
    echo -e "    ${CYAN}7.${RESET} ${ICON_PRIVATE_KEY} Показать приватник"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выход"
    echo
    draw_bottom_border
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}              ${YELLOW}Сюда вводи [0-7]:${RESET}           ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
    read -p " " choice

    case $choice in
        1) download_node ;;
        2) restart_node ;;
        3) check_node ;;
        4) check_logs_op_node ;;
        5) check_logs_execution_client ;;
        6) disable_node ;;
        7) display_private_key ;;
        0) 
            echo -e "${GREEN}❌ Выход...${RESET}"
            exit 0 
            ;;
        *) 
            echo -e "${RED}❌ Неверный ввод. Пробуй еще.${RESET}"
            ;;
    esac
done
