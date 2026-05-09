type t

type unlisten = unit => unit

type dragDropEvent =
  | Enter({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Over({position: Dpi.PhysicalPosition.t})
  | Drop({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Leave

type options = {
  url?: string,
  userAgent?: string,
  zoomHotkeysEnabled?: bool,
  acceptFirstMouse?: bool,
  dragDropEnabled?: bool,
  transparent?: bool,
  backgroundColor?: Window.color,
}

@module("@tauri-apps/api/webview")
external getCurrentWebview: unit => t = "getCurrentWebview"

@module("@tauri-apps/api/webview")
external getAllWebviews: unit => promise<array<t>> = "getAllWebviews"

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
external setBackgroundColor: (t, Nullable.t<Window.color>) => promise<unit> = "setBackgroundColor"
@send external close: t => promise<unit> = "close"

// onDragDropEvent: upstream delivers an event whose payload has shape
// { type: 'enter' | 'over' | 'drop' | 'leave', ... }. The JS-side
// `position` is a `Dpi.PhysicalPosition` class instance; we cast it
// through `Obj.magic` since the type is opaque on the ReScript side.
@send
external _onDragDropEvent: (t, {..} => unit) => promise<unlisten> = "onDragDropEvent"

let onDragDropEvent = (webview, handler) =>
  _onDragDropEvent(webview, raw => {
    let payload = (Obj.magic(raw): {..})["payload"]
    let kind: string = payload["type"]
    let position: Dpi.PhysicalPosition.t = Obj.magic(payload["position"])
    switch kind {
    | "enter" => handler(Enter({paths: payload["paths"], position}))
    | "over" => handler(Over({position: position}))
    | "drop" => handler(Drop({paths: payload["paths"], position}))
    | "leave" => handler(Leave)
    // If upstream Tauri introduces a new drag-drop variant we have not
    // mapped yet, log it via Console.warn instead of silently dropping
    // the event so the gap surfaces during development.
    | other => Console.warn2("[rescript-tauri] Unknown drag-drop event type:", other)
    }
  })
