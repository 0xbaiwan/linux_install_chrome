#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用sudo运行此脚本"
    exit 1
fi

# 更新包列表
apt-get update

# 安装依赖
apt-get install -y wget curl gnupg2 apache2-utils

# 添加Chrome仓库
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# 更新包列表并安装Chrome
apt-get update
apt-get install -y google-chrome-stable

# 创建启动脚本目录
mkdir -p /opt/chrome-remote

# 创建密码文件
read -p "请设置访问用户名: " USERNAME
read -s -p "请设置访问密码: " PASSWORD
echo
htpasswd -bc /opt/chrome-remote/.htpasswd $USERNAME $PASSWORD

# 创建启动脚本
cat > /opt/chrome-remote/start-chrome.sh << 'EOL'
#!/bin/bash
google-chrome --headless --disable-gpu --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0
EOL

# 设置权限
chmod +x /opt/chrome-remote/start-chrome.sh

# 创建systemd服务
cat > /etc/systemd/system/chrome-remote.service << 'EOL'
[Unit]
Description=Chrome Remote Debugging
After=network.target

[Service]
ExecStart=/opt/chrome-remote/start-chrome.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

# 创建nginx配置文件
cat > /etc/nginx/conf.d/chrome-remote.conf << 'EOL'
server {
    listen 9222;
    
    location / {
        auth_basic "Restricted Access";
        auth_basic_user_file /opt/chrome-remote/.htpasswd;
        
        proxy_pass http://127.0.0.1:9222;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
EOL

# 启动服务
systemctl daemon-reload
systemctl enable chrome-remote
systemctl start chrome-remote

# 安装nginx（如果没有）
apt-get install -y nginx
systemctl restart nginx

echo "安装完成！"
echo "请访问 http://<服务器IP>:9222"
echo "使用你设置的用户名和密码登录" 