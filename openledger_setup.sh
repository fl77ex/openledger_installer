#!/bin/bash

# Обновляем и удаляем старые версии Docker
sudo apt remove -y docker docker-engine docker.io containerd runc || true
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common || true

# Добавляем ключ Docker и репозиторий
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || true
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Устанавливаем Docker
sudo apt update || true
sudo apt upgrade -y || true
sudo apt install -y docker-ce docker-ce-cli containerd.io || true
sudo docker --version || true

# Устанавливаем необходимые зависимости
sudo apt install -y libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libsecret-1-0 || true

# Скачиваем и устанавливаем OpenLedger Node
wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip || true
sudo apt install -y unzip || true
sudo apt install -y screen || true
unzip openledger-node-1.0.0-linux.zip || true
sudo dpkg -i openledger-node-1.0.0.deb || true
sudo apt-get install -f -y || true

# Игнорируем ошибки
sudo apt-get install -y desktop-file-utils || true
sudo dpkg --configure -a || true

# Генерация нового machine-id
sudo rm -f /etc/machine-id
uuidgen | tr -d '-' | sudo tee /etc/machine-id > /dev/null

# Запускаем ноду в screen
screen -dmS openledger_node bash -c 'openledger-node --no-sandbox --disable-gpu --disable-software-rasterizer --disable-extensions'

# Устанавливаем дополнительные зависимости
sudo apt-get install -y libgbm1 || true
sudo apt-get install -y libasound2 || true

# Инструкция для пользователя
echo "Установка завершена. OpenLedger Node запущен в screen-сессии 'openledger_node'."
