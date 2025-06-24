# Hexo 自动化部署静态博客

本项目演示如何使用 Hexo 生成静态博客，并通过一键脚本自动推送到 GitHub Pages。

## 快速开始

1. 安装依赖：
   - Node.js
   - Git
2. 初始化 Hexo（首次使用时）：
   ```powershell
   npm install -g hexo-cli
   hexo init .
   npm install
   npm install hexo-deployer-git --save
   ```
3. 配置 `_config.yml` 中的 deploy 部分：
   ```yaml
   deploy:
     type: git
     repo: https://github.com/你的用户名/你的仓库名.git
     branch: gh-pages
   ```
4. 使用 `publish.ps1` 一键发布：
   ```powershell
   ./publish.ps1
   ```

## publish.ps1 脚本说明
- 自动生成静态文件并推送到 GitHub Pages。
- 需提前配置好 deploy 信息和 Git 账户。

---
如需自定义或遇到问题，请参考 Hexo 官方文档。
