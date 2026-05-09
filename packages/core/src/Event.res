type event<'payload> = {
  event: string,
  id: int,
  payload: 'payload,
}

type eventTarget =
  | Any
  | AnyLabel(string)
  | App
  | Window(string)
  | Webview(string)
  | WebviewWindow(string)

type tauriEvent = [
  | #"tauri://resize"
  | #"tauri://move"
  | #"tauri://close-requested"
  | #"tauri://destroyed"
  | #"tauri://focus"
  | #"tauri://blur"
  | #"tauri://scale-change"
  | #"tauri://theme-changed"
  | #"tauri://window-created"
  | #"tauri://suspended"
  | #"tauri://resumed"
  | #"tauri://webview-created"
  | #"tauri://drag-enter"
  | #"tauri://drag-over"
  | #"tauri://drag-drop"
  | #"tauri://drag-leave"
]

module TauriEvent = {
  let windowResized: tauriEvent = #"tauri://resize"
  let windowMoved: tauriEvent = #"tauri://move"
  let windowCloseRequested: tauriEvent = #"tauri://close-requested"
  let windowDestroyed: tauriEvent = #"tauri://destroyed"
  let windowFocus: tauriEvent = #"tauri://focus"
  let windowBlur: tauriEvent = #"tauri://blur"
  let windowScaleFactorChanged: tauriEvent = #"tauri://scale-change"
  let windowThemeChanged: tauriEvent = #"tauri://theme-changed"
  let windowCreated: tauriEvent = #"tauri://window-created"
  let windowSuspended: tauriEvent = #"tauri://suspended"
  let windowResumed: tauriEvent = #"tauri://resumed"
  let webviewCreated: tauriEvent = #"tauri://webview-created"
  let dragEnter: tauriEvent = #"tauri://drag-enter"
  let dragOver: tauriEvent = #"tauri://drag-over"
  let dragDrop: tauriEvent = #"tauri://drag-drop"
  let dragLeave: tauriEvent = #"tauri://drag-leave"
}

type rawEvent = {
  event: string,
  id: int,
  payload: JSON.t,
}

type t<'payload> = {
  name: string,
  decode: Core.decoder<'payload>,
}

type unlisten = unit => unit

/** Internal: shape of the JS-side `EventTarget` object that Tauri's
    `emitTo` / `listen` / `once` accept. Always `{kind, label?}` —
    `label` is omitted for the `Any` and `App` variants. */
type targetJs = {kind: string, label?: string}

type listenOptions = {target: targetJs}

@module("@tauri-apps/api/event")
external _listen: (string, rawEvent => unit, ~options: listenOptions=?) => promise<unlisten> =
  "listen"

@module("@tauri-apps/api/event")
external _once: (string, rawEvent => unit, ~options: listenOptions=?) => promise<unlisten> = "once"

@module("@tauri-apps/api/event")
external _emit: (string, 'payload) => promise<unit> = "emit"

@module("@tauri-apps/api/event")
external _emitTo: (targetJs, string, 'payload) => promise<unit> = "emitTo"

let make = (~name, ~decode): t<'payload> => {name, decode}

/** Internal: decode a raw event payload and forward it to the user
    handler as `Ok(event<'payload>)` or `Error(decoderMessage)`. */
let _wrap = (
  event: t<'payload>,
  handler: result<event<'payload>, string> => unit,
  raw: rawEvent,
): unit =>
  Core.Internal.applyDecoder(event.decode, raw.payload, decoded =>
    handler(
      switch decoded {
      | Ok(p) => Ok({event: raw.event, id: raw.id, payload: p})
      | Error(msg) => Error(msg)
      },
    )
  )

/** Internal: encode the public `eventTarget` variant as the JS-side
    `{kind, label?}` object that Tauri's `emitTo` expects. */
let _targetToJs = (target): targetJs =>
  switch target {
  | Any => {kind: "Any"}
  | AnyLabel(label) => {kind: "AnyLabel", label}
  | App => {kind: "App"}
  | Window(label) => {kind: "Window", label}
  | Webview(label) => {kind: "Webview", label}
  | WebviewWindow(label) => {kind: "WebviewWindow", label}
  }

let listen = (event: t<'payload>, handler, ~target=?) =>
  switch target {
  | Some(t) => _listen(event.name, raw => _wrap(event, handler, raw), ~options={target: _targetToJs(t)})
  | None => _listen(event.name, raw => _wrap(event, handler, raw))
  }

let once = (event: t<'payload>, handler, ~target=?) =>
  switch target {
  | Some(t) => _once(event.name, raw => _wrap(event, handler, raw), ~options={target: _targetToJs(t)})
  | None => _once(event.name, raw => _wrap(event, handler, raw))
  }

let emit = (event: t<'payload>, payload) => _emit(event.name, payload)

let emitTo = (event: t<'payload>, ~target, payload) => _emitTo(_targetToJs(target), event.name, payload)
