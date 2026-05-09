/** Cross-cutting types shared by Window / Webview / WebviewWindow / Event.

    Each of these types appears in multiple `@tauri-apps/api`
    namespaces with identical shape. Centralizing them here removes
    duplication and avoids the artificial `Webview → Window`
    dependency that arose when `color` lived under `Window`.

    See: https://v2.tauri.app/reference/javascript/api/
*/

/** Returned by `on*` event handlers across `Window` / `Webview` /
    `Event` — call it to detach the listener.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#unlistenfn
*/
type unlisten = unit => unit

/** RGBA color used by `setBackgroundColor` (Window / Webview /
    WebviewWindow) and `effects.color` (Window).

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#color
*/
type color = {r: int, g: int, b: int, a: int}

/** Drag-and-drop lifecycle event delivered to `Window.onDragDropEvent`
    and `Webview.onDragDropEvent`. Positions are reported in physical
    pixels. The same gesture surfaces on whichever layer the OS routes
    the event to; the variant payload is identical in both cases.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#dragdropevent
*/
type dragDropEvent =
  | Enter({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Over({position: Dpi.PhysicalPosition.t})
  | Drop({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Leave

/** Internal: shared raw-payload decoder used by
    `Window.onDragDropEvent` and `Webview.onDragDropEvent`. NOT part of
    the stable public API; do not depend on its presence outside
    `@rescript-tauri/core`.
*/
let decodeDragDropEvent: ('raw, dragDropEvent => unit) => unit
