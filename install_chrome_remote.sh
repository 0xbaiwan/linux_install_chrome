#!/bin/bash

# 版本信息
VERSION="1.0.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查系统配置
check_system_requirements() {
    # 检查内存
    total_mem=$(free -m | awk '/^Mem:/{print $2}')
    if [ $total_mem -lt 2048 ]; then
        echo -e "${RED}错误: 系统内存不足。Chrome 需要至少 2GB 内存才能正常运行${NC}"
        echo -e "${YELLOW}当前系统内存: ${total_mem}MB${NC}"
        exit 1
    fi

    # 检查磁盘空间
    free_space=$(df -m / | awk 'NR==2 {print $4}')
    if [ $free_space -lt 2048 ]; then
        echo -e "${RED}错误: 磁盘空间不足。需要至少 2GB 可用空间${NC}"
        echo -e "${YELLOW}当前可用空间: ${free_space}MB${NC}"
        exit 1
    fi

    # 检查CPU核心数
    cpu_cores=$(nproc)
    if [ $cpu_cores -lt 1 ]; then
        echo -e "${YELLOW}警告: 建议使用至少1核CPU${NC}"
    fi
}

# 检查root权限
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}错误: 请使用sudo运行此脚本${NC}"
        exit 1
    fi
}

# 安装Chrome
install_chrome() {
    echo -e "${GREEN}开始安装 Chrome 远程调试服务...${NC}"
    
    # 更新包列表
    apt-get update

    # 安装依赖
    apt-get install -y wget curl gnupg2 apache2-utils nginx

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
    systemctl restart nginx

    echo -e "${GREEN}安装完成！${NC}"
    echo "请访问 http://<服务器IP>:9222"
    echo "使用设置的用户名和密码登录"
}

# 删除Chrome
uninstall_chrome() {
    echo -e "${YELLOW}正在卸载 Chrome 远程调试服务...${NC}"
    
    # 停止并禁用服务
    systemctl stop chrome-remote
    systemctl disable chrome-remote
    
    # 删除文件
    rm -rf /opt/chrome-remote
    rm -f /etc/systemd/system/chrome-remote.service
    rm -f /etc/nginx/conf.d/chrome-remote.conf
    
    # 卸载Chrome
    apt-get remove -y google-chrome-stable
    apt-get autoremove -y
    
    # 删除Chrome仓库
    rm -f /etc/apt/sources.list.d/google-chrome.list
    
    systemctl daemon-reload
    systemctl restart nginx
    
    echo -e "${GREEN}卸载完成！${NC}"
}

# 显示菜单
show_menu() {
    echo -e "${GREEN}Chrome 远程调试服务管理脚本 v${VERSION}${NC}"
    echo "=============================="
    echo "1. 安装 Chrome 远程调试服务"
    echo "2. 检查服务状态"
    echo "3. 启动服务"
    echo "4. 停止服务"
    echo "5. 重启服务"
    echo "6. 查看服务日志"
    echo "7. 卸载服务"
    echo "0. 退出"
    echo "=============================="
    read -p "请输入选项 [0-7]: " choice
}

# 主程序
main() {
    check_root
    
    while true; do
        show_menu
        case $choice in
            1)
                check_system_requirements
                install_chrome
                ;;
            2)
                systemctl status chrome-remote
                ;;
            3)
                systemctl start chrome-remote
                echo -e "${GREEN}服务已启动${NC}"
                ;;
            4)
                systemctl stop chrome-remote
                echo -e "${YELLOW}服务已停止${NC}"
                ;;
            5)
                systemctl restart chrome-remote
                echo -e "${GREEN}服务已重启${NC}"
                ;;
            6)
                journalctl -u chrome-remote
                ;;
            7)
                read -p "确定要卸载吗？(y/n) " confirm
                if [ "$confirm" = "y" ]; then
                    uninstall_chrome
                fi
                ;;
            0)
                echo -e "${GREEN}感谢使用！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效的选项，请重试${NC}"
                ;;
        esac
        echo
        read -p "按回车键继续..."
    done
}

# 运行主程序
main 
