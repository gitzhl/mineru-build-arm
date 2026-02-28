# MinerU ARM64 构建指南 / MinerU ARM64 Build Guide

## 概述 / Overview

本项目提供了适用于 ARM64 (AArch64) + Ascend NPU 环境的 MinerU Docker 镜像构建方案。

This project provides MinerU Docker image build solution for ARM64 (AArch64) + Ascend NPU environment.

## 架构验证 / Architecture Verification

### 基础镜像分析

原始 Dockerfile 使用的镜像已经针对 ARM64 架构优化：

| 镜像 / Image | 架构支持 / Architecture Support |
|-------------|-------------------------------|
| `quay.m.daocloud.io/ascend/vllm-ascend:v0.11.0` | ARM64/AArch64 (专用) |
| `crpi-4crprmm5baj1v8iv.cn-hangzhou.personal.cr.aliyuncs.com/lmdeploy_dlinfer/ascend:mineru-a2` | ARM64/AArch64 (专用) |

✅ 所有依赖包均通过 apt 和 pip 安装，会自动适配 ARM64 架构

## 快速开始 / Quick Start

### 方法 1: Linux/macOS (Shell 脚本)

```bash
# 赋予执行权限
chmod +x build-arm.sh

# 构建镜像
./build-arm.sh [tag]

# 示例
./build-arm.sh v1.0
```

### 方法 2: Windows (PowerShell)

```powershell
# 以管理员身份运行 PowerShell
.\build-arm.ps1 v1.0
```

### 方法 3: 手动构建

```bash
# 创建 buildx 实例
docker buildx create --name arm-builder --driver docker-container --use

# 构建 ARM64 镜像
docker buildx build \
  --platform linux/arm64 \
  --file 2.Dockerfile \
  --tag mineru-ascend:latest \
  --progress=plain \
  --load \
  .
```

## 验证架构 / Verify Architecture

构建完成后验证镜像架构：

```bash
# 查看镜像架构信息
docker inspect mineru-ascend:latest | grep -A 5 "Architecture"

# 应该输出 / Should output:
# "Architecture": "arm64"
```

## 运行容器 / Running Container

### 基本运行命令

```bash
docker run --rm -it \
  --device=/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v ./data:/data \
  mineru-ascend:latest \
  mineru-cli -p /data/input.pdf -o /data/output
```

### 参数说明

| 参数 / Parameter | 说明 / Description |
|-----------------|-------------------|
| `--device=/dev/davinci*` | 昇腾 NPU 设备映射 / Ascend NPU device mapping |
| `--device=/dev/hisi_hdc` | 华为设备通道 / Huawei device channel |
| `-v ./data:/data` | 数据目录挂载 / Data directory mount |

## 多架构构建（可选）/ Multi-Arch Build (Optional)

如果需要同时支持多个架构：

```bash
# 使用多架构脚本
./build-multiarch.sh

# 或手动构建多平台
docker buildx build \
  --platform linux/arm64,linux/amd64 \
  --file 2.Dockerfile \
  --tag mineru-ascend:latest \
  --push \
  .
```

注意：多架构构建需要推送到 registry，不支持直接本地加载。

Note: Multi-arch builds require pushing to a registry and cannot be loaded directly.

## 常见问题 / Troubleshooting

### Q1: buildx 构建器创建失败

```bash
# 手动清理并重新创建
docker buildx rm builder-arm || true
docker buildx create --name builder-arm --driver docker-container --use
docker buildx inspect --bootstrap
```

### Q2: 平台不匹配错误

确保 Docker 运行在支持 ARM64 的环境中：
- 鲲鹏 ARM 服务器
- 通过 qemu-user-static 模拟（性能较低）

```bash
# 安装 qemu 模拟支持（x86_64 上测试用）
docker run --privileged --rm tonistiigi/binfmt --install all
```

### Q3: 依赖包安装失败

检查基础镜像是否正确拉取：

```bash
docker pull quay.m.daocloud.io/ascend/vllm-ascend:v0.11.0
docker inspect quay.m.daocloud.io/ascend/vllm-ascend:v0.11.0 | grep Architecture
```

## 系统要求 / System Requirements

- Docker 20.10+
- Docker Buildx 支持
- ARM64 (AArch64) 架构主机或模拟环境
- Ascend NPU 驱动和运行时
- 至少 16GB 内存 / At least 16GB RAM
- 至少 50GB 可用磁盘空间 / At least 50GB free disk space

## 文件说明 / File Description

| 文件 / File | 说明 / Description |
|------------|-------------------|
| `2.Dockerfile` | 原始 Dockerfile / Original Dockerfile |
| `build-arm.sh` | Linux/macOS ARM64 构建脚本 / Linux/macOS ARM64 build script |
| `build-arm.ps1` | Windows PowerShell 构建脚本 / Windows PowerShell build script |
| `build-multiarch.sh` | 多架构构建脚本 / Multi-arch build script |
| `BUILD_ARM.md` | 本文档 / This document |

## 技术支持 / Support

如遇问题，请检查：
1. Docker 和 Docker Buildx 版本
2. 基础镜像是否可访问
3. 网络连接是否稳定
4. 系统架构是否为 ARM64

For issues, please check:
1. Docker and Docker Buildx versions
2. Base image accessibility
3. Network connection stability
4. System architecture is ARM64
