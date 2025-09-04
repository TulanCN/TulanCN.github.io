---
title: linux学习记录
description: 轮岗当了一段时间的运维，重新学了下linux。
categories:
  - 工作
tags:
  - linux
date: 2025-09-03 17:05:56
---

如果说一个开发人员对linux不够熟悉，可能就永远止步于中级开发了。

原来写Java比较多，Spring在部署上已经给了一套良好的解决方案，能协助构建Fat Jar，用简单的`java -jar`命令就能启动程序。

也就导致我一直对linux的了解没那么深入。

目前的工作中，采用K8S这一套体系，所有的项目都打包成docker镜像再进行后续的部署。

这种情况下，如何编写docker file构建镜像，如何进行服务编排就是新的要求了。

docker file中的语法类似shell命令，能使用linux的一些基础命令比如cp、mv、rm、mkdir等。

毕竟docker是基于linux的镜像构建的嘛，支持这些命令也正常。

所以突然有个机会能把linux的命令重新学一下，我觉得还挺好的。

## 基础命令

### 1. 文件操作命令

#### 目录导航

- `pwd` - 显示当前工作目录
- `ls` - 列出目录内容
  - `ls -l` 详细列表
  - `ls -a` 显示隐藏文件
  - `ls -h` 人类可读大小
- `cd` - 切换目录
  - `cd ~` 回家目录
  - `cd -` 返回上一个目录
  - `cd ..` 上级目录

#### 文件操作

- `mkdir` - 创建目录
  - `mkdir -p` 创建多级目录
- `touch` - 创建空文件或更新时间戳
- `cp` - 复制文件/目录
  - `cp -r` 递归复制目录
  - `cp -v` 显示复制过程
- `mv` - 移动或重命名文件
- `rm` - 删除文件
  - `rm -r` 递归删除目录
  - `rm -f` 强制删除
  - `rm -i` 交互式删除

#### 文件查看

- `cat` - 连接并显示文件内容
- `more` - 分页显示文件内容
- `less` - 更好的分页显示（可上下滚动）
- `head` - 显示文件开头
  - `head -n 10` 显示前10行
- `tail` - 显示文件末尾
  - `tail -n 20` 显示后20行
  - `tail -f` 实时跟踪文件变化

### 2. 权限管理

#### 权限基础

Linux文件权限分为三类：

- 用户(User) - 文件所有者
- 组(Group) - 文件所属组
- 其他(Other) - 其他用户

每种权限有三种类型：

- 读(r) - 4
- 写(w) - 2  
- 执行(x) - 1

#### 权限命令

- `chmod` - 修改文件权限
  - 数字方式: `chmod 755 filename`
  - 符号方式: `chmod u+x filename`
- `chown` - 修改文件所有者
  - `chown user:group filename`
- `chgrp` - 修改文件所属组

#### 特殊权限

- SUID (Set User ID) - 以文件所有者身份执行
- SGID (Set Group ID) - 以文件所属组身份执行
- Sticky Bit - 目录中只有文件所有者能删除文件

### 3. 文本处理

#### 文本搜索

- `grep` - 文本搜索
  - `grep -i` 忽略大小写
  - `grep -n` 显示行号
  - `grep -v` 反向匹配
  - `grep -r` 递归搜索

#### 文本处理工具

- `awk` - 文本处理语言
  - `awk '{print $1}'` 打印第一列
- `sed` - 流编辑器
  - `sed 's/old/new/g'` 全局替换
- `cut` - 截取文本
  - `cut -d: -f1` 以冒号分隔取第一字段
- `sort` - 排序
- `uniq` - 去重

### 4. 帮助文档

- `man` - 查看命令手册
  - `man ls` 查看ls命令帮助
- `--help` - 查看命令简要帮助
  - `ls --help`
- `info` - 查看info格式文档

### 5. 管道

管道操作符`|`，通过管道我们能将多个命令组合起来，起到更好的效果。

注意，管道是同时起了多个进程，前一个进程的实时输出会自动输入到下一个进程里，而不是前一个执行完了才执行下一个。

```
ps -aux | grep java
```

## 系统管理

### 1. 用户和组管理

