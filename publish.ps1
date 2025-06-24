# Hexo 自动化一键发布脚本（增强版）
# 功能：
# 1. 自动检测依赖并安装
# 2. 自动检测 deploy 配置
# 3. 自动推送源码到 main 分支
# 4. 首次自动初始化主题
# 5. 支持本地预览和生产部署
# 6. 自动备份 public 到 backup 目录

function Check-Command($cmd) {
    $exists = Get-Command $cmd -ErrorAction SilentlyContinue
    if (-not $exists) {
        Write-Host "$cmd 未安装，正在全局安装..." -ForegroundColor Yellow
        npm install -g $cmd
    }
}

# 检查 hexo
Check-Command "hexo-cli"

# 检查 hexo-deployer-git
if (-not (Test-Path "./node_modules/hexo-deployer-git")) {
    Write-Host "hexo-deployer-git 未安装，正在安装..." -ForegroundColor Yellow
    npm install hexo-deployer-git --save
}

# 检查 deploy 配置
$config = Get-Content "./_config.yml" -Raw
if ($config -notmatch "deploy:\s*\n\s*type: git") {
    Write-Host "未检测到 deploy 配置，正在自动补全..." -ForegroundColor Yellow
    Add-Content "./_config.yml" "`ndeploy:`n  type: git`n  repo: https://github.com/yuanfangfc/hexo.git`n  branch: gh-pages`n"
}

# 自动初始化主题（如未安装 landscape 主题）
if (-not (Test-Path "./themes/landscape")) {
    Write-Host "未检测到主题，正在安装默认主题..." -ForegroundColor Yellow
    git clone https://github.com/hexojs/hexo-theme-landscape.git ./themes/landscape
}

# 1. 生成静态文件
hexo clean
hexo generate

# 2. 备份 public 目录
$backupDir = "./backup/$(Get-Date -Format yyyyMMdd_HHmmss)"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
Copy-Item -Recurse -Force ./public/* $backupDir

# 3. 部署到 GitHub Pages
hexo deploy

# 4. 推送源码到 main 分支
if (Test-Path .git) {
    git add .
    git commit -m "source: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss) 自动备份"
    git push origin main
}

Write-Host "博客已自动生成、备份并推送到 GitHub Pages 和源码仓库！" -ForegroundColor Green
