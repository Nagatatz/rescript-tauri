# Steering 026: sphinx-docs Phase 1 同期

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | documentation.md, PRD §8 |
| ブランチ | `worktree-phase1-sphinx-sync` |

## 背景

Phase 1 の 12 モジュール + Tauri 上位 re-export + 4 examples + 9 CI workflow がすべて実装済み。`sphinx-docs/` は当時 (steering 004 時点) のままで、`Window` / `Webview` / `WebviewWindow` / `Menu` / `Tray` / `App` / `Path` / `Image` / `Dpi` / `Mocks` の言及が user / dev ガイドにない。Phase 1 リリース直前の現状を反映する。

## 要求

### user/quickstart.md

- 既存の Layer 1 / Layer 2 / Event セクションは維持
- 新規セクション追加:
  - **Window operations** （`Window.getCurrent` + `setTitle` / `maximize` / `setSize` の最小例）
  - **Spawning a WebviewWindow** （`WebviewWindow.make` 最小例 + `asWindow` キャスト）
  - **Streaming with Channel** （`Core.Channel.make` + `onMessage`）
  - **Path / App utilities**（`Path.appConfigDir`, `App.getName` の小例）
- 「Implementation in progress」の警告は Phase 1 リリース後に外す前提で **「フィーチャー完成、npm publish 待ち」** に書き換える

### user/installation.md

- 「Not yet published on npm」警告を「`npm publish` は Phase 1 リリース時実行」に明確化
- インストール手順は変更しない（`pnpm add @rescript-tauri/core @tauri-apps/api`）

### user/configuration.md

- 「Top-level Tauri re-export」セクションの本文を、確定済みの 5 モジュール (Core / Event / Window / Webview / WebviewWindow) を明示する形に更新
- 「The exact re-export set is finalized in functional-design §2.13」→ steering 023 で確定したことを記載

### user/changelog.md

- 「Unreleased」セクションを充実させ、Phase 1 で追加された 12 モジュールを `### Added` に列挙

### dev/architecture.md

- 「Key components」テーブルに Phase 1 完成事実を反映（既存テーブルは正しいので変更不要）
- 「Where to dig deeper」テーブルは現状維持

### user/index.md

- 「Modules at a glance」テーブルを新規追加し、12 モジュール + Tauri 上位 re-export を簡潔に列挙する

## Non-goals

- 各モジュール個別のリファレンスページ作成（後段、Phase 2 か別途 sphinx-rescript の自動生成導入時）
- 日本語訳 (`locale/ja/`) の更新（次セッションで `make update-po` 後に行う）

## 受け入れ条件

- [x] sphinx-docs の Phase 1 関連 4 ページ (user/quickstart, user/installation, user/configuration, user/changelog) を更新
- [x] user/index.md に Modules at a glance を追加
- [x] sphinx-docs ローカルビルドが緑 (`make html`) — または最低でも sphinx-build dryrun が出来る範囲確認
- [x] 既存リンク切れなし
- [x] PRD / functional-design への参照は維持
