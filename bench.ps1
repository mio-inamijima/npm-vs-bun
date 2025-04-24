# PowerShell equivalent of bench.sh
$ErrorActionPreference = "Stop"

$PROJECTS = @("remix-app", "next-app", "hono-app")
$CLEAN = "Remove-Item -Recurse -Force -ErrorAction SilentlyContinue node_modules, bun.lockb, package-lock.json"

foreach ($P in $PROJECTS) {
    Write-Host "=== Running on $P ==="
    Set-Location -Path $P

    # Cold cache benchmark
    Invoke-Expression $CLEAN
    Write-Host "Running cold cache benchmark..."
    # Note: hyperfine equivalent would need to be implemented separately in PowerShell
    # For now, we'll just time the commands manually
    $npmColdTime = Measure-Command { npm install }
    Invoke-Expression $CLEAN
    $bunColdTime = Measure-Command { bun install }
    
    # Convert to seconds and output
    Write-Host "npm install (cold): $($npmColdTime.TotalSeconds) seconds"
    Write-Host "bun install (cold): $($bunColdTime.TotalSeconds) seconds"
    
    # Cached benchmark
    Write-Host "Running cached benchmark..."
    $npmCachedTime = Measure-Command { npm install }
    $bunCachedTime = Measure-Command { bun install }
    
    # Convert to seconds and output
    Write-Host "npm install (cached): $($npmCachedTime.TotalSeconds) seconds"
    Write-Host "bun install (cached): $($bunCachedTime.TotalSeconds) seconds"
    
    # Export results to JSON (simplified)
    $coldResults = @{
        "npm" = $npmColdTime.TotalSeconds
        "bun" = $bunColdTime.TotalSeconds
    } | ConvertTo-Json
    $cachedResults = @{
        "npm" = $npmCachedTime.TotalSeconds
        "bun" = $bunCachedTime.TotalSeconds
    } | ConvertTo-Json
    
    Set-Content -Path "../${P}_cold.json" -Value $coldResults
    Set-Content -Path "../${P}_cached.json" -Value $cachedResults

    Set-Location -Path ".."
}
