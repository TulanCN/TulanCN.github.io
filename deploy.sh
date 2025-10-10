#!/bin/bash

# ===========================================
# Hexo博客自动构建和发布脚本
# 作者: Tulan
# 描述: 自动构建Hexo博客并发布到GitHub Pages，同时提交源码到Git仓库
# ===========================================

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "命令 $1 未找到，请先安装"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -d, --deploy   仅部署到GitHub Pages（不构建）"
    echo "  -b, --build    仅构建（不部署）"
    echo "  -c, --clean    清理并重新构建"
    echo "  -f, --force    强制推送（使用git push --force）"
    echo "  无参数         完整流程：清理 -> 构建 -> 部署 -> 提交源码"
}

# 检查必要的命令
check_commands() {
    log_info "检查必要的命令..."
    check_command git
    check_command node
    check_command npm
    check_command hexo
}

# 清理构建
clean_build() {
    log_info "清理构建文件..."
    hexo clean
    log_success "清理完成"
}

# 构建博客
build_blog() {
    log_info "开始构建博客..."
    hexo generate
    log_success "博客构建完成"
}

# 部署到GitHub Pages
deploy_to_github() {
    log_info "部署到GitHub Pages..."

    # 检查是否存在本地配置文件（用于本地部署）
    if [ -f "_config.local.yml" ]; then
        log_info "使用本地配置进行部署..."
        hexo deploy --config _config.local.yml
    else
        log_warning "未找到本地配置文件，无法直接部署"
        log_info "请推送代码到GitHub仓库，由GitHub Actions自动部署"
        return 1
    fi

    log_success "部署完成"
}

# 提交源码到Git仓库
commit_source_code() {
    log_info "提交源码到Git仓库..."
    
    # 获取当前时间
    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
    COMMIT_MESSAGE="Auto deploy: $CURRENT_TIME"
    
    # 添加所有更改
    git add .
    
    # 检查是否有更改需要提交
    if git diff --cached --quiet; then
        log_warning "没有更改需要提交"
        return
    fi
    
    # 提交更改
    git commit -m "$COMMIT_MESSAGE"
    
    # 推送到远程仓库
    if [ "$FORCE_PUSH" = true ]; then
        git push --force origin main
    else
        git push origin main
    fi
    
    log_success "源码提交完成"
}

# 主函数
main() {
    local ONLY_DEPLOY=false
    local ONLY_BUILD=false
    local CLEAN_BUILD=false
    FORCE_PUSH=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--deploy)
                ONLY_DEPLOY=true
                shift
                ;;
            -b|--build)
                ONLY_BUILD=true
                shift
                ;;
            -c|--clean)
                CLEAN_BUILD=true
                shift
                ;;
            -f|--force)
                FORCE_PUSH=true
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log_info "开始Hexo博客自动化流程..."

    # 检查命令
    check_commands

    if [ "$ONLY_DEPLOY" = true ]; then
        deploy_to_github
        exit 0
    fi

    if [ "$ONLY_BUILD" = true ]; then
        build_blog
        exit 0
    fi

    # 完整流程
    if [ "$CLEAN_BUILD" = true ]; then
        clean_build
    fi

    build_blog

    # 尝试本地部署，如果失败则提示使用GitHub Actions
    if ! deploy_to_github; then
        log_warning "本地部署失败，将使用GitHub Actions自动部署"
        log_info "推送代码后将自动触发部署"
    fi

    commit_source_code

    log_success "所有操作完成！"
    log_info "博客将自动发布到: https://TulanCN.github.io/"
    log_info "查看部署状态: https://github.com/TulanCN/TulanCN.github.io/actions"
}

# 异常处理
trap 'log_error "脚本执行中断"; exit 1' INT TERM

# 执行主函数
main "$@"