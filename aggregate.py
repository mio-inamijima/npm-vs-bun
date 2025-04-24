#!/usr/bin/env python3
"""
Collects *_cold.json / *_cached.json across results/* and
prints a Markdown table with mean times and speed-up ratios.
"""
import json, pathlib, statistics as st, re

rows = []
for f in pathlib.Path(".").rglob("*_cold.json"):
    machine = f.parts[1] if f.parts[0] == "results" else "local"
    project = re.sub(r"_cold\.json$", "", f.name)
    cold = json.load(f.open())["results"]
    cached = json.load(f.with_name(f"{project}_cached.json").open())["results"]
    npm_cold = cold[0]["mean"]; bun_cold = cold[1]["mean"]
    npm_cached = cached[0]["mean"]; bun_cached = cached[1]["mean"]
    rows.append((machine, project, npm_cold, bun_cold, npm_cached, bun_cached))

# sort and print
rows.sort()
print("| Machine | Project | npm cold | bun cold | Speed-up | npm cached | bun cached | Speed-up |")
print("|---------|---------|---------:|---------:|---------:|-----------:|-----------:|---------:|")
for m,p,nc,bc,nh,bh in rows:
    print(f"| {m} | {p} | {nc:.2f}s | {bc:.2f}s | ×{nc/bc:.1f} | {nh:.3f}s | {bh:.3f}s | ×{nh/bh:.1f} |")

