# Linux Chrome Remote Installation Script

这是一个用于在 Ubuntu/Debian 系统上一键安装 Chrome 浏览器并配置远程调试功能的脚本。

## 功能特点

- 自动安装 Google Chrome 浏览器
- 配置 Chrome 远程调试功能
- 设置基本的访问认证
- 自动配置 Nginx 反向代理
- 创建系统服务实现开机自启

## 系统要求

- Ubuntu 18.04+ 或 Debian 10+
- 需要 root 权限
- 确保系统能够访问外网
- 最低配置要求：
  - CPU: 1核心及以上
  - 内存: 至少2GB RAM（推荐4GB以上）
  - 硬盘: 至少2GB可用空间
  - 网络: 稳定的网络连接

## 快速开始

1. 克隆仓库：

```bash
git clone https://github.com/0xbaiwan/linux_install_chrome.git
cd linux_install_chrome
```

2. 添加执行权限：

```bash
chmod +x install_chrome_remote.sh
```

3. 运行安装脚本：

```bash
sudo ./install_chrome_remote.sh
```

4. 按照提示设置访问用户名和密码

## 使用方法

安装完成后，可以通过以下地址访问：
```
http://<服务器IP>:9222
```

### 服务管理

- 检查服务状态：
```bash
sudo systemctl status chrome-remote
```

- 启动服务：
```bash
sudo systemctl start chrome-remote
```

- 停止服务：
```bash
sudo systemctl stop chrome-remote
```

- 重启服务：
```bash
sudo systemctl restart chrome-remote
```

- 查看日志：
```bash
sudo journalctl -u chrome-remote
```

## 安全建议

1. 使用强密码保护访问
2. 建议配置 SSL 证书实现 HTTPS 访问
3. 根据需要限制访问 IP
4. 定期更新系统和 Chrome 浏览器

## 问题排查

如果遇到问题，请检查：

1. 确保 9222 端口未被占用
2. 检查系统防火墙设置
3. 查看服务日志是否有错误信息
4. 确保系统符合最低要求

