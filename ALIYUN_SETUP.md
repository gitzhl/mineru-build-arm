# 阿里云容器镜像服务配置指南

## 📋 配置概览

- **Registry**: `registry.cn-hangzhou.aliyuncs.com`
- **Username**: `18970973195`
- **命名空间**: `mycangku_tusuklll`
- **镜像名称**: `registry.cn-hangzhou.aliyuncs.com/mycangku_tusuklll/mineru-ascend`

---

## 🔑 第一步：获取阿里云访问密码

### 1.1 设置阿里云容器镜像服务密码

1. 访问 [阿里云容器镜像服务控制台](https://cr.console.aliyun.com/)
2. 登录您的阿里云账号（用户名：18970973195）
3. 如果首次使用，可能需要开通服务
4. 点击右上角 **"设置Registry登录密码"** 或访问 **"访问凭证"** 页面
5. 设置固定的访问密码（请记住此密码）

### 1.2 验证密码（可选）

在本地终端测试：
```bash
docker login --username=18970973195 registry.cn-hangzhou.aliyuncs.com
# 输入刚才设置的密码
```

如果显示 "Login Succeeded" 表示密码正确。

---

## 🔐 第二步：配置 GitHub Secrets

### 2.1 访问 GitHub 仓库设置

1. 访问您的 GitHub 仓库：
   ```
   https://github.com/TuJinkai/mineru-build-arm
   ```

2. 点击顶部的 **Settings** 标签

3. 在左侧菜单中找到 **Secrets and variables** > **Actions**

### 2.2 添加阿里云密码 Secret

1. 点击 **"New repository secret"** 按钮
2. 填写信息：
   - **Name**: `ALIYUN_REGISTRY_PASSWORD`
   - **Secret**: 输入您在阿里云设置的 Registry 登录密码
3. 点击 **"Add secret"** 保存

### ✅ 验证 Secret 配置

Secret 列表中应该显示：
- `ALIYUN_REGISTRY_PASSWORD`  （刚添加的）

---

## 📝 第三步：确认阿里云命名空间

### 3.1 检查命名空间是否存在

1. 访问 [阿里云容器镜像服务控制台](https://cr.console.aliyun.com/)
2. 点击左侧 **"命名空间"**
3. 确认是否存在命名空间：`mycangku_tusuklll`

### 3.2 如果命名空间不存在

创建命名空间：
1. 点击 **"创建命名空间"**
2. 填写：
   - **命名空间名称**: `mycangku_tusuklll`
   - **是否自动创建仓库**: 选择是
3. 点击 **"确定"**

---

## 🚀 第四步：提交并推送代码

### 4.1 查看修改的内容

```bash
git diff .github/workflows/build-arm64.yml
```

### 4.2 提交修改

```bash
git add .github/workflows/build-arm64.yml
git commit -m "feat: Configure Aliyun Container Registry for image hosting"

git push
```

### 4.3 触发自动构建

推送后，GitHub Actions 会自动开始构建并推送到阿里云。

---

## 🎯 第五步：验证构建和推送

### 5.1 查看 GitHub Actions

访问：
```
https://github.com/TuJinkai/mineru-build-arm/actions
```

### 5.2 查看阿里云镜像仓库

构建成功后：
1. 访问 [阿里云容器镜像服务控制台](https://cr.console.aliyun.com/)
2. 点击 **"镜像仓库"**
3. 找到命名空间 `mycangku_tusuklll`
4. 查看镜像 `mineru-ascend`

---

## 📦 第六步：在 ARM64 设备上拉取镜像

### 6.1 登录阿里云容器镜像服务

```bash
docker login --username=18970973195 registry.cn-hangzhou.aliyuncs.com
# 输入密码
```

### 6.2 拉取镜像

```bash
# 拉取最新版本
docker pull registry.cn-hangzhou.aliyuncs.com/mycangku_tusuklll/mineru-ascend:latest

# 拉取特定版本
docker pull registry.cn-hangzhou.aliyuncs.com/mycangku_tusuklll/mineru-ascend:v1.0.0
```

### 6.3 运行容器

```bash
docker run --rm -it \
  --device=/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /data:/data \
  registry.cn-hangzhou.aliyuncs.com/mycangku_tusuklll/mineru-ascend:latest \
  mineru-cli-pdf -p /data/input.pdf -o /data/output
```

---

## 🔄 工作流配置说明

### 自动触发条件
- 推送到 `main` 或 `master` 分支
- 推送版本标签（如 `v1.0.0`）
- Pull Request（仅构建，不推送）

### 手动触发
1. 访问 Actions 页面
2. 选择 "Build MinerU ARM64 Image"
3. 点击 "Run workflow"

### 镜像标签策略
- `latest` - main 分支最新版本
- `v1.0.0` - Git 标签对应的版本
- `main-abc1234` - 分支名 + Git SHA

---

## ⚙️ 自定义配置

### 修改命名空间

如果您的阿里云命名空间不是 `tujinkai`，修改 `.github/workflows/build-arm64.yml`:

```yaml
env:
  REGISTRY: registry.cn-hangzhou.aliyuncs.com
  # 修改这里的命名空间/镜像名
  IMAGE_NAME: your-namespace/your-image-name
```

### 使用其他区域的阿里云仓库

如果需要使用其他区域，修改 `REGISTRY`:

| 区域 | Registry 地址 |
|------|--------------|
| 杭州 | `registry.cn-hangzhou.aliyuncs.com` |
| 上海 | `registry.cn-shanghai.aliyuncs.com` |
| 北京 | `registry.cn-beijing.aliyuncs.com` |
| 深圳 | `registry.cn-shenzhen.aliyuncs.com` |
| 广州 | `registry.cn-guangzhou.aliyuncs.com` |

---

## 🐛 常见问题

### Q1: GitHub Actions 构建失败，提示登录失败

**A**: 检查以下几点：
1. GitHub Secret `ALIYUN_REGISTRY_PASSWORD` 是否正确设置
2. 阿里云密码是否正确
3. 密码中是否包含特殊字符（需要正确转义）

### Q2: 构建成功但阿里云仓库没有镜像

**A**: 检查：
1. 命名空间 `tujinkai` 是否存在
2. 镜像名称是否正确
3. 查看构建日志，确认 push 步骤是否成功

### Q3: 如何修改镜像名称？

**A**: 修改工作流文件中的 `IMAGE_NAME`，然后提交推送：
```yaml
IMAGE_NAME: your-namespace/your-image-name
```

### Q4: 阿里云容器镜像服务的费用？

**A**:
- 个人版：免费
- 企业版：有存储和流量限制
- 一般个人使用完全免费

---

## 📚 相关链接

- [阿里云容器镜像服务文档](https://help.aliyun.com/product/60716.html)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Buildx 文档](https://docs.docker.com/buildx/)

---

**配置完成后，您的镜像地址将是**：
```
registry.cn-hangzhou.aliyuncs.com/mycangku_tusuklll/mineru-ascend:latest
```
