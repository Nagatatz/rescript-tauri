# Steering 057: Design — Common モジュール抽出

## 1. モジュール構成

### 1.1 新設: `packages/core/src/Common.res(i)`

```rescript
// Common.resi
/** Cross-cutting types shared by Window / Webview / WebviewWindow / Event.

    These types appear in multiple Tauri JS namespaces (window, webview,
    webviewWindow, event) with identical shapes. Centralizing them here
    eliminates duplication and avoids the artificial Window↔Webview
    dependency that arose when `color` lived under `Window`.

    See: https://v2.tauri.app/reference/javascript/api/
*/

/** Returned by `on*` event handlers across Window / Webview / Event —
    call it to detach the listener.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#unlistenfn
*/
type unlisten = unit => unit

/** RGBA color used by `setBackgroundColor` (Window / Webview /
    WebviewWindow) and `effects.color` (Window).

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#color
*/
type color = {r: int, g: int, b: int, a: int}

/** Drag-and-drop lifecycle event. Delivered by both
    `Window.onDragDropEvent` and `Webview.onDragDropEvent`; the OS
    decides which surface receives the event but the payload shape is
    identical.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#dragdropevent
*/
type dragDropEvent =
  | Enter({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Over({position: Dpi.PhysicalPosition.t})
  | Drop({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Leave
```

```rescript
// Common.res
type unlisten = unit => unit

type color = {r: int, g: int, b: int, a: int}

type dragDropEvent =
  | Enter({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Over({position: Dpi.PhysicalPosition.t})
  | Drop({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Leave

/** Internal: decode a raw drag-drop event payload (`{type, paths?,
    position}`) and dispatch it to the user handler. Shared by
    `Window.onDragDropEvent` and `Webview.onDragDropEvent`. */
let decodeDragDropEvent = (raw, handler) => {
  let payload = (Obj.magic(raw): {..})["payload"]
  let kind: string = payload["type"]
  let position: Dpi.PhysicalPosition.t = Obj.magic(payload["position"])
  switch kind {
  | "enter" => handler(Enter({paths: payload["paths"], position}))
  | "over" => handler(Over({position: position}))
  | "drop" => handler(Drop({paths: payload["paths"], position}))
  | "leave" => handler(Leave)
  | other => Console.warn2("[rescript-tauri] Unknown drag-drop event type:", other)
  }
}
```

`decodeDragDropEvent` は `.resi` で公開しない (内部ヘルパ)。`.res` のみに置く。

### 1.2 改修: `Window.res(i)`

- `type unlisten` を削除し、`Common.unlisten` を参照
- `type color` を削除し、`Common.color` を参照
- `type dragDropEvent` を削除し、`Common.dragDropEvent` を参照
- 末尾の workaround コメント (`// Same payload shape as Webview.dragDropEvent...`) を削除
- `let onDragDropEvent` の本体を `Common.decodeDragDropEvent` で置換

`.res` 側の差分例:

```rescript
// before
type unlisten = unit => unit
type color = {r: int, g: int, b: int, a: int}
// ...
type dragDropEvent =
  | Enter({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | ...

// after
type unlisten = Common.unlisten
type color = Common.color
// (色の type alias は Window.options などの record 型注釈互換のため残す)
type dragDropEvent = Common.dragDropEvent
```

#### 設計判断: type alias を残すか

`Window.color` / `Window.dragDropEvent` を**完全に削除**する破壊的変更とするか、それとも `type color = Common.color` のように type alias を残すか。

**判断: 完全削除する** (alias は残さない)。

理由:
- pre-release のため shim 不要
- alias を残すと「どっちで参照すべきか」が曖昧になり、命名規則違反 (`feedback_pre_release_no_compat.md` メモリ参照) を招く
- 利用箇所 (内部 signature テスト + WebviewWindow) はすべて自前で更新可能

ただし `record 型 + ?:optional フィールド` で `color` を引いている箇所 (`Window.options.backgroundColor?: color` 等) はそのまま `Common.color` に置換する。

### 1.3 改修: `Webview.res(i)`

- `type unlisten` 削除 → `Common.unlisten` 参照
- `type dragDropEvent` 削除 → `Common.dragDropEvent` 参照
- `Webview.options.backgroundColor` / `Webview.setBackgroundColor` の型を `Common.color` に変更
- `let onDragDropEvent` の本体を `Common.decodeDragDropEvent` で置換

これにより `Webview` から `Window` への依存が完全に消える。

### 1.4 改修: `Event.res(i)`

- `type unlisten` 削除 → `Common.unlisten` 参照
- 他は変更なし

