# MinerU ARM64 Docker Image

通过 GitHub Actions 自动构建的 MinerU ARM64 镜像，用于华为 Ascend NPU 环境。

[![Build ARM64](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/build-arm64.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/build-arm64.yml)

## 功能特性

- ✅ ARM64 (AArch64) 架构支持
- ✅ 集成 vLLM + Ascend NPU 支持
- ✅ 完整的中文字体支持
- ✅ 预下载 MinerU 模型
- ✅ 多架构标签管理

## 快速开始

### 1. 准备工作

#### 创建 GitHub 仓库

```bash
# 初始化仓库（已完成）
git init

# 添加所有文件
git add .

# 首次提交
git commit -m "Initial commit: Add MinerU ARM64 Docker build"
```

#### 创建 GitHub 仓库

访问 [GitHub](https://github.com/new) 创建新仓库，然后连接：

```bash
# 添加远程仓库（替换 YOUR_USERNAME 和 YOUR_REPO）
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

### 2. 启用 GitHub Actions

推送代码后，GitHub Actions 会自动开始构建：

1. 访问仓库的 **Actions** 标签页
2. 查看 **Build MinerU ARM64 Image** 工作流
3. 等待构建完成（约 10-20 分钟）

### 3. 手动触发构建

在 GitHub 仓库页面：
1. 点击 **Actions** 标签
2. 选择 **Build MinerU ARM64 Image**
3. 点击 **Run workflow**
4. 选择分支并点击 **Run workflow**

### 4. 拉取镜像

构建完成后，在 ARM64 设备上拉取：

```bash
# 从 GitHub Container Registry 拉取
docker pull ghcr.io/YOUR_USERNAME/YOUR_REPO:latest

# 或拉取特定版本
docker pull ghcr.io/YOUR_USERNAME/YOUR_REPO:v1.0.0
```

### 5. 运行容器

```bash
docker run --rm -it \
  --device=/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /path/to/pdfs:/data \
  ghcr.io/YOUR_USERNAME/YOUR_REPO:latest \
  mineru-cli-pdf -p /data/input.pdf -o /data/output
```

## 镜像标签

| 标签 | 说明 |
|------|------|
| `latest` | 最新稳定版本（main 分支） |
| `v1.0.0` | 特定版本号（Git 标签） |
| `main-abc1234` | 特定提交（分支名 + SHA） |

## 配置说明

### 修改镜像仓库

编辑 `.github/workflows/build-arm64.yml`:

```yaml
env:
  # 使用 GitHub Container Registry (推荐)
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

  # 或使用 Docker Hub
  # REGISTRY: docker.io
  # IMAGE_NAME: YOUR_DOCKERHUB_USERNAME/YOUR_REPO_NAME
```

### 使用 Docker Hub

如果使用 Docker Hub，需要在仓库设置中添加 Secrets：
1. 访问仓库 **Settings** > **Secrets and variables** > **Actions**
2. 添加以下 Secrets：
   - `DOCKER_USERNAME`: Docker Hub 用户名
   - `DOCKER_PASSWORD`: Docker Hub 访问令牌

然后在工作流文件中取消注释 Docker Hub 登录步骤。

## 文件说明

```
.
├── .github/
│   └── workflows/
│       └── build-arm64.yml    # GitHub Actions 工作流配置
├── 2.Dockerfile               # 主要 Dockerfile（包含字体）
├── Dockerfile.base            # 基础镜像（无字体，用于本地测试）
├── Dockerfile.fonts           # 字体层（在 ARM64 设备上添加）
├── 2.Dockerfile.minimal       # 简化版（跳过字体，QEMU 兼容）
├── .dockerignore              # Docker 构建排除文件
└── README.md                  # 本文档
```

## 故障排除

### 构建失败：字体安装错误

GitHub Actions 在真实 ARM64 环境运行，不应出现字体安装问题。如果仍然失败：
- 检查基础镜像是否可用
- 查看 Actions 日志获取详细错误

### 镜像拉取失败

1. 确认您已登录：
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
   ```

2. 或设置仓库为公开（Public）

### 权限错误

确保在 ARM64 设备上有权限访问 NPU 设备：
```bash
ls -l /dev/davinci*
```

## 本地测试（可选）

在 Windows 上测试基础层（无字体）：

```bash
docker buildx build --platform linux/arm64 \
  --file Dockerfile.base \
  --tag mineru-ascend:base \
  --load .
```

## 相关资源

- [MinerU 官方文档](https://github.com/opendatalab/MinerU)
- [Ascend NPU 文档](https://www.hiascend.com/document)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)

## 许可证

本构建配置遵循 MIT 许可证。

## 支持

如有问题，请在 [Issues](https://github.com/YOUR_USERNAME/YOUR_REPO/issues) 中提出。
