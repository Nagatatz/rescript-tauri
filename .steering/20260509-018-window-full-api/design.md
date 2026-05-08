# Design: Window 全 API 展開

## ファイル構成

`packages/core/src/Window.res` / `Window.resi` のみを拡張する。Dpi / Image との結合は polymorphic 型または `JSON.t` 経由で疎結合にし、後続 steering で型を厳格化する。

## 公開型の拡張

```rescript
type t  // opaque

type theme = [#light | #dark]

type userAttentionType = [#critical | #informational]

type cursorIcon = [
  | #default | #crosshair | #hand | #arrow | #move | #text | #wait | #help
  | #progress | #notAllowed | #contextMenu | #cell | #verticalText
  | #alias | #copy | #noDrop | #grab | #grabbing | #allScroll | #zoomIn | #zoomOut
  | #eResize | #nResize | #neResize | #nwResize | #sResize | #seResize | #swResize | #wResize
  | #ewResize | #nsResize | #neswResize | #nwseResize | #colResize | #rowResize
]

type resizeDirection = [
  | #East | #North | #NorthEast | #NorthWest
  | #South | #SouthEast | #SouthWest | #West
]

type titleBarStyle = [#visible | #transparent | #overlay]

type progressBarStatus = [#none | #normal | #indeterminate | #paused | #error]

type progressBarState = {
  status?: progressBarStatus,
  progress?: int,
}

type windowSizeConstraints = {
  minWidth?: float,
  minHeight?: float,
  maxWidth?: float,
  maxHeight?: float,
}

type closeRequestedEvent = {
  preventDefault: unit => unit,
  isPreventDefault: unit => bool,
}

type scaleFactorChanged = {
  scaleFactor: float,
  size: 'a,  // PhysicalSize, polymorphic until Dpi lands
} constraint 'a = 'b

type monitor = {
  name: Nullable.t<string>,
  size: 'size,
  position: 'position,
  scaleFactor: float,
}

// effects / color は upstream で record 型のため、公開しつつ polymorphic 引数で受ける
type color = {r: int, g: int, b: int, a: int}

type effectStyle = [
  | #appearanceBased | #blur | #acrylic | #vibrancy | #mica | #tabbed
  | #tabbedDark | #tabbedLight | #titlebar | #selection | #menu | #popover
  | #sidebar | #headerView | #sheet | #windowBackground | #hudWindow
  | #fullScreenUI | #toolTip | #contentBackground | #underWindowBackground
  | #underPageBackground
]
type effectState = [#followsWindowActiveState | #active | #inactive]
type effects = {
  effects: array<effectStyle>,
  state?: effectState,
  radius?: float,
  color?: color,
}
```

## 公開関数の拡張一覧

### 静的 (module-level)

| 関数 | バインド方式 | 備考 |
|---|---|---|
| `getCurrent: unit => t` | `@scope("Window")` | 既存 |
| `getAll: unit => array<t>` | `@scope("Window")` | 既存 |
| `getByLabel: string => promise<Nullable.t<t>>` | `@scope("Window")` | 既存 |
| `getFocusedWindow: unit => promise<Nullable.t<t>>` | `@scope("Window")` | 新規 |
| `currentMonitor: unit => promise<Nullable.t<monitor>>` | `@module` | 新規 |
| `primaryMonitor: unit => promise<Nullable.t<monitor>>` | `@module` | 新規 |
| `monitorFromPoint: (float, float) => promise<Nullable.t<monitor>>` | `@module` | 新規 |
| `availableMonitors: unit => promise<array<monitor>>` | `@module` | 新規 |
| `cursorPosition: unit => promise<'position>` | `@module` | 新規 (PhysicalPosition; Dpi 確定後に厳格化) |

### インスタンス getter (`@get` または `@send`)

