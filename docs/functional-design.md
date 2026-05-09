# 機能設計書 (Functional Design Document)

| 項目 | 内容 |
|---|---|
| プロダクト | `@rescript-tauri/core` および周辺パッケージ群 |
| 対象 | Phase 1（コアバインディング初期リリース） |
| 作成日 | 2026-05-08 |
| 関連 PRD | [docs/product-requirements.md](./product-requirements.md) |
| 関連 RFC | [docs/ideas/RFC-0001-core-api-design.md](./ideas/RFC-0001-core-api-design.md) |
| ステータス | Confirmed (Phase 1+2 merged, awaiting first publish) |

> 本書は PRD の機能要件を「何を」「どのモジュールで」「どんな型で」提供するかに落としたもの。実装方針・型シグネチャ・ファイル配置・テスト方針までを定義し、各モジュール実装時の指針とする。アーキテクチャ寄りの判断は `docs/architecture.md`、リポジトリ物理構造は `docs/repository-structure.md` を参照。

---

## 1. 全体アーキテクチャ

### 1.1 配置と責務

```
rescript-tauri/                       # monorepo root
├── packages/
│   ├── core/                         # @rescript-tauri/core (本書スコープ)
│   │   ├── src/
│   │   │   ├── Core.res / .resi      # invoke / convertFileSrc / Channel / Command
│   │   │   ├── Event.res / .resi     # listen / once / emit / TauriEvent
│   │   │   ├── Window.res / .resi
│   │   │   ├── Webview.res / .resi
│   │   │   ├── WebviewWindow.res / .resi
│   │   │   ├── Path.res / .resi
│   │   │   ├── App.res / .resi
│   │   │   ├── Dpi.res / .resi
│   │   │   ├── Menu.res / .resi
│   │   │   ├── Tray.res / .resi
│   │   │   ├── Image.res / .resi
│   │   │   ├── Mocks.res / .resi
│   │   │   └── Tauri.res / .resi     # 上位 re-export
│   │   ├── tests/                    # 型レベルテスト + vitest 実行テスト
│   │   ├── rescript.json
│   │   └── package.json
│   ├── plugin-fs/                    # Phase 2+
│   ├── plugin-dialog/                # Phase 2+
│   └── schema/                       # Phase 2 (@rescript-tauri/schema)
├── examples/
│   ├── hello-world/                  # Phase 1 必須
│   ├── window-management/
│   ├── ipc-typed/
│   ├── streaming-ipc/
│   ├── plugin-fs-demo/               # Phase 2
│   ├── plugin-dialog-demo/           # Phase 2
│   └── ipc-typed-with-schema/        # Phase 2 (Layer 3 demo)
└── docs/
```

### 1.2 レイヤー構造（IPC）

```
┌──────────────────────────────────────────────┐
│  Layer 3: @rescript-tauri/schema             │  Phase 2
│   └─ Command.fromSchemas(~name, ~args, ~result)
├──────────────────────────────────────────────┤
│  Layer 2: Core.Command                       │  Phase 1
│   └─ make / invoke / invokeExn
├──────────────────────────────────────────────┤
│  Layer 1: Core.Raw                           │  Phase 1
│   └─ invoke / convertFileSrc
└──────────────────────────────────────────────┘
            ↓ JS bridge
   @tauri-apps/api/core (上流)
```

**設計原則:**
1. Layer 1 は JS API 表面と 1:1。署名・引数順を変更しない。
2. Layer 2 は Layer 1 の上にしか依存しない（逆依存禁止）。
3. Layer 3 は別パッケージ。Layer 2 のシグネチャを安定 API として依存する。

### 1.3 依存方針

- `peerDependencies`: `@tauri-apps/api ^2.0.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`（1.6.0+ peerDep `rescript >=11.1.0` が ReScript 12.x もカバー）。
- `dependencies`: なし（ピアのみ）。
- `devDependencies`: `vitest`, `happy-dom`, `@types/node`（テスト用）。

---

## 2. モジュール別機能設計

### 2.1 `Core` モジュール（`Core.res` / `Core.resi`）

#### 2.1.1 責務
- Tauri IPC bridge のすべてのエントリポイント。
- 3 つのサブモジュール: `Raw`, `Command`, `Channel`。
- ファイル URL 変換 (`convertFileSrc`)。

#### 2.1.2 公開シグネチャ（抜粋）

