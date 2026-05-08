# Steering 030: Phase 2 Planning

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 種類 | リサーチ・計画（コード変更なし、main 直接コミット） |
| 関連 | PRD §8, architecture §10, RFC-0001 §2.4, .steering/20260509-029-phase1-release-followups |

## 背景

Phase 1 (`@rescript-tauri/core` v0.1.0) は実装完了し、Phase 1 リリース当日チェックリストに残るのは npm publish + GitHub 設定のみ。本 steering は **Phase 2 の作業範囲を確定し、着手順序を決める** 計画書。実装スコープ自体の決定は、Phase 1 リリース後 1〜2 週間のユーザーフィードバックを参照しながら最終調整する前提とする。

## Phase 2 の目的（architecture §10 より）

> core の API 表面を変えずに「スキーマ統合 + 各 Tauri plugin バインディング」を独立パッケージとして追加し、ユーザーがエンコーダ/デコーダ手書きと plugin 手書き external から解放される世界をつくる。

成功条件:

1. `@rescript-tauri/schema` を npm publish。`Command.fromSchemas` 経由で `rescript-schema` ベースの IPC 宣言が動く。
2. 最低 2 プラグイン（`plugin-fs`, `plugin-dialog`）を npm publish。各々が独立 semver、独自 CI、独自互換マトリクス。
3. `@rescript-tauri/core` の API 表面は **不変**（追加のみ、破壊的変更なし）。例外: 残課題 #5 / `Window.setSize` 引数厳格化など、pre-`v1.0.0` の最終整形は許容。

## スコープ（Phase 2 で実装するもの）

### 必須スコープ (Must)

| 項目 | 内容 | 完成条件 |
|---|---|---|
| `@rescript-tauri/schema` | `Command.fromSchemas`, `Channel.fromSchema`, `Event.fromSchema` の 3 ヘルパ実装 | RFC-0002 確定 + npm publish + 互換マトリクス |
| `@rescript-tauri/plugin-fs` | upstream `@tauri-apps/plugin-fs` v2.5.x の全公開 API を `.resi` 必須でバインド | npm publish + 既存 4 OS 互換 CI 拡張 |
| `@rescript-tauri/plugin-dialog` | upstream `@tauri-apps/plugin-dialog` v2.7.x | 同上 |
| RFC-0002 | Schema 統合の API 確定文書 | `docs/ideas/RFC-0002-schema-integration.md` を merge |

### 強く推奨スコープ (Should)

| 項目 | 内容 | 完成条件 |
|---|---|---|
| `@rescript-tauri/plugin-opener` | upstream `@tauri-apps/plugin-opener` v2.5.x | npm publish |
| `@rescript-tauri/plugin-process` | upstream `@tauri-apps/plugin-process` v2.3.x | npm publish |
| `Mocks` モジュール拡張 | `mockEvents` / `mockChannel` / `mockConvertFileSrc` を追加 | 既存 4 テスト（event / core_channel / window / core_raw_convert）を Mocks ベースに統合 |
| 残課題 #5 決定 | `Mocks` の独立パッケージ化を改めて評価 | PRD §10 #5 を「確定済み」状態に |

### あれば嬉しいスコープ (Could)

| 項目 | 内容 |
|---|---|
| `@rescript-tauri/plugin-updater` | upstream `@tauri-apps/plugin-updater` |
| `@rescript-tauri/plugin-shell` | upstream `@tauri-apps/plugin-shell`（セキュリティ要注意） |
| `@rescript-tauri/plugin-store` | upstream `@tauri-apps/plugin-store`（永続化 KV） |
| App / Webview の Phase 1 見送り API 再評価 | `App.fetchDataStoreIdentifiers`, `App.onBackButtonPress` 等の安定性確認 + 必要なら追加バインディング |
| `Window.setSize` 等の polymorphic 引数厳格化 | `'size` を `Dpi.Size.t` に固定（pre-1.0 のうちに破壊変更） |
| NativeIcon variant 完全列挙 | Menu の icon 受け取りを文字列 escape hatch から型安全 variant へ |

### Non-goals（Phase 2 では絶対やらない）

- Rust 側コード生成（PRD §1.5 / `specta` の責務）
- プロジェクトスキャフォールド `create-rescript-tauri`（別プロダクト）
- UI コンポーネント同梱
- Effect-based API（ReScript の effect 安定化待ち、Phase 3 以降）
- Tauri 1.x サポート（v2.x 専用ポリシー継続）
- ReScript 11 サポート（v12+ 専用、PRD §10 #7 確定済み）
- 自動承認フローのリリース（手動 tag push 維持）

## 前提条件 / トリガー

Phase 2 着手の前提:

- Phase 1 `v0.1.0` が npm publish 済み（`.steering/20260509-029-phase1-release-followups/release-checklist.md` 完了）
- Phase 1 リリース後 **1〜2 週間** のユーザーフィードバックを収集（issue / discussions / 公開直後の Forum 反応）
- フィードバックに応じて Must スコープ内の優先順位を再判定（schema が先か plugin が先か）

優先順位の判定基準:

| ユーザーフィードバック傾向 | 優先順 |
|---|---|
| 「encoder/decoder の手書きが辛い」「rescript-schema と統合したい」が複数 | schema を最優先 |
| 「FS が無いと実用にならない」「Dialog が欲しい」が複数 | plugin-fs / plugin-dialog を最優先 |
| 両方ほぼ同程度 | schema を先（plugin の API 設計に schema が役立つため） |

## 受け入れ条件（Phase 2 完了時）

- [ ] `@rescript-tauri/schema` v0.1.0 が npm publish
- [ ] `@rescript-tauri/plugin-fs` v0.1.0 が npm publish
- [ ] `@rescript-tauri/plugin-dialog` v0.1.0 が npm publish
- [ ] `examples/` に schema と各 plugin の利用例が追加（CI 緑）
- [ ] `docs/ideas/RFC-0002-schema-integration.md` が merge 済み
- [ ] 各パッケージで `peerDependencies` 互換マトリクスが README に記載
- [ ] PRD §10 残課題 #5 が「確定済み」状態
