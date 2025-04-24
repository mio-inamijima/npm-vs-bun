# bench.ps1
$ErrorActionPreference = "Stop"

Write-Host "=== スクリプト開始 ==="

$clean = {
  Write-Host "クリーンアップ開始..."
  Remove-Item -Recurse -Force node_modules, bun.lockb, package-lock.json -ErrorAction SilentlyContinue
  Write-Host "クリーンアップ完了"
}

$projects = @("remix-app", "next-app", "hono-app")

foreach ($p in $projects) {
  Write-Host "=== $p の処理開始 ==="
  Write-Host "現在のディレクトリ: $(Get-Location)"
  
  try {
    Write-Host "$p ディレクトリに移動..."
    Push-Location $p
    Write-Host "移動後のディレクトリ: $(Get-Location)"
    
    Write-Host "cold install のベンチマーク開始..."
    hyperfine --warmup 1 --runs 5 --prepare "$clean.Invoke()" `
      "npm install" "bun install" --export-json "..\$($p)_cold.json"
    Write-Host "cold install のベンチマーク完了"
    
    Write-Host "cached install のベンチマーク開始..."
    hyperfine --warmup 1 --runs 5 `
      "npm install" "bun install" --export-json "..\$($p)_cached.json"
    Write-Host "cached install のベンチマーク完了"
  }
  catch {
    Write-Host "エラーが発生しました: $_"
    Write-Host "エラーの詳細:"
    $_.Exception | Format-List -Force
  }
  finally {
    Write-Host "$p ディレクトリから戻ります..."
    Pop-Location
    Write-Host "現在のディレクトリ: $(Get-Location)"
  }
}

Write-Host "=== スクリプト終了 ==="

