#!/bin/bash

# Функция для обновления Unichain ноды
update_node() {
    echo 'Начинаю процесс обновления...'

    # Убедимся, что каталог с данными существует
    local NODE_DIR="$HOME/UNICHAIN/unichain-node"
    local BACKUP_DIR="$HOME/UNICHAIN/backup-geth-data"
    if [[ ! -d "$NODE_DIR/geth-data" ]]; then
        echo "Каталог с данными ноды не найден! Убедитесь, что нода была ранее запущена."
        return
    fi

    # Создаем резервную копию приватного ключа
    echo "Создаю резервную копию приватного ключа..."
    mkdir -p "$BACKUP_DIR"
    if [[ -f "$NODE_DIR/geth-data/geth/nodekey" ]]; then
        cp "$NODE_DIR/geth-data/geth/nodekey" "$BACKUP_DIR/nodekey"
        echo "Приватный ключ успешно сохранён в $BACKUP_DIR/nodekey"
    else
        echo "Приватный ключ не найден, продолжение без сохранения!"
    fi

    # Загрузка новых конфигурационных файлов
    echo "Загружаю новые конфигурационные файлы..."
    mkdir -p "$NODE_DIR/configs"
    curl -o "$NODE_DIR/configs/Rollup.json" <URL_TO_ROLLUP_JSON>
    curl -o "$NODE_DIR/configs/genesis-l2.json" <URL_TO_GENESIS_JSON>

    # Переинициализация Geth с сохранением старого ключа
    echo "Переинициализация Geth..."
    geth init --datadir "$NODE_DIR/geth-data" "$NODE_DIR/configs/genesis-l2.json"

    # Восстановление приватного ключа
    if [[ -f "$BACKUP_DIR/nodekey" ]]; then
        echo "Восстанавливаю приватный ключ..."
        cp "$BACKUP_DIR/nodekey" "$NODE_DIR/geth-data/geth/nodekey"
    fi

    # Перезапуск op-geth
    echo "Запускаю op-geth..."
    nohup geth --datadir "$NODE_DIR/geth-data" \
        --bootnodes="enode://..." \
        --http \
        --http.addr "0.0.0.0" \
        --http.port 8545 \
        --http.api "eth,net,web3" \
        &

    # Запуск op-node
    echo "Запускаю op-node..."
    nohup ./op-node --rollup.config="$NODE_DIR/configs/Rollup.json" \
        --p2p.bootnodes="enr:..." \
        &

    echo "Обновление завершено!"
}

# Запуск функции обновления
update_node
