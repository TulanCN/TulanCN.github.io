# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## 项目概述

这是一个基于 Hexo 静态网站生成器的个人博客项目，使用 NexT 主题并通过 GitHub Pages 部署。

## 构建和部署命令

### 基本命令
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
```

### 自动部署脚本（推荐）
```bash
# 完整流程（清理 -> 构建 -> 部署 -> 提交源码）
./deploy.sh

# 部署选项
./deploy.sh --deploy   # 仅部署
./deploy.sh --build    # 仅构建
./deploy.sh --clean    # 清理并重新构建
./deploy.sh --force    # 强制推送
```

## 项目特定配置

### 主题配置
- 主题配置在 `themes/next/_config.yml` 中
- 主题自定义文件位于 `source/_data/` 目录：
  - `head.swig` - 自定义头部内容
  - `bodyEnd.swig` - 自定义 body 结束内容
  - `styles.styl` - 自定义样式

### 部署配置
- 部署配置在 `_config.yml` 的 `deploy` 部分
- 使用 GitHub Pages 自动部署
- 部署密钥已配置在 `_config.yml` 中（需保护）

## 代码规范

### JavaScript 格式
- 主题代码使用 ESLint 进行代码检查
- 配置文件：`themes/next/.eslintrc.json`
- 运行检查：在 `themes/next` 目录下执行 `gulp` 或 `npm test`

### Stylus 格式
- 样式文件使用 Stylint 进行格式检查
- 配置文件：`themes/next/.stylintrc`
- 运行检查：`npx stylint ./source/css/`

## 项目结构

### 核心目录
- `source/_posts/` - 博客文章（Markdown 文件）
- `source/_data/` - 自定义数据文件
- `source/img/` - 图片资源
- `themes/next/` - NexT 主题文件
- `scaffolds/` - 文章模板

### 文章格式
- 使用 Front Matter 定义元数据
- 支持 YAML 格式的标题、日期、标签、分类等
- 图片资源建议放在 `source/img/` 目录下

## 重要注意事项

1. **缓存问题**：如果样式没有更新，运行 `hexo clean` 清理缓存
2. **Node.js 版本**：需要 Node.js 18.0.0 或更高版本
3. **部署流程**：推荐使用 `./deploy.sh` 脚本进行完整部署
4. **主题更新**：在 `themes/next` 目录下执行 `git pull` 更新主题
5. **自定义文件**：修改主题外观请编辑 `source/_data/` 中的文件而非主题核心文件