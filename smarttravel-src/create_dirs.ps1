# Smart Travel - Create Directories Script
# Create all required resource directories

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Smart Travel - Create Directories" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Set project root
$projectRoot = "e:\smarttravel"
Set-Location $projectRoot

Write-Host "Current directory: $projectRoot" -ForegroundColor Green
Write-Host ""

# Define directories to create
$directories = @(
    "entry\src\main\resources\base\media\attractions",
    "entry\src\main\resources\base\media\restaurants",
    "entry\src\main\resources\base\media\hotels",
    "entry\src\main\resources\base\media\icons",
    "entry\src\main\resources\base\media\common",
    "entry\src\main\resources\rawfile\audio",
    "entry\src\main\resources\rawfile\audio\attractions",
    "entry\src\main\resources\rawfile\audio\ui",
    "entry\src\main\resources\rawfile\images"
)

Write-Host "Creating directories..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$skipCount = 0

foreach ($dir in $directories) {
    $fullPath = Join-Path $projectRoot $dir
    
    if (Test-Path $fullPath) {
        Write-Host "  [SKIP] Already exists: $dir" -ForegroundColor Gray
        $skipCount++
    } else {
        try {
            New-Item -ItemType Directory -Force -Path $fullPath | Out-Null
            Write-Host "  [OK] Created: $dir" -ForegroundColor Green
            $successCount++
        } catch {
            Write-Host "  [ERROR] Failed: $dir" -ForegroundColor Red
            Write-Host "     Error: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Complete!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Created: $successCount directories" -ForegroundColor Green
Write-Host "  Already exists: $skipCount directories" -ForegroundColor Gray
Write-Host "  Total: $($successCount + $skipCount) directories" -ForegroundColor Cyan
Write-Host ""

Write-Host "Directory structure:" -ForegroundColor Yellow
Write-Host ""
Write-Host "resources/base/media/" -ForegroundColor Cyan
Write-Host "  - attractions/" -ForegroundColor White
Write-Host "  - restaurants/" -ForegroundColor White
Write-Host "  - hotels/" -ForegroundColor White
Write-Host "  - icons/" -ForegroundColor White
Write-Host "  - common/" -ForegroundColor White
Write-Host ""
Write-Host "resources/rawfile/" -ForegroundColor Cyan
Write-Host "  - audio/attractions/" -ForegroundColor White
Write-Host "  - audio/ui/" -ForegroundColor White
Write-Host "  - images/" -ForegroundColor White
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Visit unsplash.com or pexels.com" -ForegroundColor White
Write-Host "  2. Download required images" -ForegroundColor White
Write-Host "  3. Place them in corresponding directories" -ForegroundColor White
Write-Host ""
Write-Host "See download_images_guide.md for details" -ForegroundColor Green
Write-Host ""
Write-Host "Done!" -ForegroundColor Green