```rescript
// Core.resi

module Raw: {
  type invokeOptions = {headers?: Dict.t<string>}

  /** Calls a Tauri command on the Rust backend.
      See: https://v2.tauri.app/develop/calling-rust/ */
  let invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result>

  /** Converts a file path into a URL accessible by the webview.
      See: https://v2.tauri.app/reference/javascript/api/namespacecore/#convertfilesrc */
  let convertFileSrc: (string, ~protocol: string=?) => string
}

type invokeError =
  | DecodeError(string)
  | RustError(JSON.t)

module Command: {
  type t<'args, 'result>

  let make: (
    ~name: string,
    ~encodeArgs: 'args => JSON.t,
    ~decodeResult: JSON.t => result<'result, string>,
  ) => t<'args, 'result>

  let invoke: (
    t<'args, 'result>,
    'args,
    ~options: Raw.invokeOptions=?,
  ) => promise<result<'result, invokeError>>

  let invokeExn: (
    t<'args, 'result>,
    'args,
    ~options: Raw.invokeOptions=?,
  ) => promise<'result>
}

module Channel: {
  type t<'message>

  let make: (~decode: JSON.t => result<'message, string>) => t<'message>
  let onMessage: (t<'message>, 'message => unit) => unit
  let id: t<'message> => int
}
```

#### 2.1.3 実装方針
- `Raw.invoke`: `@module("@tauri-apps/api/core") external invoke` で薄くバインド。
- `Command.make` / `invoke`:
  1. `encodeArgs(args)` で `JSON.t` を作成。
  2. `Raw.invoke` を呼び、reject は `try/catch` で `RustError` に正規化。
  3. resolve 値を `decodeResult` に通し、`Error(string)` は `DecodeError` に正規化。
  4. `result` で返却。
- `Command.invokeExn`: `Command.invoke` の `result` を unwrap し、`Error` の場合は `JsError` に変換して `raise`。
- `Channel.make`: 上流 `Channel` クラスを `@new` でインスタンス化、decoder は内部に保持。

#### 2.1.4 受け入れ条件への対応

| PRD Story | 対応箇所 |
|---|---|
| 1-1 既存 invoke の最小コスト移植 | `Raw.invoke` |
| 1-2 typed Command ハンドル | `Command.make` / `invoke` / `invokeExn` |
| 1-3 schema 統合は外部パッケージ | `Command.make` の引数を `JSON.t` 入出力で固定し、外部から `S.t` ベースのラッパを書ける形に |
| 2-3 Channel | `Channel.make` / `onMessage` / `id` |

---

### 2.2 `Event` モジュール（`Event.res` / `Event.resi`）

#### 2.2.1 責務
- Tauri Event の typed handle と pub/sub API。
- ビルトインイベントの事前定義。

#### 2.2.2 公開シグネチャ

```rescript
// Event.resi

type event<'payload> = {
  event: string,
  id: int,
  payload: 'payload,
  windowLabel?: string,
}

type eventTarget =
  | Any
  | AnyLabel(string)
  | App
  | Window(string)
  | Webview(string)
  | WebviewWindow(string)

type t<'payload>
type unlisten = unit => unit

let make: (
  ~name: string,
  ~decode: JSON.t => result<'payload, string>,
) => t<'payload>

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
let emit: (t<'payload>, 'payload) => promise<unit>
let emitTo: (t<'payload>, ~target: eventTarget, 'payload) => promise<unit>

/* Predefined Tauri event names — string-level constants that callers feed
   into `Event.make(~name=..., ~decode=...)` to build a typed handle. The
   polymorphic-variant `tauriEvent` mirrors upstream `TauriEvent` exactly
   (16 values, see Event.resi). PhysicalSize / PhysicalPosition payloads
   are defined in the `Dpi` module (see §2.5). */
type tauriEvent = [
  | #"tauri://resize"
  | #"tauri://move"
  | #"tauri://close-requested"
  // ... 13 more — see packages/core/src/Event.resi
]

module TauriEvent: {
  let windowResized: tauriEvent
  let windowMoved: tauriEvent
  let windowCloseRequested: tauriEvent
  let windowDestroyed: tauriEvent
  let windowFocus: tauriEvent
  let windowBlur: tauriEvent
  let windowScaleFactorChanged: tauriEvent
  let windowThemeChanged: tauriEvent
  let windowCreated: tauriEvent
  let windowSuspended: tauriEvent
  let windowResumed: tauriEvent
  let webviewCreated: tauriEvent
  let dragEnter: tauriEvent
  let dragOver: tauriEvent
  let dragDrop: tauriEvent
  let dragLeave: tauriEvent
}
```

