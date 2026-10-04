#!/bin/bash
# Script thay đổi cổng SSH sang 2222 an toàn cho Ubuntu
set -e

NEW_PORT=2222

echo "=== 1. Mở cổng $NEW_PORT/tcp trên UFW Firewall ==="
sudo ufw allow ${NEW_PORT}/tcp comment 'Custom SSH Port'

echo "=== 2. Cấu hình SSH Daemon sử dụng Port $NEW_PORT ==="
if [ -d "/etc/ssh/sshd_config.d" ]; then
    echo "Port ${NEW_PORT}" | sudo tee /etc/ssh/sshd_config.d/port.conf
else
    sudo sed -i "s/#Port 22/Port ${NEW_PORT}/g" /etc/ssh/sshd_config
    sudo sed -i "s/Port 22/Port ${NEW_PORT}/g" /etc/ssh/sshd_config
fi

echo "=== 3. Kiểm tra cú pháp sshd cấu hình ==="
sudo sshd -t

echo "=== 4. Khởi động lại dịch vụ SSH ==="
sudo systemctl restart ssh || sudo systemctl restart sshd

echo "=== THAY ĐỔI PORT THÀNH CÔNG! Hãy test: ssh -p ${NEW_PORT} devops@<IP> ==="
