# Design: Phase 2 release checklist

## 1. ファイル構造

`release-checklist.md` を 1 ファイル / 1 ページに収める。Phase 1
checklist (steering 029) と同じ大枠で、3 パッケージを並列で扱う。

```
.steering/20260509-046-phase2-release-checklist/
├── requirements.md
├── design.md
├── tasklist.md
└── release-checklist.md   ← 本 steering の主要成果物
```

## 2. `release-checklist.md` の構成

### §0. 前提条件

- Phase 1 (`v0.1.0`) が npm 上に publish 済みである
  (`npm view @rescript-tauri/core` で確認)
- `NPM_TOKEN` リポジトリシークレットが設定済み
- リポジトリが public

### §1. リリース前確認 (前日まで)

3 パッケージそれぞれについて:

- 公開 API が `.resi` で確定している
- 互換マトリクスが README に記載 (steering 043)
- CHANGELOG が `## Unreleased` で当該機能を記述済 (steering 044)
- 対応する examples が CI 緑 (steering 036/037/039 + 041)
- 専用 CI (`tests-<pkg>-types.yml` / `tests-<pkg>-runtime.yml`) が
  CI 緑 (steering 041)

PRD §10 残課題のうち Phase 2 で確定する項目:

- #5 (Mocks packaging) — 確定済 (steering 045)

### §2. パッケージごとの "Cut" コミット

各パッケージで 1 コミット:

```bash
# schema
sed -i '' 's/"version": "0.0.0"/"version": "0.1.0"/' packages/schema/package.json
sed -i '' 's/^## Unreleased$/## 0.1.0 (2026-MM-DD)/' packages/schema/CHANGELOG.md
git add packages/schema/{package.json,CHANGELOG.md}
git commit -m "📝 Cut @rescript-tauri/schema v0.1.0"
```

(plugin-fs / plugin-dialog も同形式)

`sphinx-docs/user/changelog.md` の各セクション
`## @rescript-tauri/<pkg> (Unreleased)` も
`## @rescript-tauri/<pkg> 0.1.0 (2026-MM-DD)` に変える単発コミット
を最後に追加。

> 補足: macOS の `sed` は `-i ''` が必要。Linux は `-i` 単独で OK。
> runbook には両方注記する。または `python -c` でも代用可能と
> 補助記載する。

### §3. タグ作成と push

3 パッケージそれぞれ:

```bash
git tag -a schema-v0.1.0 -m "schema-v0.1.0 — Phase 2 schema package"
git push origin schema-v0.1.0

git tag -a plugin-fs-v0.1.0 -m "plugin-fs-v0.1.0 — Phase 2 plugin-fs package"
git push origin plugin-fs-v0.1.0

git tag -a plugin-dialog-v0.1.0 -m "plugin-dialog-v0.1.0 — Phase 2 plugin-dialog package"
git push origin plugin-dialog-v0.1.0
```

3 タグを連続 push しても、`release.yml` がそれぞれ独立に走る。

### §4. dry-run (希望者向け)

GitHub UI / `gh workflow run` で release.yml を `workflow_dispatch`
+ `dry_run=true` でリハーサル可能 (default core にフォールバック)。
ただし dry_run はパッケージ判定が core 固定のため、Phase 2
パッケージのリハーサル目的では tag を一度切って消す方法を推奨。

### §5. リリース後検証

各パッケージ:

```bash
npm view @rescript-tauri/schema version       # → 0.1.0
npm view @rescript-tauri/plugin-fs version    # → 0.1.0
npm view @rescript-tauri/plugin-dialog version # → 0.1.0
```

- GitHub Releases ページに 3 つの release が出来ていること
- sphinx-docs サイトの changelog 表記が更新済
- 互換マトリクスの peer dep 表記が `npm view <pkg> peerDependencies`
  と一致

### §6. スモーク試験

```bash
mkdir /tmp/rt-smoke-phase2 && cd /tmp/rt-smoke-phase2
pnpm init -y
pnpm add @rescript-tauri/core @rescript-tauri/schema rescript-schema \
         @tauri-apps/api rescript @rescript/core
pnpm exec rescript -version  # >= 12.0.0
# 別ディレクトリで plugin-fs / plugin-dialog も同様に試す
```

### §7. 告知 (オプション)

Phase 1 と同じテンプレート (ReScript Forum / Tauri Discord /
SNS)。Phase 2 では "schema 統合 + 公式プラグインバインディング 2
種が揃った" を主軸にする。

### §8. Phase 3 起点準備

- Phase 2 の steering 030〜046 のうち 30 日経過分を `archive/` へ
- Phase 3 planning steering を作成 (Should スコープ
  `plugin-opener` / `plugin-process`、Could スコープ
  `plugin-updater` / `plugin-shell` / `plugin-store`、Mocks 拡張)

### 連絡先

メンテナ / リポジトリ URL を末尾に記載。

## 3. チェックリスト形式

すべてのアクションを markdown checklist (`- [ ]`) にして trackable
に。Phase 1 checklist と同じスタイル。コードブロックの前後にも
チェックボックスを置き、「コマンド実行 → 確認」の二段で進む。

## 4. 検証手順

1. `release-checklist.md` を text-check (タブ・heading・bash
   ブロックの体裁)
2. 内部リンク (Phase 1 checklist への参照、各 steering 参照) が
   既存ファイルに解決
3. tag コマンドの prefix が release.yml の case 文と一致
   (`schema-v*` / `plugin-fs-v*` / `plugin-dialog-v*`)
4. `pnpm --recursive build` / `pnpm --recursive test` で regression
   なし

## 5. リスクと対応

| リスク | 対応 |
|---|---|
| Phase 1 未 publish のまま Phase 2 を進める | §0 で前提を明示し、`npm view @rescript-tauri/core` で先行確認するチェック項目を入れる |
| sed の OS 差 (BSD vs GNU) | macOS / Linux 両方の syntax を併記 |
| バージョン番号の typo | チェックリスト末尾に "互換マトリクスとの一致" 検証項目 |
| メンテナが連続 tag push 中に CI 緑が間に合わない | 各 tag を 5 分間隔で push する補足を含める (release.yml が並列実行になる際の race を避ける) |
