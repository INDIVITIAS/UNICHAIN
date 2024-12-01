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

# Функции для операций с нодой
channel_logo() {
    draw_top_border
    display_ascii
    draw_bottom_border
}

download_node() {
    echo 'Начинаю установку...'

    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install make build-essential unzip lz4 gcc git jq -y

    sudo apt install docker.io -y

    sudo systemctl start docker
    sudo systemctl enable docker

    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    git clone https://github.com/Uniswap/unichain-node
    cd unichain-node || { echo -e "Не получилось зайти в директорию"; return; }
  
    if [[ -f .env.sepolia ]]; then
        sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://ethereum-sepolia-rpc.publicnode.com|' .env.sepolia
        sed -i 's|^OP_NODE_L1_BEACON=.*$|OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|' .env.sepolia
    else
        echo -e "Sepolia ENV не было найдено"
        return
    fi

    sudo docker-compose up -d
}

restart_node() {
    sudo docker-compose -f "$HOME/UNICHAIN/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "$HOME/UNICHAIN/unichain-node/docker-compose.yml" up -d
    echo 'Unichain был перезагружен'
}

check_node() {
    response=$(curl -s -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
      -H "Content-Type: application/json" http://localhost:8545)
    echo -e "${BLUE}RESPONSE:${RESET} $response"
}

check_logs_op_node() {
    sudo docker logs unichain-node-op-node-1
}

check_logs_unichain() {
    sudo docker logs unichain-node-execution-client-1
}

stop_node() {
    sudo docker-compose -f "$HOME/UNICHAIN/unichain-node/docker-compose.yml" down
}

display_private_key() {
    cd $HOME/UNICHAIN/unichain-node
    echo -e 'Ваш приватник: \n' && cat unichain-node/geth-data/geth/nodekey
}

exit_from_script() {
    exit 0
}

while true; do
    channel_logo
    sleep 2
    draw_top_border
    echo -e "Меню:"
    echo "1. ${ICON_INSTALL} Установить ноду"
    echo "2. ${ICON_RESTART} Перезагрузить ноду"
    echo "3. ${ICON_CHECK} Проверить ноду"
    echo "4. ${ICON_LOG_OP_NODE} Посмотреть логи Unichain (OP)"
    echo "5. ${ICON_LOGS} Посмотреть логи Unichain"
    echo "6. ${ICON_STOP} Остановить ноду"
    echo "7. ${ICON_PRIVATE_KEY} Посмотреть приватный ключ"
    echo -e "8. ${ICON_EXIT} Выйти из скрипта\n"
    read -p "Выберите пункт меню: " choice

    case $choice in
      1)
        download_node
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
        check_logs_unichain
        ;;
      6)
        stop_node
        ;;
      7)
        display_private_key
        ;;
      8)
        exit_from_script
        ;;
      *)
        echo "Неверный пункт. Пожалуйста, выберите правильную цифру в меню."
        ;;
    esac
done
