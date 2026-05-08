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

type rawEvent = {
  event: string,
  id: int,
  payload: JSON.t,
}

type t<'payload> = {
  name: string,
  decode: JSON.t => result<'payload, string>,
}

type unlisten = unit => unit

@module("@tauri-apps/api/event")
external _listen: (string, rawEvent => unit) => promise<unlisten> = "listen"

@module("@tauri-apps/api/event")
external _once: (string, rawEvent => unit) => promise<unlisten> = "once"

@module("@tauri-apps/api/event")
external _emit: (string, 'payload) => promise<unit> = "emit"

/** Internal: shape of the JS-side `EventTarget` object that Tauri's
    `emitTo` accepts. Always `{kind, label?}` — `label` is omitted for
    the `Any` and `App` variants. */
type targetJs = {kind: string, label?: string}

@module("@tauri-apps/api/event")
external _emitTo: (targetJs, string, 'payload) => promise<unit> = "emitTo"

let make = (~name, ~decode): t<'payload> => {name, decode}

let _wrap = (event: t<'payload>, handler: event<'payload> => unit, raw: rawEvent): unit =>
  switch event.decode(raw.payload) {
  | Ok(p) => handler({event: raw.event, id: raw.id, payload: p})
  | Error(_) => ()
  }

let listen = (event: t<'payload>, handler) =>
  _listen(event.name, raw => _wrap(event, handler, raw))

let once = (event: t<'payload>, handler) =>
  _once(event.name, raw => _wrap(event, handler, raw))

let emit = (event: t<'payload>, payload) => _emit(event.name, payload)

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

let emitTo = (event: t<'payload>, ~target, payload) => _emitTo(_targetToJs(target), event.name, payload)