#### 2.2.3 実装方針
- 内部表現: `t<'payload>` は `{name: string, decode: Core.decoder<'payload>}` の opaque record。`Core.decoder<'value> = JSON.t => result<'value, string>` は Command/Channel/Event 共通の型エイリアス。
- `listen`: 上流 `listen(name, handler)` を呼び、handler 内で raw event を decode → `event<'payload>` に詰め直してユーザー callback に `Ok(event)` または `Error(msg)` として渡す。decode 失敗はサイレントドロップせず callback に surface する（呼び出し側で Ok/Error を明示的に handle する責務）。
- `emit*`: `eventTarget` を上流 JS の `EventTarget` shape (`{kind: "Window", label: ...}`) に変換する型安全なヘルパを内部に持つ（`Obj.magic` 不使用）。

#### 2.2.4 受け入れ条件への対応

| PRD Story | 対応箇所 |
|---|---|
| 2-1 typed Event ハンドル | `make` / `listen` / `once` / `emit` / `emitTo` |
| 2-2 Predefined イベント名 | `TauriEvent.*`（`tauriEvent` 文字列定数 16 種） |

---

### 2.3 `Window` モジュール（`Window.res` / `Window.resi`）

#### 2.3.1 責務
- 上流 `Window` クラスの opaque type 化と `@send` メソッド群。
- 静的メソッド (`getCurrent`, `getAll`, `getByLabel`)。

#### 2.3.2 公開シグネチャ（抜粋）

```rescript
// Window.resi

type t

type theme = [#light | #dark]

type cursorIcon = [
  | #default
  | #crosshair
  | #pointer
  | #move
  | #text
  | #wait
  | #help
  | #progress
  | #notAllowed @as("notAllowed")
  | #contextMenu @as("contextMenu")
  // ... 全 cursor 値
]

type windowOptions = {
  url?: string,
  title?: string,
  width?: float,
  height?: float,
  resizable?: bool,
  fullscreen?: bool,
  // ... Tauri 公開分すべて
}

let make: (string, ~options: windowOptions=?) => t

let getCurrent: unit => t
let getAll: unit => array<t>
let getByLabel: string => promise<Nullable.t<t>>

let label: t => string
let setTitle: (t, string) => promise<unit>
let title: t => promise<string>
let close: t => promise<unit>
let destroy: t => promise<unit>
let show: t => promise<unit>
let hide: t => promise<unit>
let minimize: t => promise<unit>
let maximize: t => promise<unit>
let unmaximize: t => promise<unit>
let isMaximized: t => promise<bool>
let setTheme: (t, theme) => promise<unit>
let setCursorIcon: (t, cursorIcon) => promise<unit>
// ... Tauri 公開メソッドすべて
```

#### 2.3.3 実装方針
- `t` は opaque（`.resi` で隠蔽）。`.res` 内では `external` のみ。
- 静的メソッドは `@module @scope("Window")`、コンストラクタは `@module @new`。
- インスタンスメソッドは `@send`。pipe-first (`win->Window.setTitle("...")`) で呼べる。
- string-literal union は polymorphic variant + `@as`。
- バインド対象範囲は **`peerDependencies` で固定する `@tauri-apps/api ^2.0.0` の `Window` クラス公開分すべて**（インスタンスメソッド・スタティックメソッド）。Tauri minor で追加された API は対応する `@rescript-tauri/core` minor で追従する。

#### 2.3.4 受け入れ条件への対応

| PRD Story | 対応箇所 |
|---|---|
| 3-1 Window opaque type | `t` + `@send` 群 |
| 4-1 polymorphic variant | `theme`, `cursorIcon` |

---

### 2.4 `Webview` / `WebviewWindow` モジュール

#### 2.4.1 責務
- `Webview` 単独クラスのバインディング。
- `WebviewWindow` は `Window` + `Webview` の合成。`%identity` キャストで再利用。

#### 2.4.2 公開シグネチャ（抜粋）

