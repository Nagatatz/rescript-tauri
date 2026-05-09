# 包括レビュー修正 — タスクリスト (tasklist.md)

## A. Status sweep

- [x] A-1 README.md の Status / Visibility ブロック (L19-21) を Phase 1+2 merged に書き換え
- [x] A-2 README.md L62-71 / L223 の design-phase 表現を実装済み・PR 受け入れ可に書き換え
- [x] A-3 CONTRIBUTING.md §1 / §3 を現行運用に書き換え
- [x] A-4 CONTRIBUTING.md §3.7 CI gates 列挙を最新ワークフローに揃える
- [x] A-5 SECURITY.md Phase 1 design-phase 表現を実態に合わせて修正
- [x] A-6 examples 各 README の Status ブロックを統一（hello-world / plugin-fs-demo / plugin-dialog-demo / ipc-typed-with-schema）。window-management / ipc-typed / streaming-ipc は元々 Status 欄を持たないため touch なし
- [x] A-7 sphinx-docs `index.md` / `dev/contributing.md` の design-phase 表現を更新（`dev/setup.md` には該当箇所なし）
- [x] A-8 ビルド・テスト緑確認（Biome は worktree 内では `!**/.claude/worktrees` ignore で実行不能、main マージ後 CI で確認）
- [x] A-9 Scope A をコミット（絵文字: 📝）

## B. docs/ 整合

- [x] B-1 docs/architecture.md L6 / L143-145 の `Phase 1〜Phase 3` / peerDep `^1.0.0` を修正（plugin-dialog 行追加 + `0.1 → 1.0` 昇格条件追記）
- [x] B-2 docs/development-guidelines.md / sphinx-docs/user/configuration.md の `§2.13` を `§2.8` に修正
- [x] B-3 docs/functional-design.md L12 「後続作成予定」を削除
- [x] B-4 docs/migration-to-plugins.md と docs/quality-measurement.md を `git rm` 削除
- [x] B-5 docs/repository-structure.md の参照行（§1 ルートレイアウト・§4 表）を削除（他に live 参照なし。`.steering/030` の言及はアーカイブ的記録なので touch なし）
- [x] B-6 docs/product-requirements.md ステータス + §4 + §8 + §10 (#2/#3) を実態に更新
- [x] B-7 docs/functional-design.md ステータス + §1.1 examples 配置図 + §5.3 + §6 + §8 (#1/#2/#3) を更新
- [x] B-8 docs/development-guidelines.md / glossary.md の Phase 1 future tense / schema 説明を更新
- [x] B-9 README.md / docs/functional-design.md / sphinx-docs/dev/project-structure.md の examples 一覧を 7 例に揃える（README は Scope A で実施済）
- [x] B-10 AGENTS.md は実在しない（hallucination だった）ため不要、スキップ
- [x] B-11 ビルド緑確認（テスト/Biome は Scope C で再実行）。Sphinx `.po` 翻訳キャッシュは `make update-po` 必要なので別タスクに分離
- [x] B-12 Scope B をコミット（絵文字: 📝）

## C. セキュリティ修正

- [x] C-1 `.github/workflows/claude-code-review.yml.template` の `actions/checkout@v4` / `anthropics/claude-code-action@v1` を SHA pinned に変更（v6.0.2 / v1 SHA `c7d6092...`）
- [x] C-2 `.github/workflows/auto-pr-description.yml.template` の `actions/checkout@v4` を SHA pinned に変更（v6.0.2）
- [x] C-3 `.github/workflows/auto-pr-description.yml.template` の `${{ github.base_ref }}` / PR 番号を `env:` 経由 + quote で受ける
- [x] C-4 `examples/hello-world/src-tauri/tauri.conf.json` に推奨 CSP を設定
- [x] C-5 `examples/hello-world/README.md` に CSP 設定の説明を追加
- [x] C-6 `packages/core/src/Core.resi` の `convertFileSrc` / `RustError` バリアント doc を補強
- [x] C-7 `packages/schema/src/Schema.res` 内部コメントに decoder 例外契約を明記
- [x] C-8 ビルド・テスト緑確認
- [x] C-9 Scope C をコミット（一括）

## D. API 整合リファクタ

- [x] D-1 `packages/core/src/Window.{resi,res}` の `setBackgroundColor` を `Nullable.t<color>` 化
- [x] D-2 `packages/core/src/Webview.res` `onDragDropEvent` の未知 kind を `Console.warn` ログに変更
- [x] D-3 `packages/core/src/Webview.resi` `onDragDropEvent` doc comment 補強
- [x] D-4 `packages/schema/src/Schema.resi` から `Core` / `Event` 公開シグネチャ削除（`S` は DSL convenience として examples で使用中なので維持）
- [x] D-5 `packages/schema/src/Schema.resi` の See リンクを Tauri 公式 URL に差し替え
- [x] D-6 `packages/schema/src/Schema.{resi,res}` `eventFromSchema` のラベルを `~payload` → `~schema` に変更
- [x] D-7 `examples/ipc-typed-with-schema/src/App.res` 呼び出し側を更新
- [x] D-8 `packages/schema/tests/schema_signature.res` を更新
- [x] D-9 `packages/core/src/Tray.resi` `close` の See リンクを `namespacetray` に修正
- [x] D-10 `packages/core/src/App.{resi,res}` `setTheme` を `Nullable.t<theme>` の単一引数に変更（`tests/app_signature.res` も併修）
- [x] D-11 `packages/core/src/Window.{resi,res}` `monitorFromPoint` を `(~x, ~y)` ラベル化（`tests/window_signature.res` も併修）
- [x] D-12 `packages/plugin-fs/src/PluginFs.resi` `readFileOptions.encoding` doc に `"utf-8"` 限定を明記
- [x] D-13 `packages/core/src/Menu.resi` 各モジュール先頭の共通 6 メソッド注記
- [x] D-14 破壊変更の波及（tests / example）を grep で網羅。sphinx-docs / docs に該当呼び出しはなし
- [x] D-15 クリーンビルド + 全 4 パッケージ test 緑確認（core 26 / plugin-fs 6 / plugin-dialog 10 / schema 5）
- [x] D-16 Scope D をコミット

## マージ

- [x] M-1 tasklist.md の全タスクを `[x]` に更新（マージタスク自体を含む）
- [x] M-2 tasklist 更新コミットを作成
- [x] M-3 ユーザーに main へのマージ可否を確認
- [x] M-4 main にマージ + worktree / ブランチ クリーンアップ
- [x] M-5 クリーンアップ完了の検証 (`git worktree list` / `git branch --list 'worktree-*'` / `.claude/worktrees/`)
