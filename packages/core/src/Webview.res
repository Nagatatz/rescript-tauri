type t

type options = {
  url?: string,
  userAgent?: string,
  zoomHotkeysEnabled?: bool,
  acceptFirstMouse?: bool,
  dragDropEnabled?: bool,
  transparent?: bool,
  backgroundColor?: Common.color,
}

@module("@tauri-apps/api/webview")
external getCurrentWebview: unit => t = "getCurrentWebview"

@module("@tauri-apps/api/webview")
external getAllWebviews: unit => promise<array<t>> = "getAllWebviews"

@scope("Webview") @module("@tauri-apps/api/webview")
external getByLabel: string => promise<Nullable.t<t>> = "getByLabel"

@get external label: t => string = "label"
@send external setSize: (t, Dpi.Size.t) => promise<unit> = "setSize"
@send external setPosition: (t, Dpi.Position.t) => promise<unit> = "setPosition"
@send external position: t => promise<Dpi.PhysicalPosition.t> = "position"
@send external size: t => promise<Dpi.PhysicalSize.t> = "size"
@send external setFocus: t => promise<unit> = "setFocus"
@send external setAutoResize: (t, bool) => promise<unit> = "setAutoResize"
@send external hide: t => promise<unit> = "hide"
@send external show: t => promise<unit> = "show"
@send external setZoom: (t, float) => promise<unit> = "setZoom"
@send external reparent: (t, 'windowOrLabel) => promise<unit> = "reparent"
@send
external setBackgroundColor: (t, Nullable.t<Common.color>) => promise<unit> = "setBackgroundColor"
@send external close: t => promise<unit> = "close"
@send external clearAllBrowsingData: t => promise<unit> = "clearAllBrowsingData"

@send
external _onDragDropEvent: (t, {..} => unit) => promise<Common.unlisten> = "onDragDropEvent"

let onDragDropEvent = (webview, handler) =>
  _onDragDropEvent(webview, raw => Common.decodeDragDropEvent(raw, handler))
