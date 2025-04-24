#!/usr/bin/env bash
set -euo pipefail

PROJECTS=(remix-app next-app hono-app)
CLEAN='rm -rf node_modules bun.lockb package-lock.json'

for P in "${PROJECTS[@]}"; do
  echo "=== Running on $P ==="
  cd "$P"

  hyperfine --warmup 1 --runs 5 \
    --prepare "$CLEAN" \
    'npm install' \
    'bun install' \
    --export-json "../${P}_cold.json"

  hyperfine --warmup 1 --runs 5 \
    'npm install' \
    'bun install' \
    --export-json "../${P}_cached.json"

  cd ..
done

