# Generate Placeholder Images Script

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Generate Placeholder Images" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "e:\smarttravel"
Set-Location $projectRoot

# Define images to create
$images = @{
    "attractions" = @(
        @{name="world_window.jpg"; text="World+Window"; size="800x600"},
        @{name="happy_valley.jpg"; text="Happy+Valley"; size="800x600"},
        @{name="splendid_china.jpg"; text="Splendid+China"; size="800x600"},
        @{name="dameisha_beach.jpg"; text="Beach"; size="800x600"},
        @{name="lianhua_mountain.jpg"; text="Mountain"; size="800x600"}
    )
    "restaurants" = @(
        @{name="seafood_restaurant.jpg"; text="Seafood"; size="800x600"},
        @{name="hotpot_restaurant.jpg"; text="Hotpot"; size="800x600"},
        @{name="cantonese_restaurant.jpg"; text="Restaurant"; size="800x600"},
        @{name="western_restaurant.jpg"; text="Dining"; size="800x600"}
    )
    "hotels" = @(
        @{name="luxury_hotel.jpg"; text="Luxury+Hotel"; size="800x600"},
        @{name="boutique_hotel.jpg"; text="Boutique"; size="800x600"},
        @{name="business_hotel.jpg"; text="Business"; size="800x600"},
        @{name="resort_hotel.jpg"; text="Resort"; size="800x600"}
    )
    "common" = @(
        @{name="placeholder.jpg"; text="Image"; size="400x300"},
        @{name="default_avatar.png"; text="Avatar"; size="200x200"}
    )
}

$totalCount = 0
$successCount = 0

Write-Host "Downloading placeholder images..." -ForegroundColor Yellow
Write-Host ""

foreach ($category in $images.Keys) {
    $targetDir = "entry\src\main\resources\base\media\$category"
    
    Write-Host "[$category]" -ForegroundColor Cyan
    
    foreach ($img in $images[$category]) {
        $totalCount++
        $filePath = Join-Path $targetDir $img.name
        $url = "https://placehold.co/$($img.size)/png?text=$($img.text)"
        
        try {
            Write-Host "  Downloading: $($img.name)..." -NoNewline
            Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop
            Write-Host " [OK]" -ForegroundColor Green
            $successCount++
        } catch {
            Write-Host " [FAILED]" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Complete!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Success: $successCount/$totalCount images" -ForegroundColor Green
Write-Host ""
Write-Host "Note: These are temporary placeholders" -ForegroundColor Yellow
Write-Host "Replace with real images from unsplash.com later" -ForegroundColor Yellow
Write-Host ""
