# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## 项目调试规则（非显而易见）

### 构建问题调试
- 如果样式没有更新，运行 `hexo clean` 清理缓存后重新构建
- 本地开发时使用 `hexo server --debug` 查看详细调试信息
- 构建失败时检查 Node.js 版本是否为 18.0.0 或更高版本

### 部署问题调试
- 部署失败时检查 `_config.yml` 中的部署配置和密钥是否正确
- 使用 `./deploy.sh --force` 可强制推送解决远程仓库冲突
- 部署后页面未更新可能需要等待 GitHub Pages 处理（通常几分钟）

### 主题自定义调试
- 主题配置不生效时检查 `themes/next/_config.yml` 中的 `override` 设置
- 自定义样式不显示时确认 `source/_data/styles.styl` 文件路径是否正确配置
- 修改主题文件后需在 `themes/next` 目录运行 `gulp` 检查代码格式

### 本地服务器调试
- 本地服务器默认端口为 4000，使用 `hexo server -p 4001` 可更换端口
- 修改配置后需重启本地服务器才能看到效果
- 使用浏览器开发者工具检查网络请求和资源加载情况

### 常见问题解决方案
- 图片不显示：检查路径是否以 `/` 开头（绝对路径）
- 文章分类不显示：确保 Front Matter 中 categories 字段格式正确
- 搜索功能不可用：检查 `hexo-generator-searchdb` 插件是否正确安装和配置