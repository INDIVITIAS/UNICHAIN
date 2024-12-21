#!/bin/bash

# ----------------------------
# Определение цветов
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# ----------------------------
# Иконки для меню
# ----------------------------
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

# ----------------------------
# Функции для рисования границ
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
# ASCII-логотип и ссылки
# ----------------------------
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

# ----------------------------
# Отображение меню
# ----------------------------
show_menu() {
    clear
    display_ascii
    draw_top_border
    echo -e "    ${YELLOW}Выберите действие:${RESET}"
    draw_middle_border
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_RESTART} Перезапустить ноду"
    echo -e "    ${CYAN}3.${RESET} ${ICON_CHECK} Проверить ноду"
    echo -e "    ${CYAN}4.${RESET} ${ICON_LOG_OP_NODE} Логи OP Node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_LOG_EXEC_CLIENT} Логи Execution Client"
    echo -e "    ${CYAN}6.${RESET} ${ICON_DISABLE} Отключить ноду"
    echo -e "    ${CYAN}7.${RESET} ${ICON_INSTALL} Обновить ноду"
    echo -e "    ${CYAN}8.${RESET} ${ICON_PRIVATE_KEY} Показать приватный ключ"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выйти"
    draw_bottom_border
    echo -ne "${YELLOW}Введите ваш выбор [0-8]: ${RESET}"
}

# ----------------------------
# Функции действий
# ----------------------------
install_node() {
    if docker ps -a --format '{{.Names}}' | grep -q "^unichain-node-execution-client-1$"; then
        echo -e "${YELLOW}🟡 Нода уже установлена.${RESET}"
    else
        echo -e "${GREEN}🟢 Устанавливаем ноду...${RESET}"
        # Добавьте сюда код установки ноды
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

restart_node() {
    echo -e "${CYAN}Перезапускаем ноду...${RESET}"
    # Добавьте код перезапуска
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

check_node() {
    echo -e "${CYAN}Проверяем статус ноды...${RESET}"
    # Добавьте код проверки статуса ноды
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

check_logs_op_node() {
    echo -e "${CYAN}Отображение логов OP Node...${RESET}"
    # Добавьте код вывода логов OP Node
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

check_logs_execution_client() {
    echo -e "${CYAN}Отображение логов Execution Client...${RESET}"
    # Добавьте код вывода логов Execution Client
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

disable_node() {
    echo -e "${RED}Отключаем ноду...${RESET}"
    # Добавьте код отключения ноды
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

update_node() {
    echo -e "${CYAN}Обновляем ноду...${RESET}"
    # Добавьте код обновления ноды
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

cat_private() {
    echo -e "${CYAN}Отображение приватного ключа...${RESET}"
    # Добавьте код для отображения приватного ключа
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
        1) install_node ;;
        2) restart_node ;;
        3) check_node ;;
        4) check_logs_op_node ;;
        5) check_logs_execution_client ;;
        6) disable_node ;;
        7) update_node ;;
        8) cat_private ;;
        0) 
            echo -e "${GREEN}❌ Выход...${RESET}"
            exit 0
            ;;
        *) 
            echo -e "${RED}❌ Неверный выбор. Попробуйте снова.${RESET}"
            ;;
    esac
done
