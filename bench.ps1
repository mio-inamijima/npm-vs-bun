# bench.ps1
$ErrorActionPreference = "Stop"

$clean = {
  Remove-Item -Recurse -Force node_modules, bun.lockb, package-lock.json -ErrorAction SilentlyContinue
}

$projects = @("remix-app", "next-app", "hono-app")

foreach ($p in $projects) {
  Write-Host "=== Running on $p ==="
  Push-Location $p
  hyperfine --warmup 1 --runs 5 --prepare "$clean.Invoke()" `
    "npm install" "bun install" --export-json "..\$($p)_cold.json"
  hyperfine --warmup 1 --runs 5 `
    "npm install" "bun install" --export-json "..\$($p)_cached.json"
  Pop-Location
}

