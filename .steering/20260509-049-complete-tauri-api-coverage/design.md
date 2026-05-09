# 設計: @tauri-apps/api 完全カバレッジ達成

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-049-complete-tauri-api-coverage` |
| 作成日 | 2026-05-09 |
| 関連 | `requirements.md` |

## 1. 全体方針

各モジュールごとに既存の命名・スタイルを踏襲し、**最小差分**で追加する。すべての追加 API は `.resi` 側に Tauri 公式 URL リンク付き doc comment を必須化（`code-comments.md` 規約）。

## 2. モジュール別設計

### 2.1 Core

#### `Resource` 抽象基底

ReScript ではクラス継承を使わず、共通インターフェースを `Resource` モジュールに集約する。`Image.t` は内部的に Resource を継承するが、ReScript 側では opaque 型として独立させ、必要なら `Image.t` から `Resource.t` へキャストできる API を将来検討（本作業では追加しない）。

```rescript
// Core.resi
module Resource: {
  /** Resource handle base. Subtypes: Image.t, Channel.t (internal). */
  type t

  /** Tauri-side resource id. */
  let rid: t => int

  /** Destroys the resource on the Rust side. */
  let close: t => promise<unit>
}
```

```rescript
// Core.res
module Resource = {
  type t
  @get external rid: t => int = "rid"
  @send external close: t => promise<unit> = "close"
}
```

#### `PluginListener` クラス

```rescript
// Core.resi
module PluginListener: {
  type t

  /** Plugin name. */
  let plugin: t => string

  /** Event name. */
  let event: t => string

  /** Channel id used by Tauri to dispatch this event. */
  let channelId: t => int

