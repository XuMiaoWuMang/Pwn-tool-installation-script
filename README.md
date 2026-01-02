# Pwn-tool-installation-script README文档

## 1. 脚本概述

### 1.1 主要功能与用途
Pwn-tool-installation-script是一套用于自动化搭建Pwn环境的脚本工具，主要功能包括：
- 系统软件源配置与优化
- Docker安装与配置
- 多种Pwn工具的自动化安装
- GDB调试环境配置
- 32位架构支持启用

### 1.2 适用操作系统环境
- Ubuntu系统（推荐Ubuntu 20.04及以上版本）
- 基于Debian的Linux发行版

### 1.3 前置依赖要求
- 需要具备sudo权限
- 系统已安装curl工具
- 稳定的网络连接

## 2. 目录结构

```
Pwn-tool-installation-script/
├── pwn_env_tools_user.sh  # 主安装脚本（用户版）
└── docker.sh              # 系统配置与Docker安装脚本
```

## 3. 详细使用方法

### 3.1 基础安装步骤

#### 3.1.1 克隆仓库
```bash
git clone https://github.com/XuMiaoWuMang/Pwn-tool-installation-script.git
cd Pwn-tool-installation-script
```

#### 3.1.2 运行主安装脚本
```bash
bash pwn_env_tools_user.sh
```

这将执行完整的安装流程，包括：
- 系统软件源配置
- Docker安装
- 所有Pwn工具安装
- GDB环境配置

### 3.2 高级配置选项

脚本支持多种命令行参数，用于自定义安装过程：

| 参数 | 说明 |
|------|------|
| `--skip-source` | 跳过系统软件源配置 |
| `--skip-docker` | 跳过Docker安装 |
| `--source-url <url>` | 指定系统软件源地址 |
| `--docker-source-url <url>` | 指定Docker CE软件源地址 |
| `--docker-registry-url <url>` | 指定Docker镜像仓库地址 |
| `--help` 或 `-h` | 显示帮助信息 |

### 3.3 自定义安装参数说明

#### 3.3.1 跳过特定步骤
```bash
# 跳过系统软件源配置，只安装Docker和工具
bash pwn_env_tools_user.sh --skip-source

# 跳过Docker安装，只进行系统换源和工具安装
bash pwn_env_tools_user.sh --skip-docker

# 只安装工具，跳过系统换源和Docker
bash pwn_env_tools_user.sh --skip-source --skip-docker
```

#### 3.3.2 使用自定义软件源
```bash
# 使用指定的系统软件源
bash pwn_env_tools_user.sh --source-url mirrors.ustc.edu.cn

# 使用指定的Docker源
bash pwn_env_tools_user.sh --docker-source-url mirrors.ustc.edu.cn/docker-ce --docker-registry-url registry.docker-cn.com
```

## 4. 使用示例

### 4.1 完整安装
```bash
bash pwn_env_tools_user.sh
```

### 4.2 仅安装工具（跳过系统配置）
```bash
bash pwn_env_tools_user.sh --skip-source --skip-docker
```

### 4.3 使用自定义软件源
```bash
bash pwn_env_tools_user.sh --source-url mirrors.ustc.edu.cn --docker-registry-url registry.docker-cn.com
```

### 4.4 验证安装结果
安装完成后，可以通过以下方式验证环境：
```bash
# 验证GDB插件

gdb

# 验证pwntools
python3 -c "import pwn; print(pwn.version)"

# 验证one_gadget
one_gadget --version
```

## 5. 安装的工具列表

### 5.1 调试工具
- **Pwndbg**：增强型GDB插件，提供丰富的Pwn调试功能
- **Pwngdb**：GDB插件，增强堆调试能力
- **one_gadget**：快速查找glibc中的one gadget
- **seccomp-tools**：seccomp过滤器分析工具

### 5.2 开发工具
- **pwntools**：Python库，用于编写exploit
- **LibcSearcher**：Libc版本查找工具
- **glibc-all-in-one**：多种glibc版本集合
- **patchelf**：修改ELF文件的工具
- **free-libc**：自由获取glibc的工具

### 5.3 WebAssembly工具
- **wabt**：WebAssembly二进制工具包
- **Wasmtime**：WebAssembly运行时

## 6. 常见问题解决方法

### 6.1 SSH私钥权限问题
**问题**：`Permissions 0664 for '/home/pwn/.ssh/github' are too open.`
**解决方案**：修改私钥文件权限
```bash
chmod 600 ~/.ssh/github ~/.ssh/gitee
```

### 6.2 Python EXTERNALLY-MANAGED限制
**问题**：在Python 3.12+版本中遇到pip安装限制
**解决方案**：脚本已自动处理，将EXTERNALLY-MANAGED文件重命名

### 6.3 网络连接问题
**问题**：git clone或curl下载失败
**解决方案**：检查网络连接，或尝试使用国内镜像源

### 6.4 权限不足问题
**问题**：安装过程中遇到权限错误
**解决方案**：确保当前用户具有sudo权限，并且在运行脚本时输入正确的sudo密码

## 7. 脚本工作流程

1. **参数解析**：读取命令行参数，设置安装选项
2. **系统配置**：调用docker.sh脚本处理系统软件源和Docker安装
3. **基础工具安装**：安装开发所需的基础软件包
4. **Python环境配置**：处理Python 3.12+的EXTERNALLY-MANAGED限制
5. **Pwn工具安装**：克隆并安装各种Pwn工具
6. **GDB配置**：生成.gdbinit文件，配置调试环境
7. **架构支持**：启用i386架构支持

## 8. 注意事项

1. 脚本会自动处理大部分依赖关系，但仍需确保系统已安装curl
2. 安装过程中需要多次输入sudo密码，请确保当前用户具有sudo权限
3. 建议在全新的Ubuntu系统上使用该脚本，以避免与现有配置冲突
4. 脚本会在用户家目录下安装所有工具，不会影响系统全局配置
5. 如果遇到网络问题，可以尝试使用`--skip-source`参数跳过系统换源
6. 如果在做pwn时不是用root，请不要使用root用户运行此脚本，会导致所有工具安装在/root目录下，并且由于root权限太高，此脚本无法保证运行效果达到预期效果

# 9. 后续维护

- 定期更新脚本以获取最新的工具版本
- 根据需要手动更新已安装的工具
- 如果工具目录已存在，脚本会跳过安装该工具

## 10. 联系方式

如有问题或建议，欢迎提交Issue或Pull Request。

---

**文档版本**：v1.0
**更新日期**：2026-01-02
**适用脚本版本**：v1.0