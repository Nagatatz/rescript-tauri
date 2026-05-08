# 設計: Window モジュール

## ファイル変更

### `packages/core/src/Window.res` (新規)

```rescript
type t

type options = {
  url?: string,
  title?: string,
  width?: float,
  height?: float,
  x?: float,
  y?: float,
  resizable?: bool,
  fullscreen?: bool,
  focus?: bool,
  transparent?: bool,
  decorations?: bool,
  alwaysOnTop?: bool,
  skipTaskbar?: bool,
}

// Constructor
@module("@tauri-apps/api/window") @new
external make: (string, ~options: options=?) => t = "Window"

// Static methods
@module("@tauri-apps/api/window") @scope("Window")
external getCurrent: unit => t = "getCurrent"

@module("@tauri-apps/api/window") @scope("Window")
external getAll: unit => array<t> = "getAll"

@module("@tauri-apps/api/window") @scope("Window")
external getByLabel: string => promise<Nullable.t<t>> = "getByLabel"

// Instance methods - identity / metadata
@send external label: t => string = "label"

// Instance methods - title
@send external setTitle: (t, string) => promise<unit> = "setTitle"
@send external title: t => promise<string> = "title"

// Instance methods - lifecycle
@send external close: t => promise<unit> = "close"
@send external destroy: t => promise<unit> = "destroy"

// Instance methods - visibility
@send external show: t => promise<unit> = "show"
@send external hide: t => promise<unit> = "hide"
@send external isVisible: t => promise<bool> = "isVisible"

// Instance methods - window state
@send external minimize: t => promise<unit> = "minimize"
@send external maximize: t => promise<unit> = "maximize"
@send external unmaximize: t => promise<unit> = "unmaximize"
@send external isMaximized: t => promise<bool> = "isMaximized"
@send external isMinimized: t => promise<bool> = "isMinimized"

// Instance methods - focus
@send external setFocus: t => promise<unit> = "setFocus"
@send external isFocused: t => promise<bool> = "isFocused"

// Instance methods - geometry (Dpi 未実装のため polymorphic)
@send external setSize: (t, 'size) => promise<unit> = "setSize"
@send external setPosition: (t, 'position) => promise<unit> = "setPosition"
@send external center: t => promise<unit> = "center"

// Instance methods - flags
@send external setFullscreen: (t, bool) => promise<unit> = "setFullscreen"
@send external setResizable: (t, bool) => promise<unit> = "setResizable"
@send external setAlwaysOnTop: (t, bool) => promise<unit> = "setAlwaysOnTop"
```

### `packages/core/src/Window.resi` (新規)

```rescript
/** Opaque handle to a Tauri Window. The underlying value is the JS
    Window class instance from `@tauri-apps/api/window`.

    **Resource lifetime**: Tauri does not garbage-collect native
    resources. Call `close` (graceful) or `destroy` (forced) when the
    window is no longer needed; otherwise the OS handle leaks.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/
*/
type t

/** Construction options for `make`. All fields are optional; pass only
    what you need. */
type options = {
  url?: string,
  title?: string,
  width?: float,
  height?: float,
  x?: float,
  y?: float,
  resizable?: bool,
  fullscreen?: bool,
  focus?: bool,
  transparent?: bool,
  decorations?: bool,
  alwaysOnTop?: bool,
  skipTaskbar?: bool,
}

/** Creates a new window. The label must be unique among all windows.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#window
*/
let make: (string, ~options: options=?) => t

/** Returns the currently focused window. */
let getCurrent: unit => t

/** Returns every Window known to the app. */
let getAll: unit => array<t>

/** Looks up a window by label, returning `Nullable.null` if no match. */
let getByLabel: string => promise<Nullable.t<t>>

/** The window's label. */
let label: t => string

/** Sets the window's title. */
let setTitle: (t, string) => promise<unit>

/** Returns the current title. */
let title: t => promise<string>

/** Requests a graceful close (the user can prevent it via the
    `tauri://close-requested` event). */
let close: t => promise<unit>

/** Forces the window to close immediately, bypassing any close-requested
    handlers. */
let destroy: t => promise<unit>

/** Shows the window. */
let show: t => promise<unit>

/** Hides the window. */
let hide: t => promise<unit>

/** Whether the window is currently visible. */
let isVisible: t => promise<bool>

/** Minimizes the window. */
let minimize: t => promise<unit>

/** Maximizes the window. */
let maximize: t => promise<unit>

/** Unmaximizes (restores) the window. */
let unmaximize: t => promise<unit>

/** Whether the window is currently maximized. */
let isMaximized: t => promise<bool>