```rescript
// WebviewWindow.resi
type t

external asWindow: t => Window.t = "%identity"
external asWebview: t => Webview.t = "%identity"

let make: (string, ~options: webviewWindowOptions=?) => t
let getCurrent: unit => t
let getAll: unit => array<t>
let getByLabel: string => promise<Nullable.t<t>>

// 共通メソッドは asWindow 経由で呼ぶことを推奨
// 頻用メソッドは @send で再エクスポート
let setTitle: (t, string) => promise<unit>
```

#### 2.4.3 実装方針
- `%identity` キャストで JS 上同一オブジェクトに対する別型ビューを提供。
- 全 `Window` メソッドのコピーは作らない。「`asWindow` 経由で使う」を `.resi` ドキュメントで明示。
- 例外: `setTitle` のような頻用メソッドのみ `@send` で再宣言（discoverability 向上）。

#### 2.4.4 受け入れ条件への対応

| PRD Story | 対応箇所 |
|---|---|
| 3-2 WebviewWindow と Window の継承表現 | `asWindow` / `asWebview` |

---

### 2.5 `Path` / `App` / `Dpi` / `Image`

#### 2.5.1 責務
- ユーティリティ関数群。クラスではなく単純な関数バインディング。

#### 2.5.2 公開シグネチャ（抜粋）

```rescript
// Path.resi
let appDataDir: unit => promise<string>
let appConfigDir: unit => promise<string>
let appLocalDataDir: unit => promise<string>
let appCacheDir: unit => promise<string>
let appLogDir: unit => promise<string>
let resourceDir: unit => promise<string>
let join: array<string> => promise<string>
let normalize: string => promise<string>
// ... Tauri Path API すべて

// App.resi
let getName: unit => promise<string>
let getVersion: unit => promise<string>
let getTauriVersion: unit => promise<string>
let show: unit => promise<unit>
let hide: unit => promise<unit>

// Dpi.resi
module LogicalSize: {
  type t = {width: float, height: float}
}
module PhysicalSize: {
  type t = {width: float, height: float}
}
module LogicalPosition: {
  type t = {x: float, y: float}
}
module PhysicalPosition: {
  type t = {x: float, y: float}
}

// Image.resi
type t
let fromPath: string => promise<t>
let fromBytes: Uint8Array.t => promise<t>
let rgba: t => promise<Uint8Array.t>
let size: t => promise<PhysicalSize.t>
```

#### 2.5.3 実装方針
- 関数ベースモジュール。`@module @scope`/`@module` で外部関数バインド。
- `Image.t` は opaque。
- `Dpi` のサブモジュールは pure record 型として exposed（`%identity` でも JS 上 fine）。

---

### 2.6 `Menu` / `Tray`

#### 2.6.1 責務
- メニュー・トレイアイコンのクラス API バインディング。

#### 2.6.2 公開シグネチャ（抜粋）

```rescript
// Menu.resi
module MenuItem: {
  type t
  type options = {
    id?: string,
    text: string,
    enabled?: bool,
    accelerator?: string,
    action?: unit => unit,
  }
  let make: options => promise<t>
  let id: t => string
  let text: t => promise<string>
  let setText: (t, string) => promise<unit>
}

module Submenu: {
  type t
  type options = {
    text: string,
    enabled?: bool,
    items?: array<menuItemKind>,
  }
  and menuItemKind =
    | Item(MenuItem.t)
    | Submenu(t)
    | Predefined(predefinedMenuItemId)
  let make: options => promise<t>
}

module Menu: {
  type t
  let new_: unit => promise<t>
  let default: unit => promise<t>
  let append: (t, menuItemKind) => promise<unit>
  let setAsAppMenu: t => promise<unit>
}

// Tray.resi
module TrayIcon: {
  type t
  type options = {
    id?: string,
    icon?: Image.t,
    tooltip?: string,
    menu?: Menu.t,
    showMenuOnLeftClick?: bool,
  }
  let make: options => promise<t>
  let setIcon: (t, Image.t) => promise<unit>
  let setMenu: (t, Menu.t) => promise<unit>
  let close: t => promise<unit>
}
```

#### 2.6.3 実装方針
- 各クラスは opaque + `@send`。
- `menuItemKind` は variant で表現し、エンコード時に JS の sub-class インスタンスへマップ。

---

### 2.7 `Mocks`

#### 2.7.1 責務
- `vitest` + `happy-dom` 環境で `__TAURI_INTERNALS__` を差し替えるテスト支援。

