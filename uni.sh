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
    echo -e "  - ${YELLOW}Запуск меню скрипта (не установка) из корня:${RESET} bash uni.sh"
    echo -e ""
}

# Проверка доступности портов
check_ports() {
    ports_tcp=(30303 8545 8546 9222 9545)
    ports_udp=(30303 9222)
    
    # Проверяем TCP порты
    for port in "${ports_tcp[@]}"; do
        nc -zv 127.0.0.1 $port &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}TCP порт $port доступен${RESET}"
        else
            echo -e "${RED}TCP порт $port занят или недоступен${RESET}"
            return 1
        fi
    done

    # Проверяем UDP порты
    for port in "${ports_udp[@]}"; do
        nc -zvu 127.0.0.1 $port &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}UDP порт $port доступен${RESET}"
        else
            echo -e "${RED}UDP порт $port занят или недоступен${RESET}"
            return 1
        fi
    done
}

# Установить ноду
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
        cd unichain-node || { echo -e "${RED}❌ Не удалось зайти в директорию unichain-node.${RESET}"; return; }

        if [[ -f .env.sepolia ]]; then
            sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://ethereum-sepolia-rpc.publicnode.com|' .env.sepolia
            sed -i 's|^OP_NODE_L1_BEACON=.*$|OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|' .env.sepolia
        else
            echo -e "${RED}❌ Не найден файл .env.sepolia!${RESET}"
            return
        fi

        sudo docker-compose up -d

        echo -e "${GREEN}✅ Нода успешно установлена.${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Перезагрузить ноду
restart_node() {
    echo -e "${GREEN}🔄 Перезагружаем ноду...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Нода была перезагружена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Проверить ноду
check_node() {
    echo -e "${GREEN}✅ Проверка состояния ноды...${RESET}"
    docker ps
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Проверить логи ноды OP
check_logs_op_node() {
    echo -e "${GREEN}✅ Логи ноды OP...${RESET}"
    docker logs -f unichain-node-op-node
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Проверить логи Execution Client
check_logs_execution_client() {
    echo -e "${GREEN}✅ Логи Execution Client...${RESET}"
    docker logs -f unichain-node-execution-client
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Остановить ноду
disable_node() {
    echo -e "${GREEN}⏹️ Останавливаем ноду...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    echo -e "${GREEN}✅ Нода остановлена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Просмотр приватного ключа
view_private_key() {
    cd $HOME
    if [ -f "unichain-node/geth-data/geth/nodekey" ]; then
        echo -e "${CYAN}Ваш приватный ключ: ${RESET}"
        cat unichain-node/geth-data/geth/nodekey
    else
        echo -e "${RED}❌ Приватный ключ не найден!${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Главная логика программы
while true; do
    check_ports
    if [ $? -ne 0 ]; then
        echo -e "${RED}Некоторые порты заняты или недоступны. Скрипт завершает работу.${RESET}"
        exit 1
    fi

    clear
    draw_top_border
    display_ascii
    draw_bottom_border
    echo -e "${CYAN}Выберите действие: ${RESET}"
    echo -e "1) Установить ноду"
    echo -e "2) Перезагрузить ноду"
    echo -e "3) Проверить состояние ноды"
    echo -e "4) Просмотреть логи OP ноды"
    echo -e "5) Просмотреть логи Execution Client"
    echo -e "6) Остановить ноду"
    echo -e "7) Просмотр приватного ключа"
    echo -e "0) Выход"
    read -p "Ваш выбор: " choice

    case $choice in
        1) install_node ;;
        2) restart_node ;;
        3) check_node ;;
        4) check_logs_op_node ;;
        5) check_logs_execution_client ;;
        6) disable_node ;;
        7) view_private_key ;;
        0) break ;;
        *) echo -e "${RED}❌ Неверный выбор. Пожалуйста, выберите число от 0 до 7.${RESET}" ;;
    esac
done
