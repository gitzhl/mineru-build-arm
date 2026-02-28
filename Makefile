.PHONY: all build build-arm build-multiarch clean help verify

# 默认目标
all: build-arm

# 镜像配置
IMAGE_NAME := mineru-ascend
IMAGE_TAG := latest
PLATFORM := linux/arm64

# 构建 ARM64 镜像
build-arm:
	@echo "构建 ARM64 镜像 / Building ARM64 image..."
	@if [ -f build-arm.sh ]; then \
		chmod +x build-arm.sh && \
		./build-arm.sh $(IMAGE_TAG); \
	else \
		echo "错误 / Error: build-arm.sh 不存在 / not found"; \
		exit 1; \
	fi

# 多架构构建
build-multiarch:
	@echo "多架构构建 / Multi-arch build..."
	@if [ -f build-multiarch.sh ]; then \
		chmod +x build-multiarch.sh && \
		./build-multiarch.sh $(IMAGE_TAG); \
	else \
		echo "错误 / Error: build-multiarch.sh 不存在 / not found"; \
		exit 1; \
	fi

# 验证镜像
verify:
	@echo "验证镜像架构 / Verifying image architecture..."
	@docker inspect $(IMAGE_NAME):$(IMAGE_TAG) | grep -A 5 "Architecture" || echo "镜像不存在 / Image not found"

# 快速构建（不使用脚本）
build:
	@echo "快速构建 / Quick build..."
	docker buildx create --name quick-builder --driver docker-container --use 2>/dev/null || \
	docker buildx use quick-builder
	docker buildx build \
		--platform $(PLATFORM) \
		--file 2.Dockerfile \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		--progress=plain \
		--load \
		.

# 清理构建缓存
clean:
	@echo "清理 Docker 构建缓存 / Cleaning Docker build cache..."
	@docker buildx prune -f
	@echo "清理完成 / Cleanup completed"

# 显示帮助信息
help:
	@echo "可用的 make 目标 / Available make targets:"
	@echo ""
	@echo "  make build-arm      - 构建 ARM64 镜像（推荐）/ Build ARM64 image (recommended)"
	@echo "  make build          - 快速构建（不使用脚本）/ Quick build (no script)"
	@echo "  make build-multiarch- 多架构构建（需要推送）/ Multi-arch build (requires push)"
	@echo "  make verify         - 验证镜像架构 / Verify image architecture"
	@echo "  make clean          - 清理构建缓存 / Clean build cache"
	@echo "  make help           - 显示此帮助 / Show this help"
	@echo ""
	@echo "示例 / Examples:"
	@echo "  make build-arm                    # 构建 ARM64 镜像"
	@echo "  IMAGE_TAG=v1.0 make build-arm     # 使用自定义标签构建"
	@echo "  make verify                       # 验证构建结果"
