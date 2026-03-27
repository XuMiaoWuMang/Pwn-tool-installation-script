# Pwn-tool-installation-script

## 项目简介

Pwn-tool-installation-script 是一套用于自动化搭建 Pwn 环境的脚本工具，以普通用户身份运行，仅在需要时使用 sudo 提升权限。脚本会自动完成系统软件源配置、Docker 安装以及多种 Pwn 工具的安装。

## 适用环境

- Ubuntu 系统（推荐 Ubuntu 20.04 及以上版本）
- 基于 Debian 的 Linux 发行版

## 前置要求

- 需要具备 sudo 权限
- 系统已安装 curl 工具
- 稳定的网络连接

> **注意**：脚本会先执行 apt 换源，然后安装 docker，最后安装 pwn 工具（大部分都是 GitHub 上的项目），如果你代理的规则不够健全，可能导致换源后执行 apt upgrade 失败。

## 目录结构

```
Pwn-tool-installation-script/
├── pwn_env_tools_user.sh  # 主安装脚本（用户版）
└── docker.sh              # 系统配置与Docker安装脚本
```

## 快速开始

### 克隆仓库

```bash
git clone https://github.com/XuMiaoWuMang/Pwn-tool-installation-script.git
cd Pwn-tool-installation-script
```

### 执行安装

```bash
bash pwn_env_tools_user.sh
```

这将执行完整的安装流程，包括：
- 系统软件源配置
- Docker 安装
- 所有 Pwn 工具安装
- GDB 环境配置

## 命令行参数

| 参数 | 说明 |
|------|------|
| `--skip-source` | 跳过系统软件源配置 |
| `--skip-docker` | 跳过 Docker 安装 |
| `--source-url <url>` | 指定系统软件源地址 |
| `--docker-source-url <url>` | 指定 Docker CE 软件源地址 |
| `--docker-registry-url <url>` | 指定 Docker 镜像仓库地址 |
| `--help` 或 `-h` | 显示帮助信息 |

## 使用示例

### 完整安装

```bash
bash pwn_env_tools_user.sh
```

### 跳过特定步骤

```bash
# 跳过系统软件源配置，只安装 Docker 和工具
bash pwn_env_tools_user.sh --skip-source

# 跳过 Docker 安装，只进行系统换源和工具安装
bash pwn_env_tools_user.sh --skip-docker

# 只安装工具，跳过系统换源和 Docker
bash pwn_env_tools_user.sh --skip-source --skip-docker
```

### 使用自定义软件源

```bash
# 使用指定的系统软件源
bash pwn_env_tools_user.sh --source-url mirrors.ustc.edu.cn

# 使用指定的 Docker 源
bash pwn_env_tools_user.sh --docker-source-url mirrors.ustc.edu.cn/docker-ce --docker-registry-url registry.docker-cn.com
```

### 验证安装结果

```bash
# 验证 GDB 插件
gdb

# 验证 pwntools
python3 -c "import pwn; print(pwn.version)"

# 验证 one_gadget
one_gadget --version
```

## 安装的工具列表

### 调试工具

| 工具 | 说明 |
|------|------|
| **Pwndbg** | 增强型 GDB 插件，提供丰富的 Pwn 调试功能 |
| **Pwngdb** | GDB 插件，增强堆调试能力 |
| **one_gadget** | 快速查找 glibc 中的 one gadget |
| **seccomp-tools** | seccomp 过滤器分析工具 |

### 开发工具

| 工具 | 说明 |
|------|------|
| **pwntools** | Python 库，用于编写 exploit |
| **LibcSearcher** | Libc 版本查找工具 |
| **glibc-all-in-one** | 多种 glibc 版本集合 |
| **patchelf** | 修改 ELF 文件的工具 |
| **free-libc** | 自由获取 glibc 的工具 |

### AWD 比赛工具

| 工具 | 说明 |
|------|------|
| **evilPatcher** | AWD 比赛补丁工具 |
| **AwdPwnPatcher** | AWD 比赛 PWN 补丁工具 |

### WebAssembly 工具

| 工具 | 说明 |
|------|------|
| **wabt** | WebAssembly 二进制工具包 |
| **Wasmtime** | WebAssembly 运行时 |

### 基础开发工具

脚本还会安装以下基础开发工具：
- vim, gcc, git
- python3-pip
- ruby, ruby-dev
- build-essential, libssl-dev, cmake
- curl, net-tools
- libseccomp-dev, libseccomp2, seccomp
- gcc-multilib, g++-multilib
- gdb

## 脚本工作流程

1. **参数解析**：读取命令行参数，设置安装选项
2. **系统配置**：调用 docker.sh 脚本处理系统软件源和 Docker 安装
3. **基础工具安装**：安装开发所需的基础软件包
4. **Python 环境配置**：处理 Python 3.12+ 的 EXTERNALLY-MANAGED 限制
5. **Pwndbg 安装**：克隆并安装 Pwndbg 调试插件
6. **Pwngdb 安装**：克隆 Pwngdb 插件
7. **GDB 配置**：生成 .gdbinit 文件，配置调试环境
8. **Pwn 工具安装**：安装 pwntools、LibcSearcher、one_gadget、seccomp-tools 等工具
9. **AWD 工具安装**：安装 evilPatcher、AwdPwnPatcher
10. **glibc 工具安装**：安装 glibc-all-in-one、patchelf、free-libc
11. **WebAssembly 工具安装**：安装 wabt、Wasmtime
12. **架构支持**：启用 i386 架构支持

## 常见问题

### SSH 私钥权限问题

**问题**：`Permissions 0664 for '/home/pwn/.ssh/github' are too open.`

**解决方案**：
```bash
chmod 600 ~/.ssh/github ~/.ssh/gitee
```

### Python EXTERNALLY-MANAGED 限制

**问题**：在 Python 3.12+ 版本中遇到 pip 安装限制

**解决方案**：脚本已自动处理，将 EXTERNALLY-MANAGED 文件重命名

### 网络连接问题

**问题**：git clone 或 curl 下载失败

**解决方案**：检查网络连接，或尝试使用国内镜像源

### 权限不足问题

**问题**：安装过程中遇到权限错误

**解决方案**：确保当前用户具有 sudo 权限，并且在运行脚本时输入正确的 sudo 密码

## 注意事项

1. 脚本会自动处理大部分依赖关系，但仍需确保系统已安装 curl
2. 安装过程中需要多次输入 sudo 密码，请确保当前用户具有 sudo 权限
3. 建议在全新的 Ubuntu 系统上使用该脚本，以避免与现有配置冲突
4. 脚本会在用户家目录下安装所有工具，不会影响系统全局配置
5. 如果遇到网络问题，可以尝试使用 `--skip-source` 参数跳过系统换源
6. **重要**：如果在做 pwn 时不是用 root，请不要使用 root 用户运行此脚本，会导致所有工具安装在 /root 目录下，并且由于 root 权限太高，此脚本无法保证运行效果达到预期效果

## 后续维护

- 定期更新脚本以获取最新的工具版本
- 根据需要手动更新已安装的工具
- 如果工具目录已存在，脚本会跳过安装该工具

## 相关项目

本脚本在系统软件源配置部分参考了以下优秀项目：

- **[SuperManito/LinuxMirrors](https://github.com/SuperManito/LinuxMirrors)** - 一个功能强大的 Linux 软件源切换工具，支持多种 Linux 发行版和国内镜像源

## 联系方式

如有问题或建议，欢迎提交 Issue 或 Pull Request。
