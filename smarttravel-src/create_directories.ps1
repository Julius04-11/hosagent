# 智慧旅行项目 - 资源目录创建脚本
# 华为高级工程架构师
# 用途：一键创建所有需要的资源目录

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  智慧旅行 - 资源目录创建脚本" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# 设置项目根目录
$projectRoot = "e:\smarttravel"
Set-Location $projectRoot

Write-Host "📁 当前目录: $projectRoot" -ForegroundColor Green
Write-Host ""

# 定义需要创建的目录
$directories = @(
    # media 图片目录
    "entry\src\main\resources\base\media\attractions",
    "entry\src\main\resources\base\media\restaurants",
    "entry\src\main\resources\base\media\hotels",
    "entry\src\main\resources\base\media\icons",
    "entry\src\main\resources\base\media\common",
    
    # rawfile 音频和图片目录
    "entry\src\main\resources\rawfile\audio",
    "entry\src\main\resources\rawfile\audio\attractions",
    "entry\src\main\resources\rawfile\audio\ui",
    "entry\src\main\resources\rawfile\images"
)

Write-Host "🚀 开始创建目录..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$skipCount = 0

foreach ($dir in $directories) {
    $fullPath = Join-Path $projectRoot $dir
    
    if (Test-Path $fullPath) {
        Write-Host "  ⏭️  已存在: $dir" -ForegroundColor Gray
        $skipCount++
    } else {
        try {
            New-Item -ItemType Directory -Force -Path $fullPath | Out-Null
            Write-Host "  ✅ 已创建: $dir" -ForegroundColor Green
            $successCount++
        } catch {
            Write-Host "  ❌ 创建失败: $dir" -ForegroundColor Red
            Write-Host "     错误: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  创建完成!" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  ✅ 新创建: $successCount 个目录" -ForegroundColor Green
Write-Host "  ⏭️  已存在: $skipCount 个目录" -ForegroundColor Gray
Write-Host "  📊 总计: $($successCount + $skipCount) 个目录" -ForegroundColor Cyan
Write-Host ""

# 显示目录结构
Write-Host "📁 创建的目录结构:" -ForegroundColor Yellow
Write-Host ""
Write-Host "resources/base/media/" -ForegroundColor Cyan
Write-Host "  ├── attractions/     (景点图片)" -ForegroundColor White
Write-Host "  ├── restaurants/     (餐厅图片)" -ForegroundColor White
Write-Host "  ├── hotels/          (酒店图片)" -ForegroundColor White
Write-Host "  ├── icons/           (UI图标)" -ForegroundColor White
Write-Host "  └── common/          (通用图片)" -ForegroundColor White
Write-Host ""
Write-Host "resources/rawfile/" -ForegroundColor Cyan
Write-Host "  ├── audio/" -ForegroundColor White
Write-Host "  │   ├── attractions/ (景点导览音频)" -ForegroundColor White
Write-Host "  │   └── ui/          (UI提示音)" -ForegroundColor White
Write-Host "  └── images/          (rawfile图片)" -ForegroundColor White
Write-Host ""

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  下一步操作:" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  1. 访问 unsplash.com 或 pexels.com" -ForegroundColor White
Write-Host "  2. 下载所需图片资源" -ForegroundColor White
Write-Host "  3. 放置到对应目录" -ForegroundColor White
Write-Host "  4. 运行应用测试" -ForegroundColor White
Write-Host ""
Write-Host "📖 详细指南请查看: SETUP_IMAGES_GUIDE.md" -ForegroundColor Green
Write-Host ""

# 创建README文件
$readmePath = "entry\src\main\resources\base\media\README.md"
$readmeContent = @"
# Media 资源目录

本目录用于存放应用的所有图片资源。

## 📁 目录说明

- **attractions/** - 景点图片（world_window.jpg等）
- **restaurants/** - 餐厅图片（seafood_restaurant.jpg等）
- **hotels/** - 酒店图片（luxury_hotel.jpg等）
- **icons/** - UI图标（icon_home.png等）
- **common/** - 通用图片（placeholder.jpg等）

## 📝 命名规范

- 使用小写字母
- 单词用下划线分隔
- 例如：world_window.jpg, seafood_restaurant.jpg

## 📏 图片规格

- 景点/餐厅/酒店: 800x600px (JPG, 质量70-80%)
- UI图标: 48x48px, 96x96px (PNG, 透明背景)
- 通用图片: 根据用途确定

## 🔗 参考文档

详细信息请查看项目根目录下的：
- SETUP_IMAGES_GUIDE.md - 图片准备指南
- RESOURCE_STRUCTURE.md - 完整资源结构

**创建日期**: $(Get-Date -Format "yyyy-MM-dd HH:mm")
"@

try {
    $readmeContent | Out-File -FilePath (Join-Path $projectRoot $readmePath) -Encoding UTF8
    Write-Host "📄 已创建 README.md 文件" -ForegroundColor Green
} catch {
    Write-Host "⚠️  README.md 创建失败: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✨ 全部完成！祝你开发顺利！" -ForegroundColor Green
Write-Host ""
