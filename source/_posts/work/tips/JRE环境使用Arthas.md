---
title: JRE环境使用Arthas
date: 2024-09-20 19:12:39
description: Arthas是线上故障排查、性能调优常用的工具。这里提供一个在JRE环境也可以使用Arthas的方式。
categories:
- 工作
tags:
 - 优秀实践
---



## 场景

实际工作中常遇到一种情况，线上环境出现异常，但是环境安装的是JRE。

JRE环境下没有了JDK提供的各类工具，根本无法排查问题。如果重装JDK，那么同时也得重启项目，而项目一旦重启，问题的环境就已经丢失，下一次再遇到同样的问题就可遇不可求了。

## 解决方案

使用轻量级的程序附加工具jattach可以做到将Arthas的Jar包attach到特定的进程上。

网上有类似的解析。最关键的一点是Arthas只需要将一个jar附加到JVM中就可以运行了。

这里提供一个脚本：

```
#!/bin/bash

# 获取当前脚本所在的目录
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 用户输入进程ID
read -p "请输入进程ID: " pid

# 用户输入可选参数host，提供默认值
read -p "请输入主机地址和端口号（格式：IP 端口，默认为 127.0.0.1 3658）: " host
host=${host:-"127.0.0.1 3658"}

# 检查当前目录下是否存在jattach文件
if [[ ! -e "$script_dir/jattach" ]]; then
  # 查找以jattach-linux开头的tgz压缩包
  jattach_tgz=$(find "$script_dir" -maxdepth 1 -type f -name "jattach-linux-*.tgz")

  if [[ -z "$jattach_tgz" ]]; then
    echo "当前目录下未找到名为jattach的文件或符合条件的jattach-linux-*.tgz压缩包。"
    exit 1
  fi

  # 判断系统架构
  system_arch=$(uname -m)
  case $system_arch in
    "aarch64"|"arm64")
      arch="arm64"
      jattach_file="jattach-linux-arm64.tgz"
      ;;
    "x86_64"|"amd64")
      arch="x64"
      jattach_file="jattach-linux-x64.tgz"
      ;;
    *)
      echo "当前系统架构不支持自动解压jattach工具。"
      exit 1
  esac

  # 检查对应的jattach压缩包是否存在
  if [[ ! -f "$script_dir/$jattach_file" ]]; then
    echo "当前目录下未找到与系统架构匹配的$jattach_file压缩包。"
    exit 1
  fi

  # 解压缩对应架构的jattach工具到当前脚本目录，并使用绝对路径
  tar -xzvf "$script_dir/$jattach_file" -C "$script_dir"

  # 检查解压后jattach是否成功生成
  if [[ ! -e "$script_dir/jattach" ]]; then
    echo "解压失败或未能在当前目录找到解压后的jattach文件。"
    exit 1
  fi
fi

# 使用jattach命令加载arthas-agent.jar，使用绝对路径
"$script_dir/jattach" $pid load instrument false "$script_dir/arthas-agent.jar" && \

# 运行arthas客户端，同样使用绝对路径
java -jar "$script_dir/arthas-client.jar" $host

```

最关键的就是脚本中最后的两句

```
# 使用jattach命令加载arthas-agent.jar，使用绝对路径
"$script_dir/jattach" $pid load instrument false "$script_dir/arthas-agent.jar" && \

# 运行arthas客户端，同样使用绝对路径
java -jar "$script_dir/arthas-client.jar" $host
```

这其实是一个命令，分成了两行。第一个命令是将`arthas-agent.jar`加载到某个pid的程序中，第二个命令是运行arthas的界面。

脚本提供了自动安装jattach的能力，只需要将jattach的安装包与此脚本方式在arthas的目录内，然后运行此脚本即可。
