# 万宁行程网页一键部署脚本
# 使用方法: 在 PowerShell 中运行: .\deploy.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubToken
)

Write-Host "🚀 开始部署万宁行程网页到 GitHub Pages..." -ForegroundColor Green

# 1. 创建 GitHub 仓库
Write-Host "📦 步骤1: 创建 GitHub 仓库..." -ForegroundColor Cyan
$headers = @{
    "Authorization" = "token $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
}
$body = @{
    name = "wanning-trip"
    description = "🌴 万宁之旅 - 移动端行程规划"
    private = $false
    auto_init = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method POST -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "✅ 仓库创建成功: $($response.html_url)" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*422*") {
        Write-Host "⚠️ 仓库已存在，继续推送代码..." -ForegroundColor Yellow
    } else {
        Write-Host "❌ 创建仓库失败: $_" -ForegroundColor Red
        exit 1
    }
}

# 2. 配置 Git 远程仓库
Write-Host "📡 步骤2: 配置远程仓库..." -ForegroundColor Cyan
git remote remove origin 2>$null
git remote add origin "https://$GitHubToken@github.com/m1234532/wanning-trip.git"

# 3. 推送到 GitHub
Write-Host "⬆️ 步骤3: 推送代码到 GitHub..." -ForegroundColor Cyan
git branch -M main
git push -u origin main --force

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 代码推送成功!" -ForegroundColor Green
} else {
    Write-Host "❌ 推送失败，请检查网络连接" -ForegroundColor Red
    exit 1
}

# 4. 启用 GitHub Pages
Write-Host "🌐 步骤4: 启用 GitHub Pages..." -ForegroundColor Cyan
$pagesBody = @{
    source = @{
        branch = "main"
        path = "/"
    }
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://api.github.com/repos/m1234532/wanning-trip/pages" -Method POST -Headers $headers -Body $pagesBody -ContentType "application/json" 2>$null
    Write-Host "✅ GitHub Pages 已启用!" -ForegroundColor Green
} catch {
    Write-Host "⚠️ GitHub Pages 可能已启用或需要手动开启" -ForegroundColor Yellow
}

# 5. 完成
Write-Host ""
Write-Host "🎉 部署完成!" -ForegroundColor Green
Write-Host "📱 网站地址: https://m1234532.github.io/wanning-trip/" -ForegroundColor Cyan
Write-Host "⏱️ 等待1-2分钟后即可访问" -ForegroundColor Gray
Write-Host ""
Write-Host "GitHub 仓库: https://github.com/m1234532/wanning-trip" -ForegroundColor Gray

# 清理凭证
git remote remove origin
git remote add origin "https://github.com/m1234532/wanning-trip.git"
