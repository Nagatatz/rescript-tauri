/** Bindings for `@tauri-apps/api/webviewWindow`.

    A `WebviewWindow` is the JS-level merge of `Window` + `Webview`.
    The same JS object exposes both layers' methods, so this module
    uses zero-cost `%identity` casts (`asWindow` / `asWebview`) to give
    callers the right view. Only frequently-used methods are
    re-exported directly here; for everything else, cast first.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/
*/

/** Opaque handle to a Tauri WebviewWindow.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#webviewwindow
*/
type t

/** Cast to a `Window` view of the same underlying JS object.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#webviewwindow
*/
external asWindow: t => Window.t = "%identity"

/** Cast to a `Webview` view of the same underlying JS object.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#webviewwindow
*/
external asWebview: t => Webview.t = "%identity"

/** Construction options. Combines `Webview.options` (minus position
    keys) with `Window.options`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#webviewwindowoptions
*/
type options = {
  url?: string,
  userAgent?: string,
  zoomHotkeysEnabled?: bool,
  acceptFirstMouse?: bool,
  dragDropEnabled?: bool,
  transparent?: bool,
  title?: string,
  width?: float,
  height?: float,
  x?: float,
  y?: float,
  resizable?: bool,
  fullscreen?: bool,
  focus?: bool,
  decorations?: bool,
  alwaysOnTop?: bool,
  alwaysOnBottom?: bool,
  contentProtected?: bool,
  skipTaskbar?: bool,
  shadow?: bool,
  theme?: Window.theme,
  titleBarStyle?: Window.titleBarStyle,
  hiddenTitle?: bool,
  tabbingIdentifier?: string,
  maximized?: bool,
  visible?: bool,
  closable?: bool,
  parent?: Window.t,
  visibleOnAllWorkspaces?: bool,
  backgroundColor?: Common.color,
}

/** Creates a new `WebviewWindow`. The label must be unique among all
    webview windows.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#webviewwindow-1
*/
let make: (string, ~options: options=?) => t

/** Returns the current `WebviewWindow`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#getcurrentwebviewwindow
*/
let getCurrent: unit => t

/** Returns every webview window known to the application.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#getallwebviewwindows
*/
let getAll: unit => promise<array<t>>

/** Looks up a webview window by label.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#getbylabel
*/
let getByLabel: string => promise<Nullable.t<t>>

/** The webview window's label.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#label
*/
let label: t => string

/** Sets the title (re-exported from the `Window` layer for
    convenience).

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#settitle
*/
let setTitle: (t, string) => promise<unit>

/** Closes the webview window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#close
*/
let close: t => promise<unit>

/** Sets the background color of both window and webview layers
    (clears with `Nullable.null`).

    See: https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/#setbackgroundcolor
*/
let setBackgroundColor: (t, Nullable.t<Common.color>) => promise<unit>
