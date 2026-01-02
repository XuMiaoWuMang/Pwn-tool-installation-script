#!/bin/bash
# Pwn 环境搭建脚本 - 用户版
# 功能：以普通用户身份运行，仅在需要时使用sudo提升权限
# 参数：
#   --skip-source             跳过系统软件源配置
#   --skip-docker             跳过Docker安装
#   --source-url <url>        系统软件源地址
#   --docker-source-url <url> Docker CE软件源地址
#   --docker-registry-url <url> Docker镜像仓库地址

set -e  # 错误时退出

# 默认参数
SKIP_SOURCE="false"
SKIP_DOCKER="false"
SOURCE_URL=""
DOCKER_SOURCE_URL=""
DOCKER_REGISTRY_URL=""

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
        exit 1
      fi
      ;;
    --docker-source-url)
      if [[ $# -gt 1 ]]; then
        DOCKER_SOURCE_URL="$2"
        shift 2
      else
        echo "错误：--docker-source-url 参数需要一个URL值"
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
    --help|-h)
      echo "Pwn 环境搭建脚本 - 用户版"
      echo "功能：以普通用户身份运行，仅在需要时使用sudo提升权限"
      echo ""
      echo "参数:"
      echo "  --skip-source             跳过系统软件源配置"
      echo "  --skip-docker             跳过Docker安装"
      echo "  --source-url <url>        系统软件源地址"
      echo "  --docker-source-url <url> Docker CE软件源地址"
      echo "  --docker-registry-url <url> Docker镜像仓库地址"
      echo "  --help|-h                 显示帮助信息"
      echo ""
      echo "用法:"
      echo "  $0                 # 执行完整安装（包括系统换源和Docker）"
      echo "  $0 --skip-source   # 跳过系统换源，只安装Docker和工具"
      echo "  $0 --skip-docker   # 跳过Docker安装，只进行系统换源和工具安装"
      echo "  $0 --skip-source --skip-docker  # 只安装工具，跳过系统换源和Docker"
      echo "  $0 --source-url mirrors.ustc.edu.cn  # 使用指定的系统软件源"
      echo "  $0 --docker-source-url mirrors.ustc.edu.cn/docker-ce --docker-registry-url registry.docker-cn.com  # 使用指定的Docker源"
      exit 0
      ;;
    *)
      echo "未知参数: $1"
      echo "请使用 --help 参数查看用法"
      exit 1
      ;;
  esac
done

# 获取当前用户信息
CURRENT_USER=$(whoami)
CURRENT_HOME=$(getent passwd "$CURRENT_USER" | cut -d: -f6)

echo "=== 当前以普通用户: $CURRENT_USER 执行，需要时将使用 sudo 提升权限 ==="
echo "用户家目录: $CURRENT_HOME"
echo "参数设置:"
echo "  跳过系统换源: $SKIP_SOURCE"
echo "  跳过Docker安装: $SKIP_DOCKER"
if [ -n "$SOURCE_URL" ]; then echo "  系统软件源地址: $SOURCE_URL"; fi
if [ -n "$DOCKER_SOURCE_URL" ]; then echo "  Docker CE软件源地址: $DOCKER_SOURCE_URL"; fi
if [ -n "$DOCKER_REGISTRY_URL" ]; then echo "  Docker镜像仓库地址: $DOCKER_REGISTRY_URL"; fi

# 调用docker.sh脚本处理系统换源和Docker安装
echo "=== 调用docker.sh脚本处理系统配置 ==="
# 构建传递给docker.sh的参数（使用数组处理参数更安全）
declare -a DOCKER_SH_ARGS=()
if [ "$SKIP_SOURCE" = "true" ]; then
  DOCKER_SH_ARGS+=("--skip-source")
fi
if [ "$SKIP_DOCKER" = "true" ]; then
  DOCKER_SH_ARGS+=("--skip-docker")
fi
if [ -n "$SOURCE_URL" ]; then
  DOCKER_SH_ARGS+=("--source-url" "$SOURCE_URL")
fi
if [ -n "$DOCKER_SOURCE_URL" ]; then
  DOCKER_SH_ARGS+=("--docker-source-url" "$DOCKER_SOURCE_URL")
fi
if [ -n "$DOCKER_REGISTRY_URL" ]; then
  DOCKER_SH_ARGS+=("--docker-registry-url" "$DOCKER_REGISTRY_URL")
fi

# 执行docker.sh脚本
sudo bash docker.sh "${DOCKER_SH_ARGS[@]}"

# 开始搭建 Pwn 环境
echo ""
echo "=== 开始搭建 Pwn 环境 ==="

# 1. 更新软件源并安装基础工具
echo '=== 更新软件源 ==='
sudo apt update -y

