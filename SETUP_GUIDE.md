# GitHub Actions 设置快速指南

## 当前状态
✅ Git 仓库已初始化
✅ 所有文件已提交
⏳ 等待推送到 GitHub

---

## 接下来的步骤（5 分钟完成）

### 步骤 1: 创建 GitHub 仓库

1. 访问 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: mineru-ascend-arm64（或您喜欢的名字）
   - **Description**: MinerU ARM64 Docker image with Ascend NPU support
   - **Visibility**: 选择 **Public**（免费构建）或 **Private**
   - **不要**勾选 "Add a README file"（我们已经有了）
3. 点击 **Create repository**

### 步骤 2: 推送代码到 GitHub

在当前目录执行以下命令（**替换 YOUR_USERNAME**）：

```bash
# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/mineru-ascend-arm64.git

# 推送代码
git branch -M main
git push -u origin main
```

**示例（假设用户名是 johndoe）**：
```bash
git remote add origin https://github.com/johndoe/mineru-ascend-arm64.git
git branch -M main
git push -u origin main
```

### 步骤 3: 启用 GitHub Actions

1. 推送成功后，访问您的仓库页面
2. 点击顶部的 **Actions** 标签
3. 如果提示启用 Actions，点击 **I understand my workflows, go ahead and enable them**
4. 您应该看到 **Build MinerU ARM64 Image** 工作流开始运行

### 步骤 4: 监控构建进度

1. 在 Actions 页面点击正在运行的工作流
2. 查看实时构建日志
3. 构建时间约 **10-20 分钟**（首次构建可能更长）

### 步骤 5: 验证镜像构建成功

构建完成后：
1. 在 Actions 页面看到绿色的 ✅
2. 访问仓库的 **Packages** 页面（如果使用 GHCR）
   - URL: https://github.com/YOUR_USERNAME?tab=packages

---

## 拉取并使用镜像

构建完成后，在您的 ARM64 设备上：

```bash
# 登录到 GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# 拉取镜像
docker pull ghcr.io/YOUR_USERNAME/mineru-ascend-arm64:latest

# 运行容器
docker run --rm -it \
  --device=/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /path/to/pdfs:/data \
  ghcr.io/YOUR_USERNAME/mineru-ascend-arm64:latest \
  mineru-cli-pdf -p /data/input.pdf -o /data/output
```

---

## 手动触发构建

推送代码后，您可以随时手动触发构建：

1. 访问仓库的 **Actions** 标签
2. 左侧选择 **Build MinerU ARM64 Image**
3. 点击右侧 **Run workflow** 按钮
4. 选择分支（通常为 `main`）
5. 点击绿色 **Run workflow** 按钮

---

## 常见问题

### Q: 推送时提示 "Permission denied"
**A**: 确保已配置 Git 凭据或使用 SSH：
```bash
# SSH 方式
git remote set-url origin git@github.com:YOUR_USERNAME/mineru-ascend-arm64.git
```

### Q: Actions 构建失败
**A**:
1. 检查 Actions 日志查看具体错误
2. 确认使用的是 2.Dockerfile（包含完整字体）
3. 基础镜像可能需要时间下载

### Q: 如何设置自动推送？
**A**: 当前配置已在以下情况自动触发：
- 推送到 main/master 分支
- 创建版本标签（如 v1.0.0）
- Pull Request（仅构建，不推送）

### Q: 镜像存储费用？
**A**:
- **GitHub Container Registry**: 公开仓库免费，私有仓库有存储限制
- **Docker Hub**: 免费账户有拉取限制和存储限制
- 推荐使用 GHCR + 公开仓库（完全免费）

---

## 仓库文件结构

推送成功后，您的仓库结构：

```
mineru-ascend-arm64/
├── .github/
│   └── workflows/
│       └── build-arm64.yml    # 自动构建配置
├── 2.Dockerfile               # 主 Dockerfile
├── Dockerfile.base            # 基础版（可选）
├── Dockerfile.fonts           # 字体层（可选）
├── README.md                  # 使用文档
└── SETUP_GUIDE.md             # 本指南
```

---

## 下一步

构建成功后，您可以：
1. 在 ARM64 设备上测试镜像
2. 发布版本标签 `git tag v1.0.0 && git push --tags`
3. 修改工作流配置自定义构建参数
4. 添加更多测试和工作流步骤

---

**需要帮助？** 查看 README.md 或提交 Issue
