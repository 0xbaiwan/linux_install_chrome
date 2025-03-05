# Linux Chrome Remote Installation Script

这是一个用于在 Ubuntu/Debian 系统上一键安装 Chrome 浏览器并配置远程调试功能的脚本。

## 功能特点

- 自动安装 Google Chrome 浏览器
- 配置 Chrome 远程调试功能
- 设置基本的访问认证
- 自动配置 Nginx 反向代理
- 创建系统服务实现开机自启
- 交互式管理菜单
- 完整的服务管理功能
- 支持一键卸载

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

3. 运行脚本：

```bash
sudo ./install_chrome_remote.sh
```

## 使用说明

### 交互式菜单选项

运行脚本后，你将看到以下菜单选项：

1. 安装 Chrome 远程调试服务
   - 自动检查系统要求
   - 安装所需组件
   - 配置服务和认证

2. 检查服务状态
   - 显示当前服务运行状态
   - 查看服务详细信息

3. 启动服务
   - 启动 Chrome 远程调试服务

4. 停止服务
   - 停止 Chrome 远程调试服务

5. 重启服务
   - 重新启动服务

6. 查看服务日志
   - 显示详细的服务运行日志

7. 卸载服务
   - 完全删除所有组件
   - 清理系统配置

0. 退出程序

### 远程访问

安装完成后，可以通过以下地址访问：
```
http://<服务器IP>:9222
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

### 常见问题解决

1. 服务无法启动
   - 检查系统日志: `journalctl -u chrome-remote`
   - 确认内存使用情况: `free -m`
   - 验证端口占用: `netstat -tulpn | grep 9222`

2. 无法访问远程页面
   - 检查 nginx 状态: `systemctl status nginx`
   - 确认防火墙设置: `ufw status`
   - 验证服务运行状态: `systemctl status chrome-remote`

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 许可证

[MIT License](LICENSE)