#### 2.7.2 公開シグネチャ

```rescript
// Mocks.resi

/** Mocks the IPC layer. The handler receives the command name and args
    and should return the value the call would resolve with (or throw to reject). */
let mockIPC: ((string, JSON.t) => promise<JSON.t>) => unit

/** Mocks Tauri windows for tests that read window state. */
let mockWindows: (~current: string, ~all: array<string>=?) => unit

/** Clears all mocks installed by mockIPC / mockWindows. */
let clearMocks: unit => unit
```

#### 2.7.3 実装方針
- 上流 `@tauri-apps/api/mocks` への薄いラッパ。
- `mockIPC` の handler は ReScript 側で `JSON.t` を受け、`promise<JSON.t>` を返すシグネチャに統一。
- リリースゲート: `examples/hello-world` の vitest テストが `Mocks.mockIPC` 経由で `Core.Command.invoke` の round-trip をパスすること。`clearMocks` 呼び出し後にハンドラがリセットされていることを assertion で検証する（PRD Story 6-1）。

---

### 2.8 `Tauri` 上位 re-export

#### 2.8.1 責務
- `open Tauri` で主要モジュールにアクセスできるエントリポイント。

#### 2.8.2 シグネチャ方針

```rescript
// Tauri.resi
module Core = Core
module Event = Event
module Window = Window
module Webview = Webview
module WebviewWindow = WebviewWindow
// Path, App, Dpi 等は heavy なので open Tauri では出さない（残課題 #1）
```

`Tauri.res` 全モジュール re-export は heavy になるため、Phase 1 リリース直前に最終決定する（PRD §10 Open Question #1）。

---

## 3. 横断的設計

### 3.1 エラー設計

| エラー型 | 発生箇所 | 内容 |
|---|---|---|
| `Core.invokeError` | `Core.Command.invoke` | `DecodeError(string)` / `RustError(JSON.t)`（`RustError` の payload は JS exn を `{name, message}` JSON に正規化したもの） |
| `result<event<'payload>, string>` | `Event.listen` / `Event.once` callback | デコード失敗は `Error(decoderMessage)` として callback に渡す（サイレントドロップしない） |
| `result<'message, string>` | `Channel.onMessage` callback | 同上 |

- 共通親 union は持たない（call site の型表面を狭く保つため）。
- すべてのデコード失敗は `result<_, string>` を経由して呼び出し側に surface される（統一ポリシー）。silent-drop が望ましい呼び出し側はパターンマッチで `Error` ブランチを `_` で破棄する。
- `*Exn` 版は `result` を unwrap し、`Error` を `JsError` (`@rescript/core`) として `raise` する。

### 3.2 命名規約

- **モジュール**: PascalCase。ファイル名と一致（`Core.res`）。
- **関数**: camelCase。`*Exn` で例外版を区別。
- **型**: snake_case を使わず camelCase（ReScript 標準）。
- **variant**: 上流 JS spelling と一致させる。差異がある場合のみ `@as` 補正。
- **ブール getter**: `is*` プレフィックス（`isMaximized`）。

### 3.3 ドキュメントコメント規約

各公開シンボルに以下を含む doc comment を必須化:

```rescript
/** Sets the window's title.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#settitle

    ## Example

    ```rescript
    let win = Window.getCurrent()
    await win->Window.setTitle("Hello")
    ```

    Platform: macOS では title bar 高さに影響しない。
*/
let setTitle: (t, string) => promise<unit>
```

### 3.4 JSON 取り扱い

- `JSON.t` (`@rescript/core`) を唯一の中間表現にする。
- decoder combinator を core から提供しない。
- 標準の `JSON.Decode.*` を使ったハンドコード decoder を tests / examples で示す。

### 3.5 polymorphic variant 運用

- `.resi` では closed bound（`[#light | #dark]`）で公開し、Tauri 側の追加に追従する場合は minor bump で拡張。
- ReScript spelling と JS spelling が一致しない場合のみ `@as` で明示。

### 3.6 リソース解放方針

- `Window.t`, `WebviewWindow.t`, `Menu.t`, `TrayIcon.t` 等の native ハンドルは `close` / `destroy` の明示呼び出しが必要。
- Finalizer / WeakRef 経由の自動解放は **採用しない**（信頼性とプラットフォーム差異のため）。
- `.resi` のドキュメントで「ユーザー責務」を明示する。

