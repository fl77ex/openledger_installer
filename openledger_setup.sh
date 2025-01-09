#!/bin/bash

# Удаляем старые версии Docker и обновляем зависимости
sudo apt remove -y docker docker-engine docker.io containerd runc || true
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common || true

# Обновляем источники репозиториев на актуальные зеркала
sudo sed -i 's|http://archive.ubuntu.com/ubuntu|http://mirror.yandex.ru/ubuntu|g' /etc/apt/sources.list || true
sudo sed -i 's|http://security.ubuntu.com/ubuntu|http://mirror.yandex.ru/ubuntu|g' /etc/apt/sources.list || true

# Добавляем ключ Docker и репозиторий
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || true
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || true

# Устанавливаем Docker
sudo apt update || true
sudo apt upgrade -y || true
sudo apt install -y docker-ce docker-ce-cli containerd.io || true

# Устанавливаем зависимости
sudo apt install -y libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libsecret-1-0 uuid-runtime unzip screen libgbm1 libasound2 || true

# Скачиваем и устанавливаем OpenLedger Node
wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip -O openledger-node.zip || true
unzip openledger-node.zip || true
sudo dpkg -i openledger-node-1.0.0.deb || sudo apt-get install -f -y || true

# Генерация нового machine-id
sudo rm -f /etc/machine-id || true
uuidgen | tr -d '-' | sudo tee /etc/machine-id > /dev/null || true

# Создаём скрипт для запуска ноды в screen
sudo tee /usr/local/bin/start_openledger_node.sh > /dev/null <<EOL
#!/bin/bash
screen -dmS openledger_node bash -c 'openledger-node --no-sandbox --disable-gpu --disable-software-rasterizer --disable-extensions'
EOL
sudo chmod +x /usr/local/bin/start_openledger_node.sh

# Создаём systemd-сервис для автоматического запуска ноды
sudo tee /etc/systemd/system/openledger-node.service > /dev/null <<EOL
[Unit]
Description=OpenLedger Node Service
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/start_openledger_node.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

# Перезагружаем systemd и включаем автозапуск сервиса
sudo systemctl daemon-reload
sudo systemctl enable openledger-node.service
sudo systemctl start openledger-node.service

# Информация для пользователя
echo "Установка завершена. OpenLedger Node запущена в screen-сессии 'openledger_node' и будет запускаться автоматически после перезагрузки сервера."
