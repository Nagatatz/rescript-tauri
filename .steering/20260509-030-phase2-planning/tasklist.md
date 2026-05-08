# Tasklist: Phase 2 Planning

本 steering は Phase 2 全体の planning 集約。実装着手は別 sub-steering で逐次行う。本 tasklist は **Phase 2 全体** のロードマップとして使い、進捗に応じてチェックを入れる。

## A. 計画フェーズ（本 steering で完了）

- [x] `.steering/20260509-030-phase2-planning/` ディレクトリ作成
- [x] requirements.md（スコープ・優先順位・受け入れ条件）
- [x] design.md（パッケージ構造 / API / CI / リリース戦略）
- [x] tasklist.md（本ファイル）
- [x] main 直接コミット (`📝 Add Phase 2 planning steering`)

## B. Phase 1 リリース完了待ち（前提条件）

- [ ] Phase 1 (`@rescript-tauri/core` v0.1.0) npm publish 完了
  → `.steering/20260509-029-phase1-release-followups/release-checklist.md` 完了
- [ ] Phase 1 リリース後 1〜2 週間のフィードバック収集
- [ ] フィードバックに応じた Phase 2 着手順序の最終判定
  - schema 優先 / plugin 優先 / 並行進行のどれにするか

## C. RFC-0002 (Schema 統合 API 確定)

- [ ] `docs/ideas/RFC-0002-schema-integration.md` ドラフト作成
- [ ] `rescript-schema` vs `rescript-struct` の正本選定
- [ ] `Command.fromSchemas` シグネチャ確定
- [ ] `Channel.fromSchema` / `Event.fromSchema` 仕様確定
- [ ] PR レビューと merge

## D. `@rescript-tauri/schema` 実装

- [ ] `packages/schema/` 雛形（package.json / rescript.json / src/Schema.res(.resi)）
- [ ] `peerDependencies` 確定（`@rescript-tauri/core ^1.0.0`, `rescript-schema >=...`）
- [ ] `Command.fromSchemas` 実装
- [ ] `Channel.fromSchema` 実装
- [ ] `Event.fromSchema` 実装
- [ ] 型レベル signature テスト
- [ ] runtime テスト（vitest + Mocks 経由）
- [ ] `examples/ipc-typed-with-schema/` 追加
- [ ] CI: `tests-schema-types.yml` / `tests-schema-runtime.yml` 追加
- [ ] CI: `compat-rescript-schema-prerelease.yml` 追加（任意）
- [ ] `release.yml` を `schema-v*` タグに対応するよう拡張
- [ ] README + 互換マトリクス
- [ ] `schema-v0.1.0` tag → npm publish

## E. `@rescript-tauri/plugin-fs` 実装

- [ ] `packages/plugin-fs/` 雛形
- [ ] upstream `@tauri-apps/plugin-fs` v2.5.x の API 表面把握
- [ ] バインディング本体（`PluginFs.res` / `.resi`）
- [ ] `BaseDirectory` の扱い（core の Path と統合 or 独立）確定
- [ ] watch 系 API の sub-module 設計
- [ ] 型レベル signature テスト
- [ ] runtime テスト（Mocks 経由）
- [ ] `examples/plugin-fs-demo/` 追加
- [ ] CI 拡張
- [ ] `release.yml` を `plugin-fs-v*` タグに対応
- [ ] README + 互換マトリクス
- [ ] `plugin-fs-v0.1.0` tag → npm publish

## F. `@rescript-tauri/plugin-dialog` 実装

- [x] `packages/plugin-dialog/` 雛形 (steering 035)
- [x] upstream `@tauri-apps/plugin-dialog` v2.7.x の API 表面把握 (steering 035)
- [x] バインディング本体 (steering 035)
- [x] options 型 / multiple-selection / directory-selection の variant 設計 (steering 035)
- [x] 型レベル signature テスト + runtime テスト (steering 035)
- [x] `examples/plugin-dialog-demo/` 追加 (steering 036)
- [ ] CI 拡張
- [ ] README + 互換マトリクス
- [ ] `plugin-dialog-v0.1.0` tag → npm publish

## G. Should スコープ（Phase 2 中盤以降に判断）

- [ ] `@rescript-tauri/plugin-opener` 実装 + publish
- [ ] `@rescript-tauri/plugin-process` 実装 + publish
- [ ] Mocks 拡張（`mockEvents` / `mockChannel` / `mockConvertFileSrc`）
- [ ] 残 4 テスト（event / core_channel / window / core_raw_convert）の Mocks 化
- [ ] PRD §10 残課題 #5 の最終決定（`Mocks` 独立パッケージ化 or core 同梱継続）

## H. Could スコープ（余力次第）

- [ ] `@rescript-tauri/plugin-updater`
- [ ] `@rescript-tauri/plugin-shell`（セキュリティ評価必須）
- [ ] `@rescript-tauri/plugin-store`
- [ ] App / Webview の Phase 1 見送り API 再評価
- [ ] `Window.setSize` polymorphic 引数を `Dpi.Size.t` に固定
- [ ] NativeIcon variant 完全列挙

## I. Phase 2 完了条件

- [ ] 「必須スコープ」がすべて publish + CI 緑
- [ ] 各パッケージの README に互換マトリクス記載
- [ ] `docs/repository-structure.md` を Phase 2 構成に更新
- [ ] `sphinx-docs/` を Phase 2 全パッケージに対応
- [ ] PRD §10 残課題 #5 が「確定済み」に
- [ ] CHANGELOG が各パッケージで `0.1.0` 以降の履歴を持つ

## J. Phase 3 着手判断（Phase 2 完了後）

- [ ] Phase 2 リリース後 1 ヶ月のフィードバック収集
- [ ] 次期 ReScript メジャー prerelease の互換性確認
- [ ] core の `v1.0.0` 確定タイミング判断
- [ ] Phase 3 planning steering 作成