---

## 4. 機能要件と実装の対応マトリクス（トレーサビリティ）

| PRD Story | 主モジュール | 主関数/型 | テスト |
|---|---|---|---|
| 1-1 Raw invoke | `Core.Raw` | `invoke`, `convertFileSrc` | `tests/core_raw.res`, vitest mockIPC |
| 1-2 typed Command | `Core.Command` | `make`, `invoke`, `invokeExn` | `tests/core_command.res`, encode/decode round-trip |
| 1-3 schema 非依存 | `Core.Command` 署名 | (`JSON.t` のみ) | `tests/core_command_no_schema.res` |
| 2-1 typed Event | `Event` | `make`, `listen`, `once`, `emit`, `emitTo` | `tests/event.res`, listen/unlisten 検証 |
| 2-2 Predefined Event 名 | `Event.TauriEvent` | `windowCloseRequested` ほか 16 種（`tauriEvent` 文字列定数） | `tests/event_signature.res` |
| 2-3 Channel | `Core.Channel` | `make`, `onMessage`, `id` | `tests/core_channel.res` |
| 3-1 Window opaque | `Window` | `t`, 全 `@send` メソッド | `tests/window.res`（型レベル） |
| 3-2 WebviewWindow 継承 | `WebviewWindow` | `asWindow`, `asWebview` | `tests/webview_window.res` |
| 3-3 主要 12 モジュール | 全モジュール | — | examples/hello-world ビルド |
| 4-1 polymorphic variant | `Window.theme` ほか | `[#light \| #dark]` | `tests/window_theme.res` |
| 5-1 result vs exn | `Core.Command` | `invoke` / `invokeExn` | `tests/core_command_error.res` |
| 6-1 Mocks | `Mocks` | `mockIPC`, `clearMocks` | `tests/mocks.res` + vitest |
| 7-1 peerDeps | `package.json` | — | publint / CI |
| 7-2 .resi 必須 | 全モジュール | — | CI: `find src -name '*.res' \| while read f; do test -f "${f}i"; done` |
| 7-3 monorepo 分離 | リポジトリ全体 | — | examples の publish 想定 dry run |

---

## 5. テスト方針

### 5.1 型レベルテスト（コンパイル成功 = pass）

- 配置: `packages/core/tests/`
- `.resi` で公開された全シンボル（`let` / `module` / `type`）の **100%** を `tests/` 配下から少なくとも 1 度参照する（PRD §5.4）。
- CI でこのディレクトリを `rescript build` する。コンパイル失敗 = 後方互換性ブレ。
- CI に grep ベースのカバレッジチェックジョブ（`tests-core-types`）を追加し、`.resi` 内の公開シンボルが `tests/` から参照されていない場合 fail させる。

### 5.2 ランタイムテスト（vitest + happy-dom）

- 配置: `packages/core/tests/runtime/`
- 検証項目:
  - `Core.Command.invoke` の encode → invoke → decode の round-trip。
  - `Event.listen` の登録・dispatch・unlisten。
  - `Mocks.mockIPC` 経由の I/O 差し替え。
  - `Channel.onMessage` のメッセージ伝播。

### 5.3 統合テスト（examples ビルド）

- 7 例（`examples/hello-world`、`examples/window-management`、`examples/ipc-typed`、`examples/streaming-ipc`、`examples/plugin-fs-demo`、`examples/plugin-dialog-demo`、`examples/ipc-typed-with-schema`）を CI で **Linux / macOS / Windows** ビルド。
- 1 環境でも失敗したらリリースを止める（PRD 5.4 信頼性ゲート）。

### 5.4 互換性チェック

- ReScript 12.x 安定版 + 次期マイナー / 次期メジャー prerelease の matrix CI。
- `@tauri-apps/api` の latest minor を nightly で取り込み、ビルドが通ることを確認するジョブ。

---

## 6. CI / 配布フロー

