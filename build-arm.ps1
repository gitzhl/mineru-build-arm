# Docker buildx 构建脚本 - Windows PowerShell 版本
# Docker buildx build script - Windows PowerShell version

$ErrorActionPreference = "Stop"

# 配置变量
$ImageName = "mineru-ascend"
$ImageTag = if ($args.Count -gt 0) { $args[0] } else { "latest" }
$Platform = "linux/arm64"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "构建 ARM64 架构镜像 / Building ARM64 image" -ForegroundColor Cyan
Write-Host "镜像名称 / Image: ${ImageName}:${ImageTag}" -ForegroundColor Green
Write-Host "平台 / Platform: ${Platform}" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

# 检查 docker 是否可用
try {
    docker version | Out-Null
} catch {
    Write-Host "错误 / Error: Docker 未运行或未安装 / Docker not running or not installed" -ForegroundColor Red
    exit 1
}

# 检查 buildx
try {
    docker buildx version | Out-Null
} catch {
    Write-Host "错误 / Error: docker buildx 不可用 / docker buildx not available" -ForegroundColor Red
    exit 1
}

# 创建并使用 buildx 构建器
Write-Host "设置 buildx 构建器 / Setting up buildx builder..." -ForegroundColor Yellow
docker buildx create --name builder-arm --driver docker-container --use 2>$null
docker buildx inspect --bootstrap

# 构建镜像
Write-Host "开始构建 / Starting build..." -ForegroundColor Yellow
docker buildx build `
    --platform ${Platform} `
    --file 2.Dockerfile `
    --tag "${ImageName}:${ImageTag}" `
    --progress plain `
    --load `
    .

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "构建完成！/ Build completed!" -ForegroundColor Green
Write-Host "镜像 / Image: ${ImageName}:${ImageTag}" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

# 验证镜像
Write-Host ""
Write-Host "验证镜像信息 / Verify image info:" -ForegroundColor Yellow
docker inspect "${ImageName}:${ImageTag}" | Select-String -Pattern "Architecture" -Context 0,5

Write-Host ""
Write-Host "运行容器示例 / Run container example:" -ForegroundColor Yellow
Write-Host "docker run --rm -it `" -ForegroundColor White
Write-Host "  --device=/dev/davinci0 `" -ForegroundColor White
Write-Host "  --device=/dev/davinci_manager `" -ForegroundColor White
Write-Host "  --device=/dev/devmm_svm `" -ForegroundColor White
Write-Host "  --device=/dev/hisi_hdc `" -ForegroundColor White
Write-Host "  -v `$PWD/data:/data `" -ForegroundColor White
Write-Host "  `${ImageName}:${ImageTag} `" -ForegroundColor White
Write-Host "  mineru-cli -p /data/input.pdf -o /data/output" -ForegroundColor White
Write-Host ""
