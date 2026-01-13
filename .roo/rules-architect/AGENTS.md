# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## 项目架构规则（非显而易见）

### 核心架构模式
- Hexo 静态网站生成器 + NexT 主题 + GitHub Pages 部署
- 配置分离：主配置在 `_config.yml`，主题配置在 `themes/next/_config.yml`
- 自定义内容通过 `source/_data/` 目录注入，避免直接修改主题文件
- 自动化部署脚本 `deploy.sh` 封装完整工作流程

### 数据流架构
- Markdown 文章 → Hexo 解析 → 静态 HTML → GitHub Pages
- 主题配置与自定义配置合并 → 最终样式
- 构建产物存储在 `public/` 目录，由 Git 自动部署
- 资源文件通过 `source/` 目录管理，构建时复制到 `public/`

### 扩展性设计
- 主题更新不影响自定义内容（通过 `source/_data/` 隔离）
- 插件系统通过 npm 包管理，在 `_config.yml` 中配置
- 自定义样式和脚本可通过特定路径注入到主题中
- 多语言支持通过 `themes/next/languages/` 目录管理

### 安全与性能考虑
- 部署密钥存储在配置文件中，需注意保护
- 启用缓存机制提高构建速度
- 图片优化和资源压缩通过插件自动处理
- CDN 配置在主题配置中，可优化资源加载速度

### 部署架构
- 源码和生成内容在同一仓库的不同分支
- 自动化脚本处理构建、部署和源码提交
- GitHub Pages 自动从指定分支发布静态内容
- 无需服务器维护，完全基于 Git 工作流程