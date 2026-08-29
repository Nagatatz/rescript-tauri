# Design: Webview / WebviewWindow モジュール

## 配置

```
packages/core/src/
├── Webview.res / .resi
└── WebviewWindow.res / .resi
```

`WebviewWindow` は `Webview` + `Window` の合成ビューであり、JS では同一クラスインスタンス。ReScript 側では `%identity` で 0-cost にビューを切り替える設計とする (functional-design §2.4)。

## 主要設計判断

### 1. opaque type + `%identity`

```rescript
// WebviewWindow.resi
type t
external asWindow: t => Window.t = "%identity"
external asWebview: t => Webview.t = "%identity"
```

`Window.t` / `Webview.t` も既に opaque なので、ReScript の型は別物に見えるが JS ランタイムでは同じインスタンスである。重複メソッド (`setTitle` 等) は `WebviewWindow` でも `@send` で再エクスポートし、頻用パスは cast 不要にする。

### 2. `dragDropEvent` variant

upstream の `DragDropEvent` は discriminated union (`type: 'enter' | 'over' | 'drop' | 'leave'`)。これを ReScript の variant に変換するラッパを `_onDragDropEvent` 経由で挟む。

```rescript
type dragDropEvent<'pos> =
  | Enter({paths: array<string>, position: 'pos})
  | Over({position: 'pos})
  | Drop({paths: array<string>, position: 'pos})
  | Leave
```

`'pos` は `Dpi.PhysicalPosition.t` の wire 形 `{x, y}`。`Dpi` 統合が steering 023 で完成したら型を厳格化。

### 3. setBackgroundColor の Nullable

upstream は `Color | null` を受ける。`Window` モジュールの色定義 (`Window.color`) を再利用し、`Nullable.t<Window.color>` で公開。

### 4. options 型の再設計

`WebviewWindow.options` は upstream で `Omit<WebviewOptions, 'x' | 'y' | 'width' | 'height'> & WindowOptions` だが、ReScript には Omit がないため新規 record として手で書く。`Webview.options` も別途定義。

## テスト

`tests/webview_signature.res` / `tests/webview_window_signature.res` で型レベル網羅。runtime テストは現段階で省略 (happy-dom では mock が複雑、PRD §5.2 の budget 配慮)。

## CI 影響

公開シンボル 225/219 でカバレッジ達成。doc-link-lint は両 `.resi` に Tauri URL を多数含むので OK。
