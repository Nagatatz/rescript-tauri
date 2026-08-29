# Steering 029: Phase 1 リリース後フォローアップ + Mocks リファクタ

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | PRD §8, .steering/20260509-018〜026, .steering/20260509-027 (core-refactoring), .steering/20260509-028 (SHA pinning) |
| ブランチ | `worktree-phase1-release-followups` |

## 背景

Steering 018〜026 + 並行作業 027 (core-refactoring) / 028 (SHA pinning) で Phase 1 リリースゲート（PRD §8）に必要な実装はすべて完了。残るのは:

| 項目 | 種類 | 担当 |
|---|---|---|
| npm publish 0.1.0 | リリース手順 | メンテナ手動（NPM_TOKEN secret 設定 + tag push）|
| GitHub branch protection | リポジトリ設定 | メンテナ手動（GitHub UI / `gh api`）|
| GHSA (Security Advisories) 有効化 | リポジトリ設定 | メンテナ手動（visibility public 化後）|
| Workflow SHA pinning | リポジトリ設定 | **完了済**（steering 028）|
| 既存テストの Mocks へリファクタ | コード | 本 steering で実施可能な範囲 |

本 steering では:
1. **コードで完結する部分**（既存テストを `Mocks.mockIPC` ベースにリファクタ）を実装
2. **メンテナ手動作業のチェックリスト**を `.steering/<n>/release-checklist.md` に永続化し、リリース当日のオペレーションを楽にする

## 要求

### コードリファクタ範囲

`Mocks.mockIPC` で代替可能な既存テスト 2 本のみリファクタ。残り 4 本は `transformCallback` / `convertFileSrc` / `metadata` 等 Mocks 未対応の internals を使うため対象外（リファクタには Mocks モジュール拡張が必要、Phase 2 で再評価）。

| ファイル | リファクタ可否 | 理由 |
|---|---|---|
| `core_raw.test.mjs` | ✓ | `invoke` のみ使用 → `Mocks.mockIPC` に置換可 |
| `core_command.test.mjs` | ✓ | 同上 |
| `core_raw_convert.test.mjs` | ✗ | `convertFileSrc` 内部関数。Mocks 未対応 |
| `event.test.mjs` | ✗ | `transformCallback` を使う listen/once フローあり |
| `core_channel.test.mjs` | ✗ | `transformCallback` 必須 |
| `window.test.mjs` | ✗ | `transformCallback` + `metadata.currentWindow` 必須 |
| `mocks.test.mjs` | — | 既に Mocks ベース |

### リリースチェックリスト

`.steering/20260509-029-phase1-release-followups/release-checklist.md` を作成し、Phase 1 リリース当日のオペレーション手順 (npm publish / branch protection / GHSA / smoke verify / changelog) を 1 ページにまとめる。

## Non-goals

- Mocks モジュール拡張（`mockEvents` / `mockChannel` / `mockConvertFileSrc`）— Phase 2 で再評価
- 自動リリース承認フロー（ApplicationHandler 系）— 当面手動 tag push
- changelog 自動生成ツール導入（changesets 等）— Phase 2

## 受け入れ条件

- [x] `core_raw.test.mjs` を `Mocks.mockIPC` ベースに書き換え
- [x] `core_command.test.mjs` を `Mocks.mockIPC` ベースに書き換え
- [x] `pnpm --filter @rescript-tauri/core test` 全件パス（26/26）
- [x] `release-checklist.md` を `.steering/20260509-029-phase1-release-followups/` に配置
- [x] 他 4 テストが未変更で引き続き緑
