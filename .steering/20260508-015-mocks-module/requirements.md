# 要求定義: Mocks モジュール

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-015 |
| タイトル | mocks-module |
| 起票日 | 2026-05-08 |
| 影響範囲 | `packages/core/src/Mocks.{res,resi}` 新規 + テスト |

## 動機

PRD Story 6-1 + functional-design §2.7 の `Mocks` モジュールを実装する。これまで各 vitest テストで `globalThis.window.__TAURI_INTERNALS__` を手動で組み立てていたが、`@tauri-apps/api/mocks` 公式ヘルパ (`mockIPC` / `mockWindows` / `clearMocks`) のラッパがあれば、ユーザー側のテストコードもシンプルになる。

## スコープ

### 対象

新規 `packages/core/src/Mocks.{res,resi}`:

- `let mockIPC: ((string, JSON.t) => promise<JSON.t>) => unit`
- `let mockWindows: (~current: string, ~additional: array<string>=?) => unit`
- `let clearMocks: unit => unit`

### 対象外

- `mockConvertFileSrc` 等の追加 mock helper (Tauri 公式が提供するなら別ステアリング)
- 既存テスト群の Mocks への置換（リファクタリングは別ステアリング）

## 派生決定

| 論点 | 採用 |
|---|---|
| `mockWindows` の variadic 引数 | ReScript の `@variadic` を内部で使い、ユーザー API は `~current` + `~additional=?` の named arg にする |
| `mockIPC` handler の sig | `(string, JSON.t) => promise<JSON.t>`（functional-design §2.7 通り）|
| Tauri docs URL | `https://v2.tauri.app/reference/javascript/api/namespacemocks/` |
| worktree 名 | `mocks-module` |

## 受け入れ条件

- [ ] `Mocks.{mockIPC, mockWindows, clearMocks}` 実装
- [ ] 型レベルテストで全公開シンボル参照
- [ ] vitest で Mocks 経由の round-trip 検証（PRD Story 6-1 受け入れ条件「Mocks.mockIPC で IPC を差し替えた状態で Core.Command.invoke の round-trip をパス」）
- [ ] doc comment に Tauri 公式 URL を含む + production ビルドで利用可能だがテスト用途である旨を明示（PRD §5.7）
