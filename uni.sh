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

# Функция для отображения меню
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    draw_middle_border
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_LOGS} Просмотреть логи"
    echo -e "    ${CYAN}3.${RESET} ${ICON_STOP} Остановить ноду"
    echo -e "    ${CYAN}4.${RESET} ${ICON_PRIVATE_KEY} Показать приватный ключ"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выход"
    draw_bottom_border
    echo
    read -p "Выберите действие [0-4]: " choice
}

# Основной цикл меню
while true; do
    show_menu
    case $choice in
        1) echo "Установка ноды..." ;; # Пример действия
        2) echo "Просмотр логов..." ;; # Пример действия
        3) echo "Остановка ноды..." ;; # Пример действия
        4) echo "Приватный ключ..." ;; # Пример действия
        0) echo -e "${GREEN}❌ Выход...${RESET}"; exit 0 ;;
        *) echo -e "${RED}❌ Неверный выбор, попробуйте снова.${RESET}" ;;
    esac
done
