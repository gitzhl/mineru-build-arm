# MinerU ARM64 构建指南

## 当前环境限制
在 Windows x86_64 上通过 QEMU 模拟 ARM64 时，安装字体会触发 `libc-bin` 的 post-installation 脚本段错误。

## 构建方案

### 方案 1：分层构建（推荐用于开发测试）

#### 步骤 1：在 Windows 上构建基础层（无字体）
```bash
docker buildx build --platform linux/arm64 --file Dockerfile.base --tag mineru-ascend:base --load .
```

#### 步骤 2：推送到镜像仓库
```bash
# 推送到 Docker Hub 或其他仓库
docker tag mineru-ascend:base your-registry/mineru-ascend:base
docker push your-registry/mineru-ascend:base
```

#### 步骤 3：在真实 ARM64 设备上添加字体
```bash
# 在 ARM64 设备上拉取并添加字体层
docker pull your-registry/mineru-ascend:base
docker build --file Dockerfile.fonts --tag mineru-ascend:latest .
```

### 方案 2：使用 GitHub Actions 自动构建

创建 `.github/workflows/build-arm64.yml`:

```yaml
name: Build ARM64 Image

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build-arm64:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./2.Dockerfile
          platforms: linux/arm64
          push: true
          tags: your-registry/mineru-ascend:latest
```

### 方案 3：使用云端 ARM64 构建服务

- **Docker Hub Automated Builds**: 支持多架构构建
- **GitHub Container Registry (GHCR)**: 免费且支持 ARM64
- **阿里云容器镜像服务**: 国内访问快，支持 ARM64 构建

### 方案 4：在真实 ARM64 设备上直接构建

如果您有访问 ARM64 服务器（如华为云鲲鹏实例、AWS Graviton 等）：

```bash
# 将 2.Dockerfile 上传到 ARM64 服务器
scp 2.Dockerfile user@arm64-server:/path/to/build/

# SSH 登录并构建
ssh user@arm64-server
cd /path/to/build
docker build --file 2.Dockerfile --tag mineru-ascend:latest .
```

## 临时解决方案：跳过字体安装

如果您的应用对中文字体要求不高，可以使用 `Dockerfile.minimal`（已创建），它跳过了字体安装步骤。

**注意**：没有中文字体时，MinerU 处理中文 PDF 可能会显示方框或乱码。

## 推荐流程

1. **开发阶段**: 使用 `Dockerfile.minimal` 在本地快速测试
2. **生产部署**: 使用 GitHub Actions 或在 ARM64 服务器上构建完整镜像
3. **字体处理**: 可以通过 Docker 卷挂载宿主机的字体文件作为临时解决方案