  /** Stops listening. Idempotent. */
  let unregister: t => promise<unit>
}
```

#### `addPluginListener`

```rescript
// Core.resi
let addPluginListener: (
  ~plugin: string,
  ~event: string,
  ~callback: 'payload => unit,
) => promise<PluginListener.t>
```

#### Permission API

```rescript
// Core.resi
type permissionState = [#granted | #denied | #prompt | #"prompt-with-rationale"]

let checkPermissions: string => promise<'state>
let requestPermissions: string => promise<'state>
```

戻り値はプラグインごとに型が異なるため `'state` 多相。`permissionState` は値レベルで使うことが多いシナリオ向け。

#### `isTauri`

```rescript
let isTauri: unit => bool
```

#### `transformCallback` / `SERIALIZE_TO_IPC_FN`

Internal-leaning だが公開されているため最低限のバインディングを `Core.Internal` 配下ではなく `Core.LowLevel` 配下に配置し、利用シーンが内部寄りであることを明示。

```rescript
// Core.resi
module LowLevel: {
  /** IPC custom serialization key (a string used as a JS Symbol-ish identifier
      via class methods like `[SERIALIZE_TO_IPC_FN]() {...}`). */
  let serializeToIpcFn: string

  /** Stores `callback` and returns a numeric id usable in IPC payloads. */
  let transformCallback: (~callback: 'response => unit=?, ~once: bool=?) => int
}
```

### 2.2 App

```rescript
// App.resi
type dataStoreIdentifier = array<int>

type bundleType = [#nsis | #msi | #deb | #rpm | #appimage | #app]

type onBackButtonPressPayload = {canGoBack: bool}

let fetchDataStoreIdentifiers: unit => promise<array<dataStoreIdentifier>>
let removeDataStore: dataStoreIdentifier => promise<unit>
let getBundleType: unit => promise<bundleType>
let onBackButtonPress: (
  onBackButtonPressPayload => unit,
) => promise<Core.PluginListener.t>
let supportsMultipleWindows: unit => promise<bool>
```

`DataStoreIdentifier` は TS 上で長さ 16 のタプル型だが、ReScript 側では `array<int>` として扱う（同等のランタイム表現）。

`BundleType` は文字列リテラル enum なので polymorphic variant にマップ。

冒頭の deferred コメントを更新する。

### 2.3 Window

すべて `Window.resi` 末尾に追記する。

```rescript
let activityName: t => promise<string>
let sceneIdentifier: t => promise<string>
let setFocusable: (t, bool) => promise<unit>
let setSimpleFullscreen: (t, bool) => promise<unit>
let toggleMaximize: t => promise<unit>
let unminimize: t => promise<unit>
let onDragDropEvent: (t, Webview.dragDropEvent => unit) => promise<unlisten>
```

`onDragDropEvent` は `Webview.dragDropEvent` を再利用する（`Window` と `Webview` で同じイベントペイロード）。

### 2.4 Webview

```rescript
let clearAllBrowsingData: t => promise<unit>
let getByLabel: string => promise<Nullable.t<t>>
```

### 2.5 Event

```rescript
type tauriEvent = [
  | #"tauri://resize"
  | #"tauri://move"
  | #"tauri://close-requested"
  | #"tauri://destroyed"
  | #"tauri://focus"
  | #"tauri://blur"
  | #"tauri://scale-change"
  | #"tauri://theme-changed"
  | #"tauri://window-created"
  | #"tauri://suspended"
  | #"tauri://resumed"
  | #"tauri://webview-created"
  | #"tauri://drag-enter"
  | #"tauri://drag-over"
  | #"tauri://drag-drop"
  | #"tauri://drag-leave"
]

/** Predefined Tauri event names re-exported as values for convenience. */
module TauriEvent: {
  let windowResized: tauriEvent
  let windowMoved: tauriEvent
  // ...
}
```

`listen` / `once` に `~target` オプションを追加:

```rescript
let listen: (
  t<'payload>,
  result<event<'payload>, string> => unit,
  ~target: eventTarget=?,
) => promise<unlisten>

let once: (
  t<'payload>,
  result<event<'payload>, string> => unit,
  ~target: eventTarget=?,
) => promise<unlisten>
```

### 2.6 Mocks

```rescript
type mockIPCOptions = {shouldMockEvents?: bool}

// 既存:
// let mockIPC: ((string, JSON.t) => promise<JSON.t>) => unit

// 拡張:
let mockIPC: (
  (string, JSON.t) => promise<JSON.t>,
  ~options: mockIPCOptions=?,
) => unit

/** Mocks `convertFileSrc` for the specified OS.
    `~osName` accepts `"linux"`, `"macos"`, or `"windows"`. */
let mockConvertFileSrc: (~osName: string) => unit
```

既存 `mockIPC` 呼び出し箇所の互換性: ラベル付き optional 引数の追加は無破壊。

### 2.7 Menu

```rescript
/** macOS-only system icon names. Use as the `icon` field of
    `IconMenuItem.options` or `Submenu.options`. */
type nativeIcon = [
  | #Add
  | #Advanced
  | #Bluetooth
  // ... 60+ variants
]
```

ファイルレベル `type nativeIcon` として `Menu.resi` 上部に配置。

### 2.8 Image

`transformImage` は API 不安定のため未対応。

## 3. テスト戦略

### 3.1 型レベル

- 既存 `*_signature.res` ファイルがある場合はそこに追記、無ければ新規作成。
- 各新規関数は最低 1 回呼び出して型推論を確認。

### 3.2 ランタイム (vitest)

- `core_*.test.mjs`:
  - `isTauri()` が `false` を返すこと（vitest は Tauri 環境ではない）。
  - `mockIPC` 経由で `addPluginListener` の cmd 名 (`plugin:<plugin>|registerListener`) を確認。
  - `Resource.close()` が `mockIPC` 経由で `plugin:resources|close` 等を呼ぶこと。
- `app.test.mjs`:
  - `mockIPC` で `plugin:app|*` 系コマンドが正しい引数で呼ばれること。
  - `getBundleType` のレスポンスが polymorphic variant にマップされること。
- `window.test.mjs`:
  - 新規メソッド呼び出し時に `mockIPC` が期待する cmd を受信すること。
- `mocks.test.mjs`:
  - `mockConvertFileSrc("windows")` 後に `Core.Raw.convertFileSrc("C:\\path")` が Windows-style URL を返すこと。

## 4. ドキュメント更新

- `docs/repository-structure.md`: 該当する場合カバレッジ完了の記述を反映。
- `README.md` (root): "API Coverage" セクションを 100% に更新。
- `sphinx-docs/dev/architecture.md`: 同様。
- 各モジュールの `README.md` (`packages/core/README.md`): 新規 API を Features に追記。

## 5. 影響範囲

- `packages/core/src/Core.res` / `.resi`
- `packages/core/src/App.res` / `.resi`
- `packages/core/src/Window.res` / `.resi`
- `packages/core/src/Webview.res` / `.resi`
- `packages/core/src/Event.res` / `.resi`
- `packages/core/src/Mocks.res` / `.resi`
- `packages/core/src/Menu.res` / `.resi`
- `packages/core/tests/` 配下のテスト（追加）
- `packages/core/tests/runtime/` 配下のテスト（追加）
- ドキュメント数点

他パッケージ (`plugin-fs` / `plugin-dialog` / `schema`) は影響なし（peer dep のため `@rescript-tauri/core` の追加 API はそのまま利用可能）。
