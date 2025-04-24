# PowerShell equivalent of bench.sh
$ErrorActionPreference = "Stop"

$PROJECTS = @("remix-app", "next-app", "hono-app")
$CLEAN = { Remove-Item -Recurse -Force -ErrorAction SilentlyContinue node_modules, bun.lockb, package-lock.json }

foreach ($P in $PROJECTS) {
    Write-Host "=== Running on $P ==="
    Push-Location -Path $P

    # Cold cache benchmark
    Write-Host "Running cold cache benchmark..."
    & $CLEAN
    hyperfine --warmup 1 --runs 5 "npm install" "bun install" --export-json "../${P}_cold.json"

    # Cached benchmark
    Write-Host "Running cached benchmark..."
    hyperfine --warmup 1 --runs 5 "npm install" "bun install" --export-json "../${P}_cached.json"

    Pop-Location
}