/** Whether the window is currently minimized. */
let isMinimized: t => promise<bool>

/** Brings the window to focus. */
let setFocus: t => promise<unit>

/** Whether the window currently has focus. */
let isFocused: t => promise<bool>

/** Sets the window size. The argument shape is intentionally
    polymorphic until the Dpi module lands; pass a `LogicalSize` /
    `PhysicalSize` value as documented by Tauri. */
let setSize: (t, 'size) => promise<unit>

/** Sets the window position. Polymorphic until Dpi module lands. */
let setPosition: (t, 'position) => promise<unit>

/** Centers the window on the current monitor. */
let center: t => promise<unit>

/** Toggles fullscreen mode. */
let setFullscreen: (t, bool) => promise<unit>

/** Toggles whether the window can be resized by the user. */
let setResizable: (t, bool) => promise<unit>

/** Pins the window above other windows. */
let setAlwaysOnTop: (t, bool) => promise<unit>
```

### `packages/core/tests/window_signature.res`

```rescript
let _check_make: (string, ~options: Window.options=?) => Window.t = Window.make
let _check_get_current: unit => Window.t = Window.getCurrent
let _check_get_all: unit => array<Window.t> = Window.getAll
let _check_get_by_label: string => promise<Nullable.t<Window.t>> = Window.getByLabel

// Instance methods (sample — referencing every one would be very long)
let _check_label: Window.t => string = Window.label
let _check_set_title: (Window.t, string) => promise<unit> = Window.setTitle
let _check_title: Window.t => promise<string> = Window.title
let _check_close: Window.t => promise<unit> = Window.close
let _check_destroy: Window.t => promise<unit> = Window.destroy
let _check_show: Window.t => promise<unit> = Window.show
let _check_hide: Window.t => promise<unit> = Window.hide
let _check_is_visible: Window.t => promise<bool> = Window.isVisible
let _check_minimize: Window.t => promise<unit> = Window.minimize
let _check_maximize: Window.t => promise<unit> = Window.maximize
let _check_unmaximize: Window.t => promise<unit> = Window.unmaximize
let _check_is_maximized: Window.t => promise<bool> = Window.isMaximized
let _check_is_minimized: Window.t => promise<bool> = Window.isMinimized
let _check_set_focus: Window.t => promise<unit> = Window.setFocus
let _check_is_focused: Window.t => promise<bool> = Window.isFocused
let _check_set_size: (Window.t, 'size) => promise<unit> = Window.setSize
let _check_set_position: (Window.t, 'position) => promise<unit> = Window.setPosition
let _check_center: Window.t => promise<unit> = Window.center
let _check_set_fullscreen: (Window.t, bool) => promise<unit> = Window.setFullscreen
let _check_set_resizable: (Window.t, bool) => promise<unit> = Window.setResizable
let _check_set_always_on_top: (Window.t, bool) => promise<unit> = Window.setAlwaysOnTop
```

### `packages/core/tests/runtime/window.test.mjs`

Tauri の `Window` クラスは内部で `__TAURI_INTERNALS__.invoke` を呼ぶ。test では mock した invoke で arguments を検証する。

```javascript
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

const installInvoke = (handler) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = {
    invoke: handler ?? vi.fn(async () => undefined),
    transformCallback: (cb) => 1,
  }
}
const clear = () => { if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__ }

describe("Window", () => {
  beforeEach(() => installInvoke())
  afterEach(clear)

  it("make + label returns the label provided to the constructor", async () => {
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("settings")
    expect(Window.label(w)).toBe("settings")
  })

  it("setTitle invokes the Rust side", async () => {
    const invoke = vi.fn(async () => undefined)
    installInvoke(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    await Window.setTitle(w, "Hello")
    expect(invoke).toHaveBeenCalled()
  })

  it("isMaximized returns whatever the underlying invoke resolves to", async () => {
    installInvoke(vi.fn(async () => true))
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    const v = await Window.isMaximized(w)
    expect(v).toBe(true)
  })

  it("center invokes the Rust side", async () => {
    const invoke = vi.fn(async () => undefined)
    installInvoke(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    await Window.center(w)
    expect(invoke).toHaveBeenCalled()
  })
})
```

## コミット粒度

| # | コミット |
|---|---|
| 1 | 📝 Add steering for 20260508-014 (window-module) |
| 2 | ✨ Add Window module (core + essential 20 methods) |
| 3 | ✅ Add type-level + runtime tests for Window |
| 4 | 📝 Mark steering 20260508-014 complete |

## worktree

`EnterWorktree(name="window-module")`。
