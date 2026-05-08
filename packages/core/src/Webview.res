type t

type unlisten = unit => unit

type dragDropEvent<'pos> =
  | Enter({paths: array<string>, position: 'pos})
  | Over({position: 'pos})
  | Drop({paths: array<string>, position: 'pos})
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
@send external setSize: (t, 'size) => promise<unit> = "setSize"
@send external setPosition: (t, 'position) => promise<unit> = "setPosition"
@send external position: t => promise<'position> = "position"
@send external size: t => promise<'size> = "size"
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
// { type: 'enter' | 'over' | 'drop' | 'leave', ... }. Map it into the
// ReScript variant before calling the user's handler.
@send
external _onDragDropEvent: (t, {..} => unit) => promise<unlisten> = "onDragDropEvent"

let onDragDropEvent = (webview, handler) =>
  _onDragDropEvent(webview, raw => {
    let payload = (Obj.magic(raw): {..})["payload"]
    let kind: string = payload["type"]
    switch kind {
    | "enter" =>
      handler(Enter({paths: payload["paths"], position: payload["position"]}))
    | "over" => handler(Over({position: payload["position"]}))
    | "drop" =>
      handler(Drop({paths: payload["paths"], position: payload["position"]}))
    | "leave" => handler(Leave)
    | _ => ()
    }
  })
