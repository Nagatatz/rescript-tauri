/** Opaque handle to a Tauri Window. The underlying value is the JS
    Window class instance from `@tauri-apps/api/window`.

    **Resource lifetime**: Tauri does not garbage-collect native
    resources. Call `close` (graceful) or `destroy` (forced) when the
    window is no longer needed; otherwise the OS handle leaks.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/
*/
type t

/** Construction options for `make`. All fields are optional. */
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

/** Forces the window to close immediately. */
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

/** Sets the window size. The argument is intentionally polymorphic
    until the Dpi module lands; pass a `LogicalSize` / `PhysicalSize`
    value as documented by Tauri. */
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