| ジョブ | トリガ | 内容 |
|---|---|---|
| `lint-format` | PR | Biome で手書き `.mjs` / JSON の format + lint（ReScript 生成物 `*.res.mjs` / `lib/` は除外） |
| `build-core` | PR / push | `packages/core` ビルド + 計測値（`time pnpm --filter @rescript-tauri/core build`）をジョブログに出力。クリーンビルド 30 秒・インクリメンタル 1 秒の閾値を超えたら fail（PRD §5.2） |
| `tests-core-types` / `tests-{schema,plugin-fs,plugin-dialog}-types` | PR | 各パッケージの型レベルコンパイル + `.resi` 公開シンボル 100% 参照カバレッジ（PRD §5.4） |
| `tests-core-runtime` / `tests-{schema,plugin-fs,plugin-dialog}-runtime` | PR | 各パッケージの vitest 実行（`Mocks.mockIPC` 経由の round-trip 検証を含む） |
| `tests-coverage` | PR / push | 4 パッケージ（core / plugin-fs / plugin-dialog / schema）を `strategy.matrix` で並列実行し、`@vitest/coverage-v8` で行・分岐・関数カバレッジを計測。Job summary に表で出力、LCOV / HTML を artifact 化（30 日保持）。**しきい値ゲート設定済み**（各 `vitest.config.mjs` の `coverage.thresholds`）。floor を下回ると `pnpm --filter @rescript-tauri/<pkg> test:coverage` が exit 非 0 を返し、ジョブが fail する |
| `examples-build` | PR | 7 例題（hello-world / window-management / ipc-typed / streaming-ipc / plugin-fs-demo / plugin-dialog-demo / ipc-typed-with-schema）を 3 OS でビルド |
| `doc-link-lint` | PR | 全 `.resi` 公開シンボルの doc comment に `v2.tauri.app` リンクが含まれているかを grep で検証（PRD §7 KPI） |
| `docs` | PR / push | Sphinx EN+JA の HTML ビルド + Pagefind アセンブリ |
| `compat-tauri-latest` | nightly | `@tauri-apps/api` を latest にして build |
| `compat-rescript-prerelease` | nightly | ReScript 12.x 次期マイナー / 次期メジャー prerelease で build。v12 系 API drift を先行検知 |
| `release` | tag push | npm publish（各パッケージ独立 semver）|

---

## 7. リリース判定基準（Phase 1）

リリースゲート:

1. PRD §4 Must スコープが全て実装済み。
2. 全モジュールに `.resi` が存在し、各公開シンボルに doc comment + Tauri 公式 URL リンクが付与されている。
3. `examples/hello-world` が Linux / macOS / Windows で CI 緑。
4. README に互換マトリクスが掲載されている。
5. RFC-0001 Decision checklist の必須項目が完了している（npm scope 予約 / repo URL / license / API 主要シグネチャ確定）。

---

## 8. 残課題と確定タイミング

| # | 論点 | 暫定 | 確定タイミング |
|---|---|---|---|
| 1 | `Tauri.res` re-export 範囲 | **Core / Event / Window / Webview / WebviewWindow 確定**（経緯: `.steering/20260509-023-tauri-reexport/`） | **確定済み（2026-05-09）** |
| 2 | `Channel` を `Core` 内 vs 独立モジュール | **`Core.Channel` サブモジュール採用（確定）** | **確定済み（Phase 1 設計レビュー）** |
| 3 | `*Exn` 命名 | **`*Exn` 採用（確定）**（`@rescript/core` 慣習） | **確定済み** |
| 4 | `Event.TauriEvent` の網羅範囲 | **upstream `TauriEvent` enum 16 種を完全カバー（確定）** — `closeRequested` / `focus` / `blur` / `scaleFactorChanged` / `resized` / `moved` / `themeChanged` / `webviewCreated` / `windowCreated` / `windowSuspended` / `windowResumed` / drag-* (4 種) / `windowDestroyed`。typed handle ではなく `Event.make(~name=TauriEvent.*, ~decode=...)` 形式で利用 | **確定済み（2026-05-09、`packages/core/src/Event.resi`）** |
| 5 | `Mocks` の独立パッケージ化 | **core 同梱を継続（確定）**（経緯: `.steering/20260509-045-mocks-packaging-decision/`） | **確定済み（2026-05-09）** |
| 6 | Belt-only ユーザー向け shim 提供可否 | 当面提供しない（`@rescript/core` を peerDep 必須） | Phase 1 リリース直前 |

---

## 9. 参照

- [PRD](./product-requirements.md)
- [RFC-0001](./ideas/RFC-0001-core-api-design.md)
- Tauri 公式: <https://v2.tauri.app/>
- ReScript: <https://rescript-lang.org/>
- `@rescript/core`: <https://github.com/rescript-lang/rescript-core>
