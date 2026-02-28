#!/bin/bash
# Docker buildx 构建脚本 - 支持 ARM64/AArch64 架构
# Docker buildx build script - Supporting ARM64/AArch64 architecture

set -e

# 配置变量 / Configuration variables
IMAGE_NAME="mineru-ascend"
IMAGE_TAG="${1:-latest}"
PLATFORM="linux/arm64"  # 目标平台 ARM64

echo "=========================================="
echo "构建 ARM64 架构镜像 / Building ARM64 image"
echo "镜像名称 / Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "平台 / Platform: ${PLATFORM}"
echo "=========================================="

# 检查 docker buildx 是否可用 / Check if docker buildx is available
if ! docker buildx version &> /dev/null; then
    echo "错误 / Error: docker buildx 未安装或不可用 / not installed or not available"
    exit 1
fi

# 创建并使用 buildx 构建器 / Create and use buildx builder
echo "设置 buildx 构建器 / Setting up buildx builder..."
docker buildx create --name builder-arm --driver docker-container --use 2>/dev/null || true
docker buildx inspect --bootstrap

# 构建镜像 / Build image
echo "开始构建 / Starting build..."
docker buildx build \
    --platform ${PLATFORM} \
    --file 2.Dockerfile \
    --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
    --progress=plain \
    --load \
    .

echo "=========================================="
echo "构建完成！/ Build completed!"
echo "镜像 / Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "架构 / Architecture: ${PLATFORM}"
echo ""
echo "验证镜像信息 / Verify image info:"
docker inspect "${IMAGE_NAME}:${IMAGE_TAG}" | grep -A 5 "Architecture"
echo "=========================================="

# 显示使用说明 / Show usage instructions
echo ""
echo "运行容器示例 / Run container example:"
echo "docker run --rm -it \\"
echo "  --device=/dev/davinci0 \\"
echo "  --device=/dev/davinci_manager \\"
echo "  --device=/dev/devmm_svm \\"
echo "  --device=/dev/hisi_hdc \\"
echo "  -v ./data:/data \\"
echo "  \"${IMAGE_NAME}:${IMAGE_TAG}\" \\"
echo "  mineru-cli -p /data/input.pdf -o /data/output"
echo ""
