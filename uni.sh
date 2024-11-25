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

# Функция для установки Docker
install_docker() {
    echo -e "${GREEN}🟢 Проверка и установка Docker...${RESET}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker не найден. Устанавливаем Docker...${RESET}"

        sudo apt update
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io

        sudo systemctl start docker
        sudo systemctl enable docker
        
        echo -e "${GREEN}✅ Docker успешно установлен!${RESET}"
    else
        echo -e "${GREEN}Docker уже установлен.${RESET}"
    fi
}

# Функция для исправления прерванных установок
fix_dpkg() {
    echo -e "${GREEN}🟢 Исправляем прерванные установки пакетов...${RESET}"
    sudo dpkg --configure -a
    sudo apt update
    sudo apt upgrade -y
    echo -e "${GREEN}✅ Прерванные установки исправлены.${RESET}"
}

# Функция установки ноды
install_node() {
    cd
    if docker ps -a --format '{{.Names}}' | grep -q "^unichain-node-execution-client-1$"; then
        echo -e "${YELLOW}🟡 Нода уже установлена.${RESET}"
    else
        echo -e "${GREEN}🟢 Установка ноды...${RESET}"

        fix_dpkg
        install_docker

        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        git clone https://github.com/INDIVITIAS/UNICHAIN.git
        cd UNICHAIN || { echo -e "${RED}❌ Не удалось войти в директорию UNICHAIN.${RESET}"; return; }

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
    sudo docker-compose -f "${HOMEDIR}/UNICHAIN/docker-compose.yml" down
    echo -e "${GREEN}✅ Нода остановлена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция запуска ноды
start_node() {
    echo -e "${GREEN}▶️ Запуск ноды...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/UNICHAIN/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Нода запущена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция изменения RPC
change_rpc() {
    echo -e "${CYAN}🔄 Изменение RPC...${RESET}"
    HOMEDIR="$HOME"
    if [[ -f "${HOMEDIR}/UNICHAIN/.env.sepolia" ]]; then
        sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://new-rpc-url|' "${HOMEDIR}/UNICHAIN/.env.sepolia"
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
    sudo docker-compose -f "${HOMEDIR}/UNICHAIN/docker-compose.yml" down
    sudo rm -rf "${HOMEDIR}/UNICHAIN"
    echo -e "${GREEN}✅ Нода удалена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция отображения приватного ключа
display_private_key() {
    HOMEDIR="$HOME"
    echo -e "${YELLOW}Ваш приватный ключ:${RESET}"
    if [[ -f "${HOMEDIR}/UNICHAIN/geth-data/geth/nodekey" ]]; then
        cat "${HOMEDIR}/UNICHAIN/geth-data/geth/nodekey"
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
    echo -e "${YELLOW}1. Установить ноду${RESET}"
    echo -e "${YELLOW}2. Запустить ноду${RESET}"
    echo -e "${YELLOW}3. Остановить ноду${RESET}"
    echo -e "${YELLOW}4. Просмотреть логи${RESET}"
    echo -e "${YELLOW}5. Изменить RPC${RESET}"
    echo -e "${YELLOW}6. Удалить ноду${RESET}"
    echo -e "${YELLOW}7. Показать приватный ключ${RESET}"
    echo -e "${YELLOW}0. Выход${RESET}"
    draw_bottom_border
    read -p "Введите ваш выбор [0-7]: " choice
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
            ;;
    esac
done
