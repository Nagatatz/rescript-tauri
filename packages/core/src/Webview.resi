/** Bindings for `@tauri-apps/api/webview`.

    A `Webview` is the rendering surface inside a `Window`. On desktop
    the two often have a 1:1 relationship via `WebviewWindow`. Methods
    here only manipulate the webview layer; window operations live in
    the `Window` module.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/
*/

/** Opaque handle to a Tauri Webview.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#webview
*/
type t

/** Returned by `listen` / `once` / `onDragDropEvent` — call it to
    detach the handler.
*/
type unlisten = unit => unit

/** Drag-and-drop lifecycle event delivered to `onDragDropEvent`.
    Positions are reported in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#dragdropevent
*/
type dragDropEvent =
  | Enter({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Over({position: Dpi.PhysicalPosition.t})
  | Drop({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Leave

/** Construction options (excluding window-layer-only keys).

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#webviewoptions
*/
type options = {
  url?: string,
  userAgent?: string,
  zoomHotkeysEnabled?: bool,
  acceptFirstMouse?: bool,
  dragDropEnabled?: bool,
  transparent?: bool,
  backgroundColor?: Window.color,
}

/** Returns the webview hosting the current page.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#getcurrentwebview
*/
let getCurrentWebview: unit => t

/** Returns every webview registered with the application.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#getallwebviews
*/
let getAllWebviews: unit => promise<array<t>>

/** Looks up a webview by its label, returning `Nullable.null` if no
    such webview exists.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#getbylabel
*/
let getByLabel: string => promise<Nullable.t<t>>

/** The webview's label.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#label
*/
let label: t => string

/** Sets the webview size. Wrap a `LogicalSize` or `PhysicalSize` with
    `Dpi.Size.fromLogical` / `Dpi.Size.fromPhysical`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#setsize
*/
let setSize: (t, Dpi.Size.t) => promise<unit>

/** Sets the webview position relative to its host window. Wrap with
    `Dpi.Position.fromLogical` / `Dpi.Position.fromPhysical`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#setposition
*/
let setPosition: (t, Dpi.Position.t) => promise<unit>

/** Returns the position of the webview in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#position
*/
let position: t => promise<Dpi.PhysicalPosition.t>

/** Returns the size of the webview in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#size
*/
let size: t => promise<Dpi.PhysicalSize.t>

/** Brings the webview to focus.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#setfocus
*/
let setFocus: t => promise<unit>

/** Toggles whether the webview auto-resizes with its container.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#setautoresize
*/
let setAutoResize: (t, bool) => promise<unit>

/** Hides the webview.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#hide
*/
let hide: t => promise<unit>

/** Shows the webview.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#show
*/
let show: t => promise<unit>

/** Sets the page zoom level (`1.0` = 100%).

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#setzoom
*/
let setZoom: (t, float) => promise<unit>

/** Reparents the webview into a different host window. Pass either a
    `Window.t` or a window label string.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#reparent
*/
let reparent: (t, 'windowOrLabel) => promise<unit>

/** Sets the webview background color, or clears it when given
    `Nullable.null`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#setbackgroundcolor
*/
let setBackgroundColor: (t, Nullable.t<Window.color>) => promise<unit>

/** Closes the webview.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#close
*/
let close: t => promise<unit>

/** Clears all browsing data (cookies, storage, etc.) for this
    webview's data store.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#clearallbrowsingdata
*/
let clearAllBrowsingData: t => promise<unit>

/** Subscribes to drag-and-drop events on this webview.

    The handler receives one of `Enter` / `Over` / `Drop` / `Leave`.
    If upstream Tauri introduces a new variant before this binding
    catches up, the unknown payload type is logged via `Console.warn`
    and otherwise ignored — file an issue when you see the warning.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#ondragdropevent
*/
let onDragDropEvent: (t, dragDropEvent => unit) => promise<unlisten>
