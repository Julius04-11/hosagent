# 创建占位图片脚本
# 使用placeholder.co API生成占位图

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  创建占位图片" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "e:\smarttravel"
Set-Location $projectRoot

# 定义要创建的图片
$images = @{
    "attractions" = @(
        @{name="world_window.jpg"; text="世界之窗"; size="800x600"},
        @{name="happy_valley.jpg"; text="欢乐谷"; size="800x600"},
        @{name="splendid_china.jpg"; text="锦绣中华"; size="800x600"},
        @{name="dameisha_beach.jpg"; text="大梅沙"; size="800x600"},
        @{name="lianhua_mountain.jpg"; text="莲花山"; size="800x600"}
    )
    "restaurants" = @(
        @{name="seafood_restaurant.jpg"; text="海鲜餐厅"; size="800x600"},
        @{name="hotpot_restaurant.jpg"; text="火锅餐厅"; size="800x600"},
        @{name="cantonese_restaurant.jpg"; text="粤菜餐厅"; size="800x600"},
        @{name="western_restaurant.jpg"; text="西餐厅"; size="800x600"}
    )
    "hotels" = @(
        @{name="luxury_hotel.jpg"; text="豪华酒店"; size="800x600"},
        @{name="boutique_hotel.jpg"; text="精品酒店"; size="800x600"},
        @{name="business_hotel.jpg"; text="商务酒店"; size="800x600"},
        @{name="resort_hotel.jpg"; text="度假酒店"; size="800x600"}
    )
    "common" = @(
        @{name="placeholder.jpg"; text="占位图"; size="400x300"},
        @{name="default_avatar.png"; text="头像"; size="200x200"}
    )
}

$totalCount = 0
$successCount = 0

Write-Host "开始下载占位图片..." -ForegroundColor Yellow
Write-Host ""

foreach ($category in $images.Keys) {
    $targetDir = "entry\src\main\resources\base\media\$category"
    
    Write-Host "[$category]" -ForegroundColor Cyan
    
    foreach ($img in $images[$category]) {
        $totalCount++
        $filePath = Join-Path $targetDir $img.name
        $url = "https://placehold.co/$($img.size)/png?text=$([System.Web.HttpUtility]::UrlEncode($img.text))"
        
        try {
            Write-Host "  下载: $($img.name)..." -NoNewline
            Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop
            Write-Host " [成功]" -ForegroundColor Green
            $successCount++
        } catch {
            Write-Host " [失败]" -ForegroundColor Red
            Write-Host "    错误: $_" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  完成!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  成功: $successCount/$totalCount 张图片" -ForegroundColor Green
Write-Host ""
Write-Host "注意: 这些是临时占位图" -ForegroundColor Yellow
Write-Host "建议后续从 unsplash.com 下载真实图片替换" -ForegroundColor Yellow
Write-Host ""