#### 用户管理命令

- `useradd` - 添加用户
  - `useradd -m` 创建家目录
  - `useradd -s` 指定shell
  - `useradd -g` 指定主组
- `usermod` - 修改用户属性
  - `usermod -aG` 添加附加组
  - `usermod -L` 锁定用户
  - `usermod -U` 解锁用户
- `userdel` - 删除用户
  - `userdel -r` 删除用户及家目录

#### 密码管理

- `passwd` - 设置密码
  - `passwd -l` 锁定密码
  - `passwd -u` 解锁密码
  - `passwd -d` 删除密码
- `chage` - 修改密码过期信息
  - `chage -l` 查看密码信息
  - `chage -M` 设置最大天数

#### 组管理

- `groupadd` - 添加组
- `groupmod` - 修改组
- `groupdel` - 删除组
- `gpasswd` - 组密码管理

#### 权限提升

- `su` - 切换用户
  - `su -` 完全切换环境
  - `su -c` 以其他用户执行命令
- `sudo` - 以超级用户权限执行
  - `/etc/sudoers` 配置文件
  - `visudo` 安全编辑sudoers

### 2. 进程管理

#### 进程查看

- `ps` - 进程状态
  - `ps aux` 查看所有进程
  - `ps -ef` 完整格式列表
  - `ps -o` 自定义输出格式
- `top` - 实时进程监控
  - 交互命令: k(杀死), r(renice), h(帮助)
- `htop` - 增强版top（需要安装）
- `pstree` - 树状显示进程

#### 进程控制

- `kill` - 发送信号给进程
  - `kill -9` 强制终止
  - `kill -15` 正常终止
  - `kill -l` 列出所有信号
- `pkill` - 按名称杀死进程
- `killall` - 杀死所有同名进程
- `nice` - 设置进程优先级
- `renice` - 修改运行中进程优先级

#### 后台作业

- `&` - 后台运行
- `jobs` - 查看后台作业
- `fg` - 前台运行
- `bg` - 后台继续运行
- `nohup` - 忽略挂起信号运行

### 3. 系统监控

#### 系统状态

- `uptime` - 系统运行时间
- `w` - 显示登录用户及进程
- `who` - 显示登录用户
- `last` - 显示登录历史

#### 内存监控

- `free` - 内存使用情况
  - `free -h` 人类可读格式
  - `free -m` 以MB显示
- `vmstat` - 虚拟内存统计
  - `vmstat 1` 每秒刷新

#### 磁盘监控

- `df` - 磁盘空间使用
  - `df -h` 人类可读格式
  - `df -i` inode使用情况
- `du` - 目录空间使用
  - `du -sh` 汇总显示
  - `du -h --max-depth=1` 一级目录

#### 性能监控

- `iostat` - CPU和磁盘I/O统计
- `mpstat` - CPU使用统计
- `sar` - 系统活动报告
  - 需要安装sysstat包
- `dstat` - 多功能系统监控

### 4. 日志管理

#### 系统日志

- `/var/log/messages` - 主要系统日志
- `/var/log/secure` - 安全相关日志
- `/var/log/cron` - 计划任务日志
- `/var/log/boot.log` - 启动日志

#### 日志查看工具

- `tail` - 查看日志尾部
- `less` - 分页查看日志
- `grep` - 搜索日志内容
- `journalctl` - systemd日志查看
  - `journalctl -f` 实时跟踪
  - `journalctl -u` 按服务查看
  - `journalctl --since` 时间范围

### 5. 系统信息

#### 硬件信息

- `uname` - 系统信息
  - `uname -a` 所有信息
- `lscpu` - CPU信息
- `lsblk` - 块设备信息
- `lspci` - PCI设备信息
- `lsusb` - USB设备信息

#### 系统版本

- `cat /etc/redhat-release` - CentOS版本
- `cat /etc/os-release` - 系统发行版信息

## 网络配置

### 1. 网络接口管理

#### 传统网络命令

- `ifconfig` - 接口配置（已逐渐被淘汰）
  - `ifconfig eth0 up` 启用接口
  - `ifconfig eth0 down` 禁用接口
