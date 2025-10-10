# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个基于 Hexo 静态网站生成器的个人博客项目，部署在 GitHub Pages 上。项目使用 Butterfly 主题，包含博客文章、配置文件和部署脚本。

## 常用命令

### 开发和构建
```bash
# 安装依赖
npm install

# 本地开发服务器
npm run server
# 或者
hexo server

# 生成静态文件
npm run build
# 或者
hexo generate

# 清理构建文件
npm run clean
# 或者
hexo clean

# 部署到 GitHub Pages
npm run deploy
# 或者
hexo deploy

# 使用自动部署脚本（推荐）
./deploy.sh
```

### 自动部署脚本选项
```bash
# 完整流程（清理 -> 构建 -> 部署 -> 提交源码）
./deploy.sh

# 仅部署到 GitHub Pages
./deploy.sh --deploy

# 仅构建
./deploy.sh --build

# 清理并重新构建
./deploy.sh --clean

# 强制推送
./deploy.sh --force

# 显示帮助
./deploy.sh --help
```

## 项目架构

### 目录结构
- `_config.yml` - Hexo 主配置文件
- `_config.butterfly.yml` - Butterfly 主题配置文件
- `source/` - 源文件目录
  - `_posts/` - 博客文章（Markdown 文件）
  - `_data/` - 数据文件（自定义配置）
  - `img/` - 图片资源
  - `css/` - 自定义样式
  - `about/`、`categories/`、`tags/`、`links/` - 页面文件
- `themes/` - 主题目录
  - `butterfly/` - Butterfly 主题文件
- `public/` - 生成的静态文件（不需要手动修改）
- `scaffolds/` - 文章模板
- `node_modules/` - 依赖包

### 配置文件说明
- `_config.yml` - 包含网站基本配置、部署设置、插件配置
- `_config.butterfly.yml` - 主题外观、导航、侧边栏、功能开关等配置
- `deploy.sh` - 自动化部署脚本，包含完整的工作流程

## 主题和自定义

### Butterfly 主题
项目使用 Butterfly 主题，配置文件为 `_config.butterfly.yml`。主要功能包括：
- 导航菜单和页面布局
- 侧边栏卡片（作者信息、最近文章、分类、标签等）
- 代码块高亮和复制功能
- 搜索功能（本地搜索）
- 暗黑模式
- 字数统计和阅读时间
- 评论系统（支持多种）
- 社交媒体链接

### 自定义文件
- `source/_data/` - 数据文件，用于自定义配置
- `source/css/` - 自定义样式
- `source/img/` - 自定义图片资源

## 部署流程

### 自动部署（推荐）
```bash
# 执行自动部署脚本
./deploy.sh
```

### 手动部署
```bash
# 1. 清理旧文件
hexo clean

# 2. 生成静态文件
hexo generate

# 3. 部署到 GitHub Pages
hexo deploy

# 4. 提交源码（可选）
git add .
git commit -m "Update blog"
git push origin main
```

## 内容管理

### 创建新文章
```bash
# 创建新文章
hexo new "文章标题"

# 创建新页面
hexo new page "页面名称"
```

### 文章格式
文章存放在 `source/_posts/` 目录下，使用 Markdown 格式。支持 Front Matter：

```yaml
---
title: 文章标题
date: 2025-03-10 12:00:00
updated: 2025-03-10 12:00:00
tags:
  - 标签1
  - 标签2
categories: 分类
cover: /img/cover.jpg
description: 文章描述
---
```

## 依赖和插件

主要依赖包括：
- `hexo` - 静态网站生成器
- `hexo-theme-landscape` - 默认主题
- `hexo-deployer-git` - Git 部署插件
- `hexo-generator-*` - 各种生成器插件
- `hexo-renderer-*` - 渲染器插件
- `hexo-all-minifier` - 资源压缩

## 注意事项

1. **敏感信息**：GitHub 部署密钥已配置在 `_config.yml` 中，注意保护
2. **Node.js 版本**：需要 Node.js 18.0.0 或更高版本（见 `.nvmrc`）
3. **图片路径**：图片资源建议放在 `source/img/` 目录下
4. **主题配置**：修改主题外观请编辑 `_config.butterfly.yml` 文件
5. **缓存问题**：如果样式没有更新，可能需要清理缓存或使用 `hexo clean`

## 开发建议

- 本地开发时使用 `hexo server --debug` 查看调试信息
- 修改配置后需要重新生成和部署才能看到效果
- 使用 `hexo clean` 清理缓存来解决构建问题
- 备份重要的配置文件和自定义内容