# タスクリスト: Biome から oxlint / oxfmt への移行

| 項目 | 内容 |
|---|---|
| 採番 | 20260713-001 |
| 作成日 | 2026-07-13 |
| 関連 | requirements.md / design.md |

## テスト方針（省略理由の明記）

本作業は lint/format 外部ツールの差し替えのため専用ユニットテストは追加しない（`testing.md` の「外部サービス結合が必須で単体テストが困難」に準拠）。代わりに `pnpm run check` pass / `git diff --exit-code` clean / `oxfmt --list-different` の対象検証 / build + test 不変 / CI green で振る舞いを担保する（design.md §5）。

## タスク

### T1 + T2: 依存差し替え + 設定 + scripts（commit `🔧 Replace Biome with oxlint + oxfmt`）
- [x] `@biomejs/biome` を削除し `oxlint@^1.73.0` / `oxfmt@^0.58.0` を devDependency に追加
- [x] `.oxfmtrc.json` を作成（現行スタイル再現 + `sortPackageJson:false` + `ignorePatterns`）
- [x] `.oxlintrc.json` を作成（`correctness` gate + `no-unused-vars` の `^_` ignore pattern）
- [x] `biome.json` を削除
- [x] ルート `package.json` の 6 scripts を oxlint/oxfmt へ置換
- [x] `oxfmt --list-different` / `--check` で対象が手書き `.mjs`/JSON 100 件のみと検証
- [x] `pnpm run check` pass + `git diff --exit-code` clean を確認（**再整形 diff ゼロ**：oxfmt 出力は Biome と一致したため別コミット不要）

### T3: CI 置換（commit `🔧 Run oxlint + oxfmt in lint-format CI`）
- [x] `lint-format.yml` の job を `biome` → `oxc`、step を oxlint + oxfmt に置換
- [x] required status check への影響を確認（main は required check 未設定＝影響なし）

### T4: PostToolUse hook 置換（commit `🔧 Auto-format via oxfmt in PostToolUse hook`）
- [x] `.claude/hooks/biome-format.sh` → `oxfmt-format.sh`（`git mv` + 書き換え、`*.res.mjs` を明示 skip）
- [x] `.claude/settings.json` の command パスを更新
- [x] `bash -n` で構文検証 + hook の実行スモークテスト

### T5: ドキュメント更新（commit `📝 Update docs for the oxlint/oxfmt migration`）
- [x] `CLAUDE.md` / `README.md` / `CONTRIBUTING.md` を更新
- [x] `docs/repository-structure.md`（tree / hooks / config 表）を更新
- [x] `docs/development-guidelines.md` / `docs/functional-design.md` を更新
- [x] `.github/dependabot.yml` の `biome` グループを oxlint/oxfmt に retarget
- [x] 履歴 changelog（`packages/core/CHANGELOG.md` / `sphinx-docs/.../changelog.md`）は不変記録のため据え置き

### T6: 最終検証 + マージ
- [x] `pnpm run check` pass + `git diff --exit-code` clean を最終確認
- [x] `pnpm --recursive build` rc 0 / `pnpm --recursive test` 全 pass（build 生成物は oxc 側で ignore、tree clean）
- [x] 全タスク `[x]` を最終コミットに含める
- [x] PR 作成 → CI green 確認 → self-merge → worktree クリーンアップ

## 実装メモ（振り返り）
- oxfmt デフォルトが Biome スタイルとほぼ一致し、明示指定は `semi:false` のみで足りた。`sortPackageJson` はデフォルト `true` のため `false` を明示して package.json のキー順を維持。
- oxlint は `suspicious` カテゴリが `__TAURI_INTERNALS__` に `no-underscore-dangle` を多発させるため、Biome recommended との整合と安定 gate を優先し `correctness` のみに絞った。`catch (_)` の未使用は `^_` ignore pattern で吸収。
- fresh worktree は node_modules 未populate のため build 前に `pnpm install` が必須だった（`pnpm add -w` のみでは workspace package の bin が揃わない）。
- `git mv` を先行ステージしたため rename が CI コミットに、内容変更が hook コミットに分かれた（最終ツリーは正しい）。
- 既存の未コミット draft steering `20260630-001`（別 worktree `biome-to-oxc`）はユーザー承認のもと worktree ごと削除し、本 `20260713-001` で置き換えた。
