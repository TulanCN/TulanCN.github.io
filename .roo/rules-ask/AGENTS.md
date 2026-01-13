# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## 项目文档规则（非显而易见）

### 配置文件说明
- 主配置文件 `_config.yml` 包含 Hexo 基本设置和部署配置
- 主题配置文件 `themes/next/_config.yml` 控制外观和功能
- 主题自定义文件在 `source/_data/` 目录，用于覆盖默认设置
- `override: false` 表示合并配置，`true` 表示完全覆盖

### 内容组织说明
- 博客文章存放在 `source/_posts/` 目录，使用 Markdown 格式
- 图片资源建议放在 `source/img/` 目录而非文章资源文件夹
- 页面文件（关于、分类、标签等）在 `source/` 对应目录下
- 自定义样式和脚本通过 `source/_data/` 中的文件引入

### 部署流程说明
- 使用 `./deploy.sh` 脚本进行完整部署流程
- 脚本会自动执行清理、构建、部署和源码提交
- 部署密钥已配置在 `_config.yml` 中，无需手动设置
- GitHub Pages 自动部署，无需手动操作服务器

### 主题自定义说明
- 主题使用 NexT，通过修改 `source/_data/` 中的文件自定义
- 不建议直接修改 `themes/next/` 目录中的主题文件
- 主题更新会覆盖直接修改的文件，但保留 `source/_data/` 中的自定义内容
- 主题配置更改后需要清理缓存才能看到效果

### 项目结构说明
- `public/` 目录为生成的静态文件，不需要手动修改
- `scaffolds/` 目录包含文章模板，可自定义新文章的默认格式
- `themes/next/` 目录为主题文件，更新时会被覆盖
- `node_modules/` 目录为依赖包，由 npm 管理