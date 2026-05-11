# Steering 20260511-005 — Tasklist

## Phase 1: 計画

- [x] 採番衝突確認 (`ls .steering/ | grep 20260511-` / `git branch --list 'worktree-*'`)
- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [x] ユーザー承認 → EnterWorktree plugin-clipboard-manager-userguide

## Phase 2: 実装（4 独立 checkpoint、各 checkpoint で 1 コミット）

### Checkpoint 1: スケルトン + Image.t 連携の前書き + Installation

- [x] `sphinx-docs/user/plugin-clipboard-manager.md` 新規作成
  - frontmatter / H1 / Tauri 上流リンクの冒頭
  - `{note}` Phase 2 公開待ち
  - `{tip}` `Core.Image` 連携の説明（external link to `packages/core/src/Image.resi`）
  - `## Install` 節 (pnpm add + rescript.json + Rust 側 Cargo.toml + builder)
- [x] `pnpm run check` pass
- [x] コミット: `📝 Add sphinx-docs plugin-clipboard-manager skeleton + install section`

### Checkpoint 2: Text APIs (writeText / readText / writeTextOptions)

- [ ] `## Capabilities` 節 (clipboard-manager:default)
- [ ] `## Minimal example` 節 (README の Quick example 流用)
- [ ] `## Public API` 表（6 関数 + 1 record）
- [ ] `### Text APIs` サブ節（writeText / readText / writeTextOptions.label）
- [ ] `pnpm run check` pass
- [ ] コミット: `📝 Document plugin-clipboard-manager text APIs`

### Checkpoint 3: Image APIs (writeImage polymorphic / readImage / Image.t 連携)

- [ ] `### Image APIs` サブ節
  - 冒頭で再度 `Core.Image` 再利用を明示
  - `Image.t` を渡すケース（`Core.Image.fromPath`）
  - `Uint8Array` RGBA bytes を渡すケース
  - `readImage` + `Image.rgba` の例
- [ ] `### Pitfalls — Image RGBA layout` 節（row-major top-to-bottom 注意）
- [ ] `pnpm run check` pass
- [ ] コミット: `📝 Document plugin-clipboard-manager image APIs with Core.Image reuse`

### Checkpoint 4: HTML + Clear + index/installation 整合 + 旁証

- [ ] `### HTML APIs` サブ節（`writeHtml(html, ~altText?, ())` シグネチャ説明 + リッチテキスト use case）
- [ ] `### Clear` サブ節（Android < SDK 28 fallback 注意）
- [ ] `## Compatibility` 表
- [ ] `## See also` 節（README / 上流 docs / Image.resi）
- [ ] `sphinx-docs/user/index.md` の Phase 2 表に plugin-clipboard-manager 行追加 + toctree に挿入
- [ ] `sphinx-docs/user/installation.md` の note 句から plugin-clipboard-manager を除外し、ガイド完成リンク列へ移動
- [ ] cross-ref 検証:
  - `installation.md` から `user/plugin-clipboard-manager` への解決
  - `Core.Image` への external link が GitHub 上で 404 にならない事を URL 形式（`/blob/main/...`）で担保
- [ ] `pnpm run check` pass
- [ ] コミット: `📝 Add plugin-clipboard-manager HTML/clear APIs + index/installation cross-refs`

## Phase 3: マージ前

- [ ] tasklist.md の全タスクを `[x]` に更新
- [ ] 最終コミット (tasklist 更新): `✅ Mark steering 20260511-005 tasklist complete`

## Phase 4: マージ・クリーンアップ

- [ ] AskUserQuestion で main へのマージ可否を確認
- [ ] CWD を main repo へ移動
- [ ] `git merge worktree-plugin-clipboard-manager-userguide --no-ff`
- [ ] worktree 削除 / ブランチ削除 / 検証
