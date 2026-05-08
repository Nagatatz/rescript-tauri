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
    `'pos` is the physical position; until `Dpi`'s value types are
    threaded through this binding, callers should treat it as
    `Dpi.PhysicalPosition.t`'s wire shape (`{x, y}`).

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#dragdropevent
*/
type dragDropEvent<'pos> =
  | Enter({paths: array<string>, position: 'pos})
  | Over({position: 'pos})
  | Drop({paths: array<string>, position: 'pos})
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

/** The webview's label.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#label
*/
let label: t => string

/** Sets the webview size. Polymorphic until the `Dpi` module's value
    types are wired through this binding.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#setsize
*/
let setSize: (t, 'size) => promise<unit>

/** Sets the webview position relative to its host window. Polymorphic
    until Dpi integration.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#setposition
*/
let setPosition: (t, 'position) => promise<unit>

/** Returns the position of the webview in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#position
*/
let position: t => promise<'position>

/** Returns the size of the webview in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#size
*/
let size: t => promise<'size>

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

/** Subscribes to drag-and-drop events on this webview.

    See: https://v2.tauri.app/reference/javascript/api/namespacewebview/#ondragdropevent
*/
let onDragDropEvent: (t, dragDropEvent<'pos> => unit) => promise<unlisten>
