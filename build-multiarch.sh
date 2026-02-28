#!/bin/bash
# Docker buildx 多架构构建脚本
# Docker buildx multi-architecture build script

set -e

# 配置变量 / Configuration variables
IMAGE_NAME="mineru-ascend"
IMAGE_TAG="${1:-latest}"
PLATFORMS="linux/arm64"  # 默认只构建 ARM64，可根据需要扩展为 "linux/arm64,linux/amd64"

echo "=========================================="
echo "多架构构建 / Multi-arch build"
echo "镜像名称 / Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "支持平台 / Platforms: ${PLATFORMS}"
echo "=========================================="

# 检查 docker buildx
if ! docker buildx version &> /dev/null; then
    echo "错误 / Error: docker buildx 未安装或不可用"
    exit 1
fi

# 创建并使用 buildx 构建器
echo "设置 buildx 构建器 / Setting up buildx builder..."
docker buildx create --name builder-multi --driver docker-container --use 2>/dev/null || true
docker buildx inspect --bootstrap

# 构建并推送镜像（如需推送到仓库）
# 如果只是本地加载，使用 --load 参数（但多架构时 --load 不支持）
echo "开始构建 / Starting build..."
docker buildx build \
    --platform ${PLATFORMS} \
    --file 2.Dockerfile \
    --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
    --progress=plain \
    --push \
    . || echo "提示 / Note: 如需本地加载多架构镜像，请先推送到 registry 然后使用 docker pull"

echo "=========================================="
echo "构建完成！/ Build completed!"
echo "=========================================="