- `route` - 路由管理
  - `route -n` 数字格式显示路由表
  - `route add` 添加路由
  - `route del` 删除路由

#### 现代网络命令（iproute2）

- `ip` - 多功能网络工具
  - `ip addr` 查看IP地址
  - `ip link` 查看网络接口
  - `ip route` 查看路由表
  - `ip neigh` 查看ARP表
- `ss` - socket统计（替代netstat）
  - `ss -tuln` 查看监听端口
  - `ss -t` 查看TCP连接
  - `ss -u` 查看UDP连接

### 2. 网络配置文件

#### 网络配置文件位置

- `/etc/sysconfig/network-scripts/` - 网络脚本目录
- `ifcfg-eth0` - 以太网接口配置文件
- `route-eth0` - 接口路由配置文件

#### 配置文件示例

```bash
# /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=static
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
ONBOOT=yes
```

### 3. 防火墙配置（firewalld）

#### firewalld基础概念

- 区域(zone): 预定义的规则集合
- 服务(service): 预定义的服务规则
- 端口(port): 自定义端口规则

#### firewall-cmd命令

- `firewall-cmd --state` 查看防火墙状态
- `firewall-cmd --get-active-zones` 查看活动区域
- `firewall-cmd --list-all` 查看所有规则
- `firewall-cmd --reload` 重载配置

#### 常用操作

- 添加服务: `firewall-cmd --add-service=http`
- 添加端口: `firewall-cmd --add-port=8080/tcp`
- 永久生效: `--permanent` 参数
- 移除规则: `--remove-service` 或 `--remove-port`

### 4. 网络诊断工具

#### 连通性测试

- `ping` - ICMP连通性测试
  - `ping -c 4` 发送4个包
  - `ping -i 2` 间隔2秒
- `traceroute` - 路由追踪
  - `traceroute example.com`
- `mtr` - 更好的路由追踪工具

#### 端口扫描

- `nmap` - 网络扫描工具
  - `nmap -sS` TCP SYN扫描
  - `nmap -sU` UDP扫描
  - `nmap -O` 操作系统检测
- `telnet` - 测试端口连通性
  - `telnet host port`

#### 网络抓包

- `tcpdump` - 命令行抓包工具
  - `tcpdump -i eth0` 指定接口
  - `tcpdump port 80` 指定端口
  - `tcpdump -w file.pcap` 保存到文件
- `wireshark` - 图形化抓包工具

### 5. DNS和主机名

#### DNS配置

- `/etc/resolv.conf` - DNS解析配置
- `/etc/hosts` - 本地主机名解析
- `nslookup` - DNS查询工具
- `dig` - 更强大的DNS查询工具
  - `dig example.com` 查询A记录
  - `dig MX example.com` 查询MX记录

#### 主机名管理

- `hostname` - 查看或设置主机名
- `hostnamectl` - 系统主机名控制
- 
  - `hostnamectl set-hostname` 设置主机名

### 6. 网络服务

#### SSH服务

- `ssh` - 安全远程登录
  - `ssh user@host`
  - `ssh -p port user@host` 指定端口
- `scp` - 安全文件传输
  - `scp file user@host:path`
- `ssh-keygen` - SSH密钥生成

#### 其他网络工具

- `curl` - URL传输工具
- `wget` - 网络下载工具
- `netcat` - 网络瑞士军刀

## 磁盘管理

### 1. 磁盘基础概念

#### 磁盘设备命名

- `/dev/sda` - 第一块SCSI/SATA磁盘
- `/dev/sdb` - 第二块SCSI/SATA磁盘
- `/dev/sda1` - 第一块磁盘的第一个分区
- `/dev/vda` - 虚拟化环境中的磁盘

#### 磁盘类型

- HDD: 机械硬盘
- SSD: 固态硬盘
- NVMe: 高速固态硬盘（/dev/nvme0n1）

### 2. 磁盘分区管理

#### 分区工具

- `fdisk` - 传统分区工具（MBR）
- `parted` - 高级分区工具（支持GPT）
- `gdisk` - GPT分区工具

#### fdisk基本操作