### 1.5 改修: `WebviewWindow.res(i)`

- `WebviewWindow.options.backgroundColor` / `WebviewWindow.setBackgroundColor` の型を `Common.color` に変更
- `WebviewWindow.options.theme` / `titleBarStyle` / `parent` は `Window.theme` 等を引き続き参照 (これらは Window 固有の型で Common に上げない)

### 1.6 改修: `Tauri.res(i)`

```rescript
module Common = Common  // 追加
module Core = Core
module Event = Event
module Window = Window
module Webview = Webview
module WebviewWindow = WebviewWindow
```

`.resi` の docstring も「`Common` も `open Tauri` で利用可能」旨に更新。

### 1.7 改修: signature テスト

- `tests/window_signature.res`: `Window.color` → `Common.color`、`Window.unlisten` → `Common.unlisten`、`Window.dragDropEvent` → `Common.dragDropEvent`
- `tests/webview_signature.res`: 同様
- `tests/webview_window_signature.res`: `Window.color` → `Common.color`
- 新規 `tests/common_signature.res`: `Common.unlisten` / `Common.color` / `Common.dragDropEvent` の型レベル検証

## 2. 依存関係

変更後の依存方向:

```
Common (depends on Dpi only)
  ↑
  ├─ Event
  ├─ Window
  ├─ Webview
  └─ WebviewWindow (depends on Window for theme/titleBarStyle, on Webview options indirectly)
Tauri (umbrella; re-exports Common + 5 modules)
```

`Common` は `Dpi.PhysicalPosition` のみに依存する。`Common` から `Window` / `Webview` への参照は **作らない**。

## 3. ビルド順序

ReScript の namespace 機能 (`"namespace": true`) によりファイル名から module が自動解決される。`Common.res` を `src/` に追加するだけで他のモジュールから `Common` 名で参照可能。

## 4. テスト戦略

| レイヤ | テスト | 期待 |
|---|---|---|
| 型レベル | `common_signature.res` 新規 | `Common` の型シグネチャを固定 |
| 型レベル | 既存 4 ファイル更新 | リネーム箇所のみ修正 |
| runtime | `webview.test.mjs` / `window.test.mjs` | 変更不要 (生成 JS が等価) |
| integration | `pnpm --recursive build/test` | 全パス |

`runtime` 側のテストは ReScript が生成する JS のみを呼び出しているため、型レベルのリネームだけでは破綻しない。ただし念のため `webview.test.mjs` 内の `dragDropEvent` decode 経路はビルド後に再確認する。

## 5. 影響を受けるファイル一覧

```
新規:
  packages/core/src/Common.res
  packages/core/src/Common.resi
  packages/core/tests/common_signature.res

修正:
  packages/core/src/Window.res
  packages/core/src/Window.resi
  packages/core/src/Webview.res
  packages/core/src/Webview.resi
  packages/core/src/WebviewWindow.res
  packages/core/src/WebviewWindow.resi
  packages/core/src/Event.res
  packages/core/src/Event.resi
  packages/core/src/Tauri.res
  packages/core/src/Tauri.resi
  packages/core/tests/window_signature.res
  packages/core/tests/webview_signature.res
  packages/core/tests/webview_window_signature.res
  packages/core/tests/tauri_signature.res (Tauri.Common 検証行を追加)
  packages/core/README.md (umbrella 一覧に Common 追記、軽微)

ドキュメント (必要に応じて):
  docs/repository-structure.md (Common.res(i) を core/ ファイル一覧に追記)
  docs/functional-design.md (該当箇所があれば追記)
```

## 6. リスクと緩和策

| リスク | 緩和策 |
|---|---|
| `Obj.magic` 周りで型推論が変わって既存 runtime コードが壊れる | runtime テスト (`webview.test.mjs` の drag-drop ブロック / `window.test.mjs:289`) で検証 |
| 公開 type の rename を漏らして他の package がビルド失敗 | `pnpm --recursive build` を全 package で実行する CI と同等チェックをローカルで通す |
| `Tauri.Common` の re-export で循環参照 | `Common` 自体が `Tauri` に依存しないので発生しない |
| coverage threshold 抵触 | 元々 100% に近く、今回の変更は実装行が純減するので問題なし。最終確認は `pnpm --filter @rescript-tauri/core test:coverage` |

## 7. 設計外注 / 関連メモリ

- `feedback_pre_release_no_compat.md`: pre-release のため互換 shim を入れない方針
- `feedback_git_mv_then_edit.md`: ファイル移動を伴わないので該当しない
