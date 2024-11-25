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
    if [[ -f "${HOMEDIR}/.ethereum/keyfile" ]]; then
        cat "${HOMEDIR}/.ethereum/keyfile"
    else
        echo -e "${RED}❌ Приватный ключ не найден!${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Функция просмотра логов ноды
check_logs_op_node() {
    echo -e "${CYAN}📄 Просмотр логов ноды...${RESET}"
    HOMEDIR="$HOME"
    LOGS_FILE="${HOMEDIR}/UNICHAIN/logs/op-node.log"

    if [[ -f "$LOGS_FILE" ]]; then
        cat "$LOGS_FILE"
    else
        echo -e "${RED}❌ Логи не найдены!${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Главное меню
while true; do
    clear
    draw_top_border
    echo -e "${CYAN}Добро пожаловать в утилиту по управлению нодой${RESET}"
    print_telegram_icon
    draw_middle_border
    echo -e "${YELLOW}1) Установить ноду ${ICON_INSTALL}${RESET}"
    echo -e "${YELLOW}2) Запустить ноду ${ICON_START}${RESET}"
    echo -e "${YELLOW}3) Остановить ноду ${ICON_STOP}${RESET}"
    echo -e "${YELLOW}4) Просмотр логов ноды ${ICON_LOGS}${RESET}"
    echo -e "${YELLOW}5) Изменить RPC ${ICON_CHANGE_RPC}${RESET}"
    echo -e "${YELLOW}6) Удалить ноду ${ICON_DELETE}${RESET}"
    echo -e "${YELLOW}7) Показать приватный ключ ${ICON_WALLET}${RESET}"
    echo -e "${YELLOW}8) Выход ${ICON_EXIT}${RESET}"
    draw_bottom_border
    read -p "Выберите действие: " option

    case $option in
        1) install_node ;;
        2) start_node ;;
        3) stop_node ;;
        4) check_logs_op_node ;;
        5) change_rpc ;;
        6) delete_node ;;
        7) display_private_key ;;
        8) exit 0 ;;
        *) echo -e "${RED}❌ Некорректный выбор!${RESET}" ;;
    esac
done