```bash
fdisk /dev/sdb
# 常用命令:
# n - 新建分区
# d - 删除分区
# p - 打印分区表
# w - 写入并退出
# q - 退出不保存
```

#### parted基本操作

```bash
parted /dev/sdb
# 常用命令:
# mklabel gpt - 创建GPT分区表
# mkpart primary ext4 1MiB 10GiB - 创建分区
# print - 显示分区信息
# quit - 退出
```

### 3. 文件系统管理

#### 文件系统类型

- ext4: Linux默认文件系统
- xfs: 高性能文件系统
- swap: 交换分区
- vfat: FAT32文件系统

#### 创建文件系统

- `mkfs.ext4 /dev/sdb1` - 创建ext4文件系统
- `mkfs.xfs /dev/sdb1` - 创建xfs文件系统
- `mkswap /dev/sdb2` - 创建交换分区
- `swapon /dev/sdb2` - 启用交换分区

#### 文件系统检查

- `fsck.ext4 /dev/sdb1` - 检查ext4文件系统
- `xfs_repair /dev/sdb1` - 修复xfs文件系统
- `tune2fs` - 调整ext文件系统参数

### 4. 挂载管理

#### 挂载命令

- `mount /dev/sdb1 /mnt/data` - 挂载分区
- `umount /mnt/data` - 卸载分区
- `mount -a` - 挂载所有在fstab中的文件系统

#### /etc/fstab配置

```bash
# 设备        挂载点   文件系统  选项      备份 检查
/dev/sdb1    /data    ext4     defaults  0    0
UUID=xxxx    /backup  xfs      defaults  0    0
```

#### 挂载选项

- defaults: 默认选项（rw,suid,dev,exec,auto,nouser,async）
- noatime: 不更新访问时间
- nodiratime: 不更新目录访问时间
- ro: 只读挂载
- rw: 读写挂载

### 5. LVM逻辑卷管理

#### LVM概念

- PV (Physical Volume): 物理卷
- VG (Volume Group): 卷组
- LV (Logical Volume): 逻辑卷

#### LVM创建流程

1. 创建物理卷: `pvcreate /dev/sdb`
2. 创建卷组: `vgcreate vg_data /dev/sdb`
3. 创建逻辑卷: `lvcreate -L 10G -n lv_data vg_data`
4. 创建文件系统: `mkfs.ext4 /dev/vg_data/lv_data`
5. 挂载使用: `mount /dev/vg_data/lv_data /data`

#### LVM管理命令

- `pvdisplay` - 显示物理卷信息
- `vgdisplay` - 显示卷组信息
- `lvdisplay` - 显示逻辑卷信息
- `vgextend` - 扩展卷组
- `lvextend` - 扩展逻辑卷
- `resize2fs` - 调整文件系统大小

### 6. 磁盘配额管理

#### 配额配置步骤

1. 启用配额: `usrquota,grpquota` 挂载选项
2. 创建配额数据库: `quotacheck -cug /mountpoint`
3. 启用配额: `quotaon /mountpoint`
4. 设置配额: `edquota username`

#### 配额管理命令

- `quota` - 查看用户配额
- `repquota` - 报告配额使用情况
- `setquota` - 设置配额限制

### 7. 磁盘性能监控

#### 性能监控工具

- `iostat` - I/O统计信息
- `iotop` - I/O使用情况top
- `hdparm` - 硬盘参数和性能测试
- `dd` - 磁盘读写性能测试

#### 性能测试示例

```bash
# 写性能测试
dd if=/dev/zero of=testfile bs=1G count=1 oflag=direct

# 读性能测试
dd if=testfile of=/dev/null bs=1G count=1
```

## 服务管理

### 1. systemd基础

#### systemd简介

- 系统初始化系统
- 服务管理守护进程
- 提供系统状态快照
- 支持并行启动服务

#### 核心概念

- 单元(Unit): 系统资源抽象（服务、挂载点、设备等）
- 目标(Target): 单元组，类似运行级别
- 依赖关系: 服务启动顺序控制

### 2. 服务管理命令

#### systemctl基础命令