echo '=== 安装基础开发工具 ==='
sudo apt install -y vim gcc git python3-pip ruby ruby-dev build-essential libssl-dev cmake wabt curl libseccomp-dev libseccomp2 seccomp net-tools gcc-multilib g++-multilib

# 2. 配置 Python 环境
echo '=== 配置 Python 环境 ==='
# 处理 Python 3.12+ 的 EXTERNALLY-MANAGED 限制
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if [ -f /usr/lib/python${PYTHON_VERSION}/EXTERNALLY-MANAGED ]; then
    echo '处理Python EXTERNALLY-MANAGED限制（需root权限）'
    sudo mv /usr/lib/python${PYTHON_VERSION}/EXTERNALLY-MANAGED /usr/lib/python${PYTHON_VERSION}/EXTERNALLY-MANAGED.bk
fi

# 3. 安装 Pwndbg
echo '=== 安装 Pwndbg ==='
export PWNDBG_DIR=~/pwndbg
if [ ! -d "$PWNDBG_DIR" ]; then
  cd ~/
  git clone https://github.com/pwndbg/pwndbg
  cd ~/pwndbg
  ./setup.sh
  cd -
else
  echo "Pwndbg 目录已存在，跳过安装"
fi

# 4. 安装 Pwngdb
echo '=== 安装 Pwngdb ==='
if [ ! -d ~/Pwngdb ]; then
  git clone https://github.com/scwuaptx/Pwngdb
else
  echo "Pwngdb 目录已存在，跳过安装"
fi
# 5. 配置 .gdbinit 文件
echo '=== 配置 .gdbinit 文件 ==='
# 检查pwndbg和Pwngdb文件夹是否存在
if [ -d ~/pwndbg ] && [ -d ~/Pwngdb ]; then
  echo "pwndbg 和 Pwngdb 目录已存在，生成 .gdbinit 配置文件"
  cat > ~/.gdbinit << 'EOF'
source ~/pwndbg/gdbinit.py
source ~/Pwngdb/pwngdb.py
source ~/Pwngdb/angelheap/gdbinit.py

define hook-run
python
import angelheap
angelheap.init_angelheap()
end
end
EOF
else
  echo "pwndbg 或 Pwngdb 目录不存在，跳过 .gdbinit 配置"
fi
# 6. 安装其他pwn工具
echo '=== 安装 pwntools ==='
pip install pwntools --user

echo '=== 安装 LibcSearcher ==='
if [ ! -d ~/LibcSearcher ]; then
  git clone https://github.com/lieanu/LibcSearcher ~/LibcSearcher
  cd ~/LibcSearcher
  pip install -e . --user
  cd -
else
  echo "LibcSearcher 目录已存在，跳过安装"
fi

# 安装 Ruby 工具（需要sudo）
echo '=== 安装 Ruby 工具 ==='
sudo gem install one_gadget seccomp-tools

# 继续安装其他工具
echo '=== 安装 glibc-all-in-one ==='
if [ ! -d ~/glibc-all-in-one ]; then
  git clone https://github.com/matrix1001/glibc-all-in-one ~/glibc-all-in-one
  cd ~/glibc-all-in-one
  python3 update_list
  cd -
else
  echo "glibc-all-in-one 目录已存在，跳过安装"
fi

echo '=== 安装 patchelf ==='
sudo apt install patchelf -y

echo '=== 安装 free-libc ==='
if [ ! -d ~/free-libc ]; then
  git clone https://github.com/dsyzy/free-libc ~/free-libc
  cd ~/free-libc
  sudo sh ./install.sh
  cd -
else
  echo "free-libc 目录已存在，跳过安装"
fi

echo '=== 安装和编译 wabt ==='
if [ ! -d ~/wabt ]; then
  git clone --recursive https://github.com/WebAssembly/wabt ~/wabt
  cd ~/wabt
  mkdir -p build
  cd build
  cmake ..
  cmake --build .
  cd -
else
  echo "wabt 目录已存在，跳过安装"
fi

echo '=== 安装 Wasmtime ==='
if [ ! -d ~/.wasmtime ]; then
  curl https://wasmtime.dev/install.sh -sSf | bash
else
  echo ".wasmtime 目录已存在，跳过安装"
fi

# 7. 启用 i386 架构并安装相关库（需要sudo）
echo '=== 启用 i386 架构支持 ==='
sudo dpkg --add-architecture i386
sudo apt update -y
sudo apt install gcc-multilib g++-multilib -y

echo -e "\n=== Pwn 环境搭建完成！==="
echo "所有工具已安装在用户 ${CURRENT_USER} 的家目录中"
echo "运行 gdb 验证环境是否正常："
echo "  gdb"

echo -e "\n=== 所有操作完成！==="
