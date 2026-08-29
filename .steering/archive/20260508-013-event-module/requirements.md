# 要求定義: Event モジュール

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-013 |
| タイトル | event-module |
| 起票日 | 2026-05-08 |
| 影響範囲 | `packages/core/src/Event.{res,resi}` 新規 + テスト |

## 動機

PRD Story 2-1 + RFC §3.1-3.3 + functional-design §2.2 の Event API を実装。Core モジュール (Raw / Command / Channel) の次の柱で、Tauri 側の pub/sub（`tauri://...` 系イベント等）を ReScript から型付きで購読・発行できるようにする。

## スコープ

### 対象

- `packages/core/src/Event.res` / `Event.resi` 新規:
  - `type event<'payload> = {event, id, payload}`
  - `type eventTarget = Any | AnyLabel(string) | App | Window(string) | Webview(string) | WebviewWindow(string)`
  - `type t<'payload>`
  - `type unlisten = unit => unit`
  - `let make: (~name, ~decode) => t<'payload>`
  - `let listen: (t<'payload>, event<'payload> => unit) => promise<unlisten>`
  - `let once: (t<'payload>, event<'payload> => unit) => promise<unlisten>`
  - `let emit: (t<'payload>, 'payload) => promise<unit>`
  - `let emitTo: (t<'payload>, ~target, 'payload) => promise<unit>`
- `tests/event_signature.res`: 型レベル
- `tests/runtime/event.test.mjs`: 4-5 ケース

### 対象外

- `Event.Predefined` (PRD Story 2-2): `closeRequested` などの 7 種定義は `Dpi.PhysicalSize / PhysicalPosition` 型に依存するため、Dpi モジュール実装後の別ステアリング (013.5 想定) で対応
- `Window` モジュールとの統合 (Window 実装ステアリングで)

## 派生決定

| 論点 | 採用 |
|---|---|
| `event<'payload>` 内の `windowLabel?` | RFC §3.1 にあるが Tauri 2.x の `Event<T>` には実は `windowLabel` がない（`event`, `id`, `payload` のみ）。RFC の記述は更新が必要だが、本 steering では Tauri 実装に合わせて `windowLabel` を含めない |
| decode 失敗時の listen / once 挙動 | silently drop（Channel と同じ方針）|
| `eventTarget` の JS 表現 | Tauri 2.x の型定義に従い `{ kind: "Any" }` / `{ kind: "AnyLabel", label }` 等 (PascalCase kind) |
| Tauri docs URL | `https://v2.tauri.app/develop/calling-frontend/#event-system` (overview) + `https://v2.tauri.app/reference/javascript/api/namespaceevent/` (per function) |
| worktree 名 | `event-module` |

## 受け入れ条件

- [ ] `Event.{make, listen, once, emit, emitTo}` 実装、build warning ゼロ
- [ ] `event<'payload>`, `eventTarget`, `unlisten` 型公開
- [ ] 型レベルテスト全公開シンボル参照
- [ ] vitest 4-5 ケース pass
- [ ] doc comment に Tauri 公式 URL を含む
