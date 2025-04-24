# npm vs bun ― install 速度ベンチマーク

Remix / Next.js / Hono のスターター 3 プロジェクトで  
**`npm install` と `bun install`** の速度を Hyperfine で測るだけのリポジトリです。  
結果は `aggregate.py` でその場で Markdown 表にまとめて CLI に表示できます。

---

## 前提：絶対に必要なのは 4 つだけ

| ツール | 目的 | インストール例 |
|--------|------|----------------|
| **Git** | ソース取得 | mac:`brew install git`<br>Win:`winget install Git.Git`<br>Linux:`sudo apt install git` |
| **Node.js (npm)** | 比較対象 & スターター依存 | mac:`brew install node`<br>Win:`winget install OpenJS.NodeJS.LTS`<br>Linux:`curl -fsSL https://deb.nodesource.com/setup_20.x \| sudo -E bash - && sudo apt install -y nodejs` |
| **Bun** | 高速パッケージマネージャ | mac/Linux:`curl -fsSL https://bun.sh/install \| bash`<br>Win (PowerShell):<br>`irm bun.sh/install.ps1 \| iex` |
| **Hyperfine** | ベンチ計測 & JSON 出力 | mac:`brew install hyperfine`<br>Win:`scoop install hyperfine`<br>Linux:`sudo apt install hyperfine` |
| **Python 3** | `aggregate.py` を回す | mac:`brew install python`<br>Win:`winget install Python.Python.3`<br>Linux: ほぼ標準で入っている |

> *Bash* は mac/Linux 標準、Windows は PowerShell スクリプトを同梱しています。  
> Raspberry Pi など ARM64 Linux も同じ手順で OK（**64-bit OS 必須**）。

---

## 0. リポジトリを取得

```bash
git clone https://github.com/mio-inamijima/npm-vs-bun.git
cd npm-vs-bun
```

## 1. macOS (zsh/Bash)

```bash
chmod +x bench.sh
./bench.sh |& tee mac_bench.log          # JSON とログが作成される
python3 aggregate.py                     # 結果を Markdown テーブルで表示
```

## 2. Windows 11 (PowerShell 7+)

```powershell
# スクリプト実行がブロックされた場合は実行ポリシーを緩める
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

.\bench.ps1 | Tee-Object -FilePath win_bench.log
python aggregate.py
```

## 3. Ubuntu / Debian / Raspberry Pi OS (64-bit)

```bash
bash bench.sh |& tee linux_bench.log
python3 aggregate.py
```

## 4. aggregate.py の出力例

```
| Machine | Project   | npm cold | bun cold | Speed-up | npm cached | bun cached | Speed-up |
|---------|-----------|---------:|---------:|---------:|-----------:|-----------:|---------:|
| local   | remix-app |  9.72s   |  1.68s   | ×5.8     |   0.970s   |   0.032s   | ×29.9    |
| local   | next-app  |  8.65s   |  2.08s   | ×4.2     |   0.702s   |   0.014s   | ×50.7    |
| local   | hono-app  |  7.42s   |  1.86s   | ×4.0     |   0.599s   |   0.016s   | ×38.0    |
```

## 5. よくあるエラー

| 症状 | 原因 / 対処 |
|------|------------|
| bun: command not found | exec $SHELL -l でパス再読み込み or インストールし直し |
| hyperfine: command not found | パッケージマネージャのコマンドを再確認（brew / scoop / apt） |
| Raspberry Pi で exec format error | 32-bit OS。64-bit (aarch64) に変更 |
| PowerShell でスクリプトが実行不可 | Set-ExecutionPolicy -Scope CurrentUser RemoteSigned |

結果ファイル (*.json, *.log) は .gitignore 済み なので、
必要であれば results/<machine> などに移動して PR してください。

グラフ化したい場合のみ pip install matplotlib して aggregate.py に手を入れれば OK。




