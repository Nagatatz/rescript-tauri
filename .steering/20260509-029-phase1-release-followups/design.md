# Design: Phase 1 リリース後フォローアップ

## 編集対象

```
packages/core/tests/runtime/
├── core_raw.test.mjs      # 書き換え: globalThis.window.__TAURI_INTERNALS__ → Mocks.mockIPC
└── core_command.test.mjs  # 書き換え: 同上

.steering/20260509-029-phase1-release-followups/
├── requirements.md
├── design.md (本ファイル)
├── tasklist.md
└── release-checklist.md   # リリース当日のチェックリスト
```

## リファクタ方針

- 既存テストの `installInvokeMock(handler)` / `installMock(handler)` を `Mocks.mockIPC(handler)` 一発に置換
- `clearMock()` を `Mocks.clearMocks()` に置換
- `beforeEach(installMock)` で渡していた handler は各 `it(...)` 内で `Mocks.mockIPC(...)` を呼ぶ形に
- `Mocks` と `Core` のモジュール import は `beforeEach` で 1 回だけ実施し、テストごとに使い回す（ESM の動的 import コストを避ける）

## リファクタ対象外の理由

| ファイル | 利用 internals |
|---|---|
| `core_raw_convert.test.mjs` | `__TAURI_INTERNALS__.convertFileSrc` — 別関数 |
| `event.test.mjs` | `__TAURI_INTERNALS__.transformCallback`、`__TAURI_EVENT_PLUGIN_INTERNALS__.unregisterListener` |
| `core_channel.test.mjs` | `__TAURI_INTERNALS__.transformCallback` |
| `window.test.mjs` | `__TAURI_INTERNALS__.transformCallback`、`__TAURI_INTERNALS__.metadata.currentWindow` |

これらを `Mocks` 経由に集約するには `mockEvents` / `mockChannel` / `mockMetadata` 等を Mocks モジュールに追加する必要があり、これは **新規バインディング作業** で本フォローアップ steering の範囲を超える。Phase 2 に持ち越す。

## release-checklist.md の構造

メンテナがリリース当日 1 ページで参照できるよう、以下の 8 セクションで構成:

1. リリース前確認（PRD §8 ゲート）
2. リポジトリ visibility と secrets
3. Branch protection 設定
4. GHSA 有効化
5. リリース実行コマンド（changelog 更新 → tag → push → release.yml 自動実行）
6. リリース後検証（npm view / GitHub Releases / smoke test）
7. 告知（オプション）
8. Phase 2 起点準備

各項目はチェックボックス形式で、リリース日に「終わったらチェック」で運用できる。

## CI 影響

- 既存 26 テストがすべて引き続きパス（リファクタしたものも同等の検証カバレッジ）
- `Mocks` モジュールに依存することで、`Mocks` 自体の振る舞いも兼ねて検証されるようになる（テスト多重カバレッジ）
