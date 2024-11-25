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
    echo -e "${YELLOW}Купи мне крипто бутылочку... ${ICON_KEFIR}кефира 😏${RESET} ${MAGENTA} 👉  https://bit.ly/4eBbfIr  👈 ${MAGENTA}"
    echo -e ""
    echo -e "${CYAN}Полезные команды:${RESET}"
    echo -e "  - ${YELLOW}Просмотр файлов директории:${RESET} ll"
    echo -e "  - ${YELLOW}Вход в директорию:${RESET} cd ocean"
    echo -e "  - ${YELLOW}Выход из директории:${RESET} cd .."
    echo -e "  - ${YELLOW}Запуск меню скрипта (не установка) из директории ocean:${RESET} bash OCEAN1.sh"
    echo -e ""
}

# Функция для получения IP-адреса
get_ip_address() {
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi
    echo "$ip_address"
}

# Функция для отображения меню
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    echo -e "    ${BLUE}Криптан, подпишись!: ${YELLOW}https://t.me/indivitias${RESET}"
    draw_middle_border

    # Отображаем текущую рабочую директорию и IP-адрес
    current_dir=$(pwd)
    ip_address=$(get_ip_address)
    echo -e "    ${GREEN}Текущая директория:${RESET} ${current_dir}"
    echo -e "    ${GREEN}IP-адрес:${RESET} ${ip_address}"
    draw_middle_border

    echo -e "    ${YELLOW}Выберите действие:${RESET}"
    echo
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_START} Запустить ноду"
    echo -e "    ${CYAN}3.${RESET} ${ICON_LOGS} Просмотреть логи ноды"
    echo -e "    ${CYAN}4.${RESET} ${ICON_STOP} Остановить ноду"
    echo -e "    ${CYAN}5.${RESET} ${ICON_CHANGE_RPC} Сменить RPC"
    echo -e "    ${CYAN}6.${RESET} ${ICON_DELETE} Удалить ноду"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выход"
    echo
    draw_bottom_border
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}          ${YELLOW}Введите ваш выбор [0-6]:${RESET}                ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    read -p " " choice
}

# Примерные функции для пунктов меню
install_node() {
    echo -e "${GREEN}🛠️ Установка ноды...${RESET}"
    # Реализуйте здесь логику установки
    echo -e "${GREEN}✅ Нода успешно установлена!${RESET}"
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

start_node() {
    echo -e "${GREEN}▶️ Запуск ноды...${RESET}"
    # Логика для запуска ноды
    echo -e "${GREEN}✅ Нода запущена!${RESET}"
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

view_logs() {
    echo -e "${GREEN}📄 Просмотр логов ноды...${RESET}"
    # Логика для просмотра логов
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

stop_node() {
    echo -e "${RED}⏹️ Остановка ноды...${RESET}"
    # Логика для остановки ноды
    echo -e "${GREEN}✅ Нода остановлена!${RESET}"
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

change_rpc() {
    echo -e "${BLUE}🔄 Смена RPC...${RESET}"
    # Логика для смены RPC
    echo -e "${GREEN}✅ RPC успешно изменён!${RESET}"
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

delete_node() {
    echo -e "${RED}🗑️ Удаление ноды...${RESET}"
    # Логика для удаления ноды
    echo -e "${GREEN}✅ Нода успешно удалена!${RESET}"
    read -p "Нажмите Enter, чтобы вернуться в меню..."
}

# Основной цикл работы меню
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) start_node ;;
        3) view_logs ;;
        4) stop_node ;;
        5) change_rpc ;;
        6) delete_node ;;
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