- `systemctl status service` - 查看服务状态
- `systemctl start service` - 启动服务
- `systemctl stop service` - 停止服务
- `systemctl restart service` - 重启服务
- `systemctl reload service` - 重载配置

#### 服务启用和禁用

- `systemctl enable service` - 启用开机启动
- `systemctl disable service` - 禁用开机启动
- `systemctl is-enabled service` - 检查启用状态
- `systemctl is-active service` - 检查活动状态

#### 系统状态查看

- `systemctl list-units` - 列出所有单元
- `systemctl list-unit-files` - 列出所有单元文件
- `systemctl list-dependencies` - 列出依赖关系
- `systemctl show service` - 显示服务属性

### 3. 服务单元文件

#### 单元文件位置

- `/usr/lib/systemd/system/` - 系统安装的单元文件
- `/etc/systemd/system/` - 系统管理员创建的单元文件
- `/run/systemd/system/` - 运行时单元文件

#### 单元文件结构

```ini
[Unit]
Description=服务描述
After=network.target
Requires=network.target

[Service]
Type=simple
User=username
ExecStart=/path/to/command
Restart=always

[Install]
WantedBy=multi-user.target
```

#### 常用配置选项

- **Type**: simple, forking, oneshot, notify
- **User/Group**: 运行服务的用户和组
- **ExecStart**: 启动命令
- **ExecStop**: 停止命令
- **Restart**: 重启策略
- **Environment**: 环境变量

### 4. 目标(Target)管理

#### 系统目标

- `multi-user.target` - 多用户文本模式
- `graphical.target` - 图形界面模式
- `rescue.target` - 救援模式
- `emergency.target` - 紧急模式

#### 目标操作

- `systemctl isolate target` - 切换到目标
- `systemctl get-default` - 获取默认目标
- `systemctl set-default target` - 设置默认目标
- `systemctl list-dependencies target` - 列出目标依赖

### 5. 日志管理

#### journalctl命令

- `journalctl` - 查看所有日志
- `journalctl -u service` - 查看指定服务日志
- `journalctl -f` - 实时跟踪日志
- `journalctl --since "1 hour ago"` - 时间范围查询
- `journalctl -p err` - 查看错误级别日志

#### 日志过滤

- `journalctl _PID=1234` - 按进程ID过滤
- `journalctl _UID=1000` - 按用户ID过滤
- `journalctl -k` - 查看内核日志
- `journalctl --disk-usage` - 查看日志磁盘使用

### 6. 定时任务管理

#### systemd定时器

- 替代传统的cron
- 更精确的时间控制
- 更好的日志集成

#### 定时器配置

```ini
# timer单元
[Unit]
Description=定时任务描述

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

#### 传统cron

- `/etc/crontab` - 系统crontab
- `/etc/cron.d/` - 额外cron配置
- `crontab -e` - 编辑用户cron
- `crontab -l` - 列出用户cron

### 7. 服务故障排查

#### 常见问题

- 服务启动失败
- 依赖关系问题
- 权限配置错误
- 资源限制问题

#### 排查工具

- `systemctl status` - 查看服务状态
- `journalctl -u` - 查看服务日志
- `systemctl daemon-reload` - 重载配置
- `systemctl reset-failed` - 重置失败状态

## 后话

这个文档是刚开始学习时的记录。

后面经过一段时间的工作后，觉得能看明白日志，能排查问题才是最重要的。

可能是我作为开发人员的习惯吧，总觉得遇到错误得弄明白才行。

开发人员也有遇到线上问题的时候，这时候能看日志，能通过命令旁敲侧击查找问题的根源就很重要了。

能否处理线上事故，排查的手段是否丰富，这应该是高级开发和普通开发最大的差异点之一了。

就我个人来说，以前写Java也处理过不少线上问题，有自己的经验，但到运维这块，我发现遇到的网络问题明显更多一些...

所以就很头疼，硬着头皮学了不少东西，把网络这块的缺漏又补了一遍。

明明研究生的时候就又重学了一遍网络，没想到工作之后又得学，果然是学无止境。

我做现在的工作时总会想起多隆，解决一个个问题，处理好一件件事情，以后会不会也有机会成为像多隆一样的技术专家呢？