| 関数 | 備考 |
|---|---|
| `label`, `setTitle`, `title`, `close`, `destroy`, `show`, `hide`, `isVisible`, `minimize`, `maximize`, `unmaximize`, `isMaximized`, `isMinimized`, `setFocus`, `isFocused`, `setSize`, `setPosition`, `center`, `setFullscreen`, `setResizable`, `setAlwaysOnTop` | 既存 |
| `setAlwaysOnBottom: (t, bool) => promise<unit>` | 新規 |
| `isFullscreen: t => promise<bool>` | 新規 |
| `isDecorated: t => promise<bool>` | 新規 |
| `isResizable: t => promise<bool>` | 新規 |
| `isMaximizable: t => promise<bool>` | 新規 |
| `isMinimizable: t => promise<bool>` | 新規 |
| `isClosable: t => promise<bool>` | 新規 |
| `isAlwaysOnTop: t => promise<bool>` | 新規 |
| `isEnabled: t => promise<bool>` | 新規 |
| `setEnabled: (t, bool) => promise<unit>` | 新規 |
| `setMaximizable / setMinimizable / setClosable: (t, bool) => promise<unit>` | 新規 |
| `setDecorations: (t, bool) => promise<unit>` | 新規 |
| `setShadow: (t, bool) => promise<unit>` | 新規 |
| `setEffects: (t, effects) => promise<unit>` | 新規 |
| `clearEffects: t => promise<unit>` | 新規 |
| `setContentProtected: (t, bool) => promise<unit>` | 新規 |
| `setMinSize: (t, Nullable.t<'size>) => promise<unit>` | 新規 |
| `setMaxSize: (t, Nullable.t<'size>) => promise<unit>` | 新規 |
| `setSizeConstraints: (t, Nullable.t<windowSizeConstraints>) => promise<unit>` | 新規 |
| `setIcon: (t, 'icon) => promise<unit>` | 新規 (Image 型統合は steering 022 で) |
| `setSkipTaskbar: (t, bool) => promise<unit>` | 新規 |
| `setBackgroundColor: (t, color) => promise<unit>` | 新規 |
| `setIgnoreCursorEvents: (t, bool) => promise<unit>` | 新規 |
| `setCursorIcon: (t, cursorIcon) => promise<unit>` | 新規 |
| `setCursorVisible: (t, bool) => promise<unit>` | 新規 |
| `setCursorGrab: (t, bool) => promise<unit>` | 新規 |
| `setCursorPosition: (t, 'position) => promise<unit>` | 新規 |
| `startDragging: t => promise<unit>` | 新規 |
| `startResizeDragging: (t, resizeDirection) => promise<unit>` | 新規 |
| `requestUserAttention: (t, Nullable.t<userAttentionType>) => promise<unit>` | 新規 |
| `setBadgeCount: (t, ~count: int=?) => promise<unit>` | 新規 |
| `setBadgeLabel: (t, ~label: string=?) => promise<unit>` | 新規 |
| `setOverlayIcon: (t, ~icon: 'icon=?) => promise<unit>` | 新規 |
| `setProgressBar: (t, progressBarState) => promise<unit>` | 新規 |
| `setVisibleOnAllWorkspaces: (t, bool) => promise<unit>` | 新規 |
| `setTitleBarStyle: (t, titleBarStyle) => promise<unit>` | 新規 |
| `setTheme: (t, Nullable.t<theme>) => promise<unit>` | 新規 |
| `theme: t => promise<Nullable.t<theme>>` | 新規 |
| `userTheme: t => promise<Nullable.t<theme>>` | 新規 (= upstream `theme()`) — alias |
| `scaleFactor: t => promise<float>` | 新規 |
| `innerSize / outerSize: t => promise<'size>` | 新規 |
| `innerPosition / outerPosition: t => promise<'position>` | 新規 |

### `on*` ハンドラ

すべて `(t, callback) => promise<Event.unlisten>` のシグネチャ。

- `onResized: (t, 'size => unit) => promise<Event.unlisten>` (PhysicalSize)
- `onMoved: (t, 'position => unit) => promise<Event.unlisten>`
- `onCloseRequested: (t, closeRequestedEvent => unit) => promise<Event.unlisten>`
- `onFocusChanged: (t, bool => unit) => promise<Event.unlisten>`
- `onScaleChanged: (t, scaleFactorChanged => unit) => promise<Event.unlisten>`
- `onThemeChanged: (t, theme => unit) => promise<Event.unlisten>`

`Event.unlisten` を再利用するため、`Event` モジュールから `unlisten` 型を `module type of` 風に流用する。実装簡略化のため `type unlisten = unit => unit` を `Window` モジュール内で再宣言する（型同一性は Tauri JS API レベルで `() => void` として固定なので問題なし）。

## 実装方針

- すべて `@send` で薄くバインド。upstream の callback は raw 値を受け取るため、`onResized` 等は raw event の `.payload` を取り出して callback に渡すラッパーを ReScript 側に挟む。
- `setSize` / `setPosition` / `cursorPosition` の引数戻り値は polymorphic にし、Dpi 実装後 (steering 019) で具象型に置き換え。
- `setBadgeCount`, `setBadgeLabel`, `setOverlayIcon` は upstream で引数 optional のため `~count: int=?` 等の labeled-optional に。
- `theme()` は `Promise<Theme | null>` のため `Nullable.t<theme>` を返す。
- `requestUserAttention(null)` でクリアできるため `Nullable.t<userAttentionType>` を引数に取る。
- `effects.color` は record。`effects: {...}` を直接 `@send` で渡す。

## テスト

- `tests/window_signature.res` を Phase 1 全公開シンボル網羅に書き直す（型レベル参照のみで OK）。
- `tests/runtime/window.test.mjs` は既存の `Mocks.mockWindows` を使う構造を維持し、新規追加 API のうち mock しやすい一部だけを smoke test。すべてのメソッドの runtime 検証は不要（PRD § 5.2 の budget を超える）。

## ロールバック計画

`.resi` の追加分は型レベル拡張のみ（既存型・既存関数のシグネチャは不変）なので、不具合が出ても追加分のみ revert で戻せる。
