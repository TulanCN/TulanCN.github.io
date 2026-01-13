# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## 项目编码规则（非显而易见）

### 主题代码修改
- 修改 NexT 主题代码时，必须在 `themes/next` 目录下运行 `gulp` 进行代码检查
- JavaScript 代码使用 ESLint 检查，配置文件为 `themes/next/.eslintrc.json`
- Stylus 样式使用 Stylint 检查，配置文件为 `themes/next/.stylintrc`
- 运行 `npx stylint ./source/css/ 检查样式文件格式

### 自定义文件位置
- 自定义样式必须放在 `source/_data/styles.styl` 中，不要直接修改主题文件
- 自定义头部内容放在 `source/_data/head.swig` 中
- 自定义 body 结束内容放在 `source/_data/bodyEnd.swig` 中
- 这些文件路径在 `themes/next/_config.yml` 的 `custom_file_path` 部分配置

### 文章资源管理
- 启用了 `post_asset_folder: true`，每篇文章会创建同名资源文件夹
- 图片资源建议放在 `source/img/` 目录下，而非文章资源文件夹
- 使用 `hexo new "文章标题"` 创建新文章时，会自动创建资源文件夹

### 主题配置注意事项
- 主题配置文件 `themes/next/_config.yml` 中的 `override: false` 表示合并配置而非完全覆盖
- 如需完全覆盖主题配置，需设置 `override: true` 并复制所有配置到 `source/_data/next.yml`
- 主题更新前建议备份自定义配置，更新后使用 `hexo clean` 清理缓存

### 部署相关
- 部署密钥已配置在 `_config.yml` 中，修改时需注意保护敏感信息
- 使用 `./deploy.sh` 脚本进行部署，避免手动执行 `hexo deploy`
- 脚本会自动提交源码到 Git 仓库，无需手动提交