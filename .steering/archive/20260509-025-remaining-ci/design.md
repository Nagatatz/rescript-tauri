# Design: 残り CI workflows

## ファイル構成

3 つの新規 workflow をリポジトリ規約 (action SHA pinning, README 文書化) に従って追加:

```
.github/workflows/
├── compat-tauri-latest.yml          # 新規: nightly @tauri-apps/api latest 取込み
├── compat-rescript-prerelease.yml   # 新規: nightly rescript@next/@beta 取込み
├── release.yml                       # 新規: tag push で npm publish + GH Release
└── README.md                         # 更新: Active テーブルに 3 行追加、Planned セクション削除
```

## 主要設計判断

### compat-tauri-latest.yml

- 単一 Linux ジョブ（compat 検出が目的、3 OS は不要）
- `pnpm add @tauri-apps/api@latest` を root + 各パッケージで実行 (pnpm workspaces の peer/dev 解決が古いリンクを引き続き使うのを防ぐため)
- core の build / tests / hello-world の build を順に実行
- 失敗時 issue は自動で立てない（Phase 2 へ）

### compat-rescript-prerelease.yml

- matrix で `next` / `beta` の dist-tag を両方試す
- pre-flight `npm view rescript@<tag> version` で dist-tag が published かを確認、無ければ `::warning::` 出して skip
- skip 時はジョブ自体は green のまま終わる (`if: steps.resolve.outputs.skip != 'true'`)
- 取込み手順は compat-tauri と同じ（root + 各パッケージで `pnpm add`）

### release.yml

- トリガ: tag push (`v*`) と manual dispatch (`dry_run` 入力)
- `id-token: write` permission を付与し `npm publish --provenance` を有効化
- secret `NPM_TOKEN` が無いとき:
  - publish step を skip
  - `::warning::` で開発者に通知
- manual dispatch + `dry_run=true` のときも publish skip（CI のリハーサル目的）
- GitHub Release 作成は tag push の場合のみ (`startsWith(github.ref, 'refs/tags/v')`)
- `gh release create --generate-notes` は GitHub の自動 changelog 機能 (`Generate release notes`) を呼び出すため、別途 changelog 自動生成 ツールは不要

## Action SHA pinning

steering 028（並行セッション）で全 action は SHA pinning 済み。本 steering の workflow も同一のピン (`actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1` 等) を使用。

## README 更新

「Active workflows」テーブルに 3 行追加、「Planned for Phase 1」セクション削除。各行は **トリガと目的を 1 文で説明**する規約に従う。

## actionlint

3 ファイルとも actionlint で lint 緑（CI 上の syntax / type / shell エラーがない）ことをローカル確認済。

## CI 影響

新規 workflow は scheduled / tag triggered なので、PR フローの latency に影響しない。
