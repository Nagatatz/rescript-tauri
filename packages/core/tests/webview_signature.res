// Type-level signature test for Webview.

let _check_get_current_webview: unit => Webview.t = Webview.getCurrentWebview
let _check_get_all_webviews: unit => promise<array<Webview.t>> = Webview.getAllWebviews
let _check_label: Webview.t => string = Webview.label
let _check_set_size: (Webview.t, Dpi.Size.t) => promise<unit> = Webview.setSize
let _check_set_position: (Webview.t, Dpi.Position.t) => promise<unit> = Webview.setPosition
let _check_position: Webview.t => promise<Dpi.PhysicalPosition.t> = Webview.position
let _check_size: Webview.t => promise<Dpi.PhysicalSize.t> = Webview.size
let _check_set_focus: Webview.t => promise<unit> = Webview.setFocus
let _check_set_auto_resize: (Webview.t, bool) => promise<unit> = Webview.setAutoResize
let _check_hide: Webview.t => promise<unit> = Webview.hide
let _check_show: Webview.t => promise<unit> = Webview.show
let _check_set_zoom: (Webview.t, float) => promise<unit> = Webview.setZoom
let _check_reparent: (Webview.t, 'wl) => promise<unit> = Webview.reparent
let _check_set_background_color: (Webview.t, Nullable.t<Window.color>) => promise<unit> = Webview.setBackgroundColor
let _check_close: Webview.t => promise<unit> = Webview.close
let _check_on_drag_drop_event: (
  Webview.t,
  Webview.dragDropEvent => unit,
) => promise<Webview.unlisten> = Webview.onDragDropEvent

let _check_unlisten_value: Webview.unlisten = () => ()
