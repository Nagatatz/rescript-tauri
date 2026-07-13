# タスクリスト: Biome から oxlint / oxfmt への移行

| 項目 | 内容 |
|---|---|
| 採番 | 20260713-001 |
| 作成日 | 2026-07-13 |
| 関連 | requirements.md / design.md |

## テスト方針（省略理由の明記）

本作業は lint/format 外部ツールの差し替えのため専用ユニットテストは追加しない（`testing.md` の「外部サービス結合が必須で単体テストが困難」に準拠）。代わりに `pnpm run check` pass / `git diff --exit-code` clean / `oxfmt --list-different` の対象検証 / CI green で振る舞いを担保する（design.md §5）。

## タスク

### T1: 依存差し替え + 設定ファイル
- [ ] `@biomejs/biome` を削除し `oxlint@^1.73.0` / `oxfmt@^0.58.0` を devDependency に追加（`pnpm remove` / `pnpm add -D`）
- [ ] `.oxfmtrc.json` を作成（design §3.1 のスタイル + `ignorePatterns`）
- [ ] `.oxlintrc.json` を作成（design §3.2）
- [ ] `biome.json` を削除
- [ ] コミット `🔧 Replace Biome config/deps with oxlint + oxfmt`

### T2: scripts 置換 + 再整形適用
- [ ] ルート `package.json` の 6 scripts を oxlint/oxfmt へ置換（design §3.3）
- [ ] `oxfmt --list-different "**/*.mjs" "**/*.json"` の出力を確認し、対象が `.mjs`/JSON のみ・除外対象が含まれないことを検証（含まれれば `ignorePatterns` 追加）
- [ ] `pnpm run check:fix` を一度実行し再整形差分を適用、`oxlint` 指摘を解消
- [ ] `pnpm run check` pass + `git diff --exit-code`（再整形後）clean を確認
- [ ] コミット（再整形 diff は分離）`🎨 Reformat handwritten .mjs/.json with oxfmt`
- [ ] コミット `🔧 Switch package.json lint/format scripts to oxc`

### T3: CI 置換
- [ ] `lint-format.yml` を oxlint + oxfmt --check に置換（design §3.5）
- [ ] required status check 名への影響を確認（変更が必要ならユーザーに確認）
- [ ] コミット `🔧 Run oxlint + oxfmt in lint-format CI`

### T4: PostToolUse hook 置換
- [ ] `.claude/hooks/biome-format.sh` → `oxfmt-format.sh`（`git mv` + Edit、design §3.4）
- [ ] `.claude/settings.json` の command パスを `.claude/hooks/oxfmt-format.sh` に更新
- [ ] `bash -n` で hook の構文検証
- [ ] コミット `🔧 Auto-format via oxfmt in PostToolUse hook`

### T5: ドキュメント更新
- [ ] `CLAUDE.md`（品質チェックセクション）を oxlint/oxfmt に更新
- [ ] `README.md` の Biome 言及を更新
- [ ] `CONTRIBUTING.md` の lint-format 記述を更新
- [ ] `docs/repository-structure.md`（hooks 一覧 / `biome.json` / `lint-format.yml`）を更新
- [ ] `docs/development-guidelines.md` の format+lint セクションを更新
- [ ] `docs/functional-design.md` §6 CI テーブルを更新
- [ ] コミット `📝 Update docs for oxlint/oxfmt migration`

### T6: 最終検証 + マージ
- [ ] `pnpm run check` pass + `git diff --exit-code` clean を最終確認
- [ ] `pnpm --recursive build` / `pnpm --recursive test` が影響を受けないことを確認
- [ ] 全タスク `[x]` を最終コミットに含める
- [ ] PR 作成 → CI green 確認 → self-merge → worktree クリーンアップ

## 補足
- 既存の未コミット draft steering `20260630-001-biome-to-oxc-migration`（別 worktree `biome-to-oxc`）は本 steering `20260713-001` で置き換える。当該 worktree のクリーンアップはユーザーに確認する。
