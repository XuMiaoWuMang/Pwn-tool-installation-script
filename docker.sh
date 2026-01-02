#!/bin/bash
# 系统软件源配置和Docker安装脚本
# 参数：
#   --skip-source             跳过系统软件源配置
#   --skip-docker             跳过Docker安装
#   --source-url <url>        系统软件源地址
#   --docker-source-url <url> Docker CE软件源地址
#   --docker-registry-url <url> Docker镜像仓库地址

# 默认参数
SKIP_SOURCE="false"
SKIP_DOCKER="false"
SOURCE_URL="mirrors.tuna.tsinghua.edu.cn"
DOCKER_SOURCE_URL="mirrors.tuna.tsinghua.edu.cn/docker-ce"
DOCKER_REGISTRY_URL="docker.1ms.run"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-source)
      SKIP_SOURCE="true"
      shift
      ;;
    --skip-docker)
      SKIP_DOCKER="true"
      shift
      ;;
    --source-url)
      if [[ $# -gt 1 ]]; then
        SOURCE_URL="$2"
        shift 2
      else
        echo "错误：--source-url 参数需要一个URL值"
        echo "用法: $0 [--source-url <url>] [--docker-source-url <url>] [--docker-registry-url <url>]"
        exit 1
      fi
      ;;
    --docker-source-url)
      if [[ $# -gt 1 ]]; then
        DOCKER_SOURCE_URL="$2"
        shift 2
      else
        echo "错误：--docker-source-url 参数需要一个URL值"
        echo "用法: $0 [--source-url <url>] [--docker-source-url <url>] [--docker-registry-url <url>]"
        exit 1
      fi
      ;;
    --docker-registry-url)
      if [[ $# -gt 1 ]]; then
        DOCKER_REGISTRY_URL="$2"
        shift 2
      else
        echo "错误：--docker-registry-url 参数需要一个URL值"
        exit 1
      fi
      ;;
    *)
      echo "未知参数: $1"
      echo "用法: $0 [--skip-source] [--skip-docker] [--source-url <url>] [--docker-source-url <url>] [--docker-registry-url <url>]"
      exit 1
      ;;
  esac
done

echo "=== Docker.sh 执行参数设置 ==="
echo "  跳过系统换源: $SKIP_SOURCE"
echo "  跳过Docker安装: $SKIP_DOCKER"
echo "  系统软件源地址: $SOURCE_URL"
echo "  Docker CE软件源地址: $DOCKER_SOURCE_URL"
echo "  Docker镜像仓库地址: $DOCKER_REGISTRY_URL"

# 系统软件源配置（root权限执行）
if [ "$SKIP_SOURCE" = "false" ]; then
  echo "=== 配置系统软件源 ==="
  bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
    --source "$SOURCE_URL" \
    --protocol http \
    --use-intranet-source false \
    --install-epel true \
    --backup true \
    --upgrade-software false \
    --clean-cache false \
    --ignore-backup-tips \
    --pure-mode 
else
  echo "=== 跳过系统软件源配置 ==="
fi

# Docker安装（root权限执行）
if [ "$SKIP_DOCKER" = "false" ]; then
  echo "=== 安装和配置Docker ==="
  bash <(curl -sSL https://linuxmirrors.cn/docker.sh) \
    --source "$DOCKER_SOURCE_URL" \
    --source-registry "$DOCKER_REGISTRY_URL" \
    --protocol http \
    --use-intranet-source false \
    --install-latest true \
    --close-firewall true \
    --ignore-backup-tips \
    --pure-mode 
else
  echo "=== 跳过Docker安装 ==="
fi

echo "如果想切换源, 可以在运行脚本时通过参数指定:"
echo "  ./docker.sh --source-url <新源地址> --docker-source-url <新Docker CE源地址> --docker-registry-url <新Docker镜像仓库地址>"
