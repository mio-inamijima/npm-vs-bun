# bench.ps1
$ErrorActionPreference = "Stop"

Write-Host "=== Script Start ==="

$clean = {
    Write-Host "Starting cleanup..."
    Remove-Item -Recurse -Force node_modules, bun.lockb, package-lock.json -ErrorAction SilentlyContinue
    Write-Host "Cleanup completed"
}

$projects = @("remix-app", "next-app", "hono-app")

foreach ($p in $projects) {
    Write-Host "=== Processing $p ==="
    Write-Host "Current directory: $(Get-Location)"
    
    try {
        Write-Host "Moving to $p directory..."
        Push-Location $p
        Write-Host "Directory after move: $(Get-Location)"
        
        Write-Host "Starting cold install benchmark..."
        hyperfine --warmup 1 --runs 5 --prepare "$($clean.Invoke())" `
            "npm install" "bun install" --export-json "..\$($p)_cold.json"
        Write-Host "Cold install benchmark completed"
        
        Write-Host "Starting cached install benchmark..."
        hyperfine --warmup 1 --runs 5 `
            "npm install" "bun install" --export-json "..\$($p)_cached.json"
        Write-Host "Cached install benchmark completed"
    }
    catch {
        Write-Host "Error occurred: $_"
        Write-Host "Error details:"
        $_.Exception | Format-List -Force
    }
    finally {
        Write-Host "Returning from $p directory..."
        Pop-Location
        Write-Host "Current directory: $(Get-Location)"
    }
}

Write-Host "=== Script End ==="

