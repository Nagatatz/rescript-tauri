# 包括レビュー修正 — タスクリスト (tasklist.md)

## A. Status sweep

- [ ] A-1 README.md の Status / Visibility ブロック (L19-21) を Phase 1+2 merged に書き換え
- [ ] A-2 README.md L62-71 / L223 の design-phase 表現を実装済み・PR 受け入れ可に書き換え
- [ ] A-3 CONTRIBUTING.md §1 / §3 を現行運用に書き換え
- [ ] A-4 CONTRIBUTING.md §3.7 CI gates 列挙を最新ワークフローに揃える
- [ ] A-5 SECURITY.md Phase 1 design-phase 表現を実態に合わせて修正
- [ ] A-6 examples 各 README の Status ブロックを統一（hello-world / window-management / ipc-typed / streaming-ipc / plugin-fs-demo / plugin-dialog-demo / ipc-typed-with-schema）
- [ ] A-7 sphinx-docs `index.md` / `dev/contributing.md` / `dev/setup.md` の design-phase 表現を更新
- [ ] A-8 ビルド・テスト・Biome check 緑確認
- [ ] A-9 Scope A をコミット（絵文字: 📝）

## B. docs/ 整合

- [ ] B-1 docs/architecture.md L6 / L143-145 の `Phase 1〜Phase 3` / peerDep `^1.0.0` を修正
- [ ] B-2 docs/development-guidelines.md / sphinx-docs/user/configuration.md の `§2.13` dangling anchor を修正
- [ ] B-3 docs/functional-design.md L12 「後続作成予定」を削除
- [ ] B-4 docs/migration-to-plugins.md と docs/quality-measurement.md を `git rm` 削除
- [ ] B-5 docs/repository-structure.md の参照行 (§4 表) を削除し、CLAUDE.md / 他からの参照も grep して削除
- [ ] B-6 docs/product-requirements.md ステータス + §4 + §8 + §10 を実態に更新
- [ ] B-7 docs/functional-design.md ステータス + §1.1 examples 配置図 + §5.3 + §6 + §8 を更新
- [ ] B-8 docs/development-guidelines.md / glossary.md の Phase 1 future tense / schema 説明を更新
- [ ] B-9 README.md / docs/functional-design.md / sphinx-docs/dev/project-structure.md の examples 一覧を 7 例に揃える
- [ ] B-10 AGENTS.md を CLAUDE.md と最小同期（Biome 行追加）
- [ ] B-11 ビルド・テスト・Biome check 緑確認
- [ ] B-12 Scope B をコミット（絵文字: 📝）

## C. セキュリティ修正

- [ ] C-1 `.github/workflows/claude-code-review.yml.template` の `actions/checkout@v4` / `anthropics/claude-code-action@v1` を SHA pinned に変更
- [ ] C-2 `.github/workflows/auto-pr-description.yml.template` の `actions/checkout@v4` を SHA pinned に変更
- [ ] C-3 `.github/workflows/auto-pr-description.yml.template` の `${{ github.base_ref }}` / PR 番号を `env:` 経由 + quote で受ける
- [ ] C-4 `examples/hello-world/src-tauri/tauri.conf.json` に推奨 CSP を設定
- [ ] C-5 `examples/hello-world/README.md` に CSP 設定の説明を追加
- [ ] C-6 `packages/core/src/Core.resi` の `convertFileSrc` / `RustError` バリアント doc を補強
- [ ] C-7 `packages/schema/src/Schema.res` 内部コメントに decoder 例外契約を明記
- [ ] C-8 ビルド・テスト・Biome check 緑確認
- [ ] C-9 Scope C をコミット（絵文字: 🔧 + 📝、または分割）

## D. API 整合リファクタ

- [ ] D-1 `packages/core/src/Window.{resi,res}` の `setBackgroundColor` を `Nullable.t<color>` 化
- [ ] D-2 `packages/core/src/Webview.res` `onDragDropEvent` の未知 kind を `Console.warn` ログに変更
- [ ] D-3 `packages/core/src/Webview.resi` `onDragDropEvent` doc comment 補強
- [ ] D-4 `packages/schema/src/Schema.{resi,res}` の `module Core/Event/S` 公開シグネチャ削除
- [ ] D-5 `packages/schema/src/Schema.{resi,res}` の See リンクを Tauri 公式 URL に差し替え
- [ ] D-6 `packages/schema/src/Schema.{resi,res}` `eventFromSchema` のラベルを `~payload` → `~schema` に変更
- [ ] D-7 `examples/ipc-typed-with-schema/src/App.res` 呼び出し側を更新
- [ ] D-8 `packages/schema/tests/schema_signature.res` を更新
- [ ] D-9 `packages/core/src/Tray.resi` `close` の See リンクを `namespacetray` に修正
- [ ] D-10 `packages/core/src/App.{resi,res}` `setTheme` を `Nullable.t<theme>` の単一引数に変更
- [ ] D-11 `packages/core/src/Window.{resi,res}` `monitorFromPoint` を `(~x, ~y)` ラベル化
- [ ] D-12 `packages/plugin-fs/src/PluginFs.resi` `readFileOptions.encoding` doc に `"utf-8"` 限定を明記
- [ ] D-13 `packages/core/src/Menu.resi` 各モジュール先頭の共通 6 メソッド注記
- [ ] D-14 破壊変更の波及（examples / sphinx-docs / docs / tests）を grep 確認・更新
- [ ] D-15 ビルド・テスト・Biome check 緑確認
- [ ] D-16 Scope D をコミット（絵文字: ♻️ + 🐛、または分割）

## マージ

- [ ] M-1 tasklist.md の全タスクを `[x]` に更新（マージタスク自体を含む）
- [ ] M-2 tasklist 更新コミットを作成
- [ ] M-3 ユーザーに main へのマージ可否を確認
- [ ] M-4 main にマージ + worktree / ブランチ クリーンアップ
- [ ] M-5 クリーンアップ完了の検証 (`git worktree list` / `git branch --list 'worktree-*'` / `.claude/worktrees/`)
