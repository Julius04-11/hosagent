# Fix Media Directory Structure
# HarmonyOS media directory does not support subdirectories

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Fix Media Directory Structure" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$mediaRoot = "entry\src\main\resources\base\media"
Set-Location "e:\smarttravel"

Write-Host "Moving all images to media root..." -ForegroundColor Yellow
Write-Host ""

# Move files from subdirectories
$subdirs = @("attractions", "restaurants", "hotels", "common", "icons")

foreach ($subdir in $subdirs) {
    $sourcePath = Join-Path $mediaRoot $subdir
    
    if (Test-Path $sourcePath) {
        $files = Get-ChildItem $sourcePath -File
        
        if ($files.Count -gt 0) {
            Write-Host "Moving files from $subdir/:" -ForegroundColor Cyan
            
            foreach ($file in $files) {
                $destPath = Join-Path $mediaRoot $file.Name
                
                try {
                    Move-Item -Path $file.FullName -Destination $destPath -Force
                    Write-Host "  [OK] $($file.Name)" -ForegroundColor Green
                } catch {
                    Write-Host "  [ERROR] $($file.Name): $_" -ForegroundColor Red
                }
            }
            
            Write-Host ""
        }
        
        # Remove empty directory
        try {
            Remove-Item $sourcePath -Recurse -Force
            Write-Host "Removed directory: $subdir/" -ForegroundColor Gray
        } catch {
            Write-Host "Warning: Could not remove $subdir/: $_" -ForegroundColor Yellow
        }
        
        Write-Host ""
    }
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Complete!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Show final structure
Write-Host "Final media directory contents:" -ForegroundColor Yellow
Get-ChildItem $mediaRoot -File | Format-Table Name, Length -AutoSize

Write-Host ""
Write-Host "All images are now in media/ root directory" -ForegroundColor Green
Write-Host "HarmonyOS resource structure is now correct" -ForegroundColor Green
Write-Host ""
