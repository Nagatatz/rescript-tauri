// Type-level signature test for Event.

let _check_make: (~name: string, ~decode: JSON.t => result<'payload, string>) => Event.t<'payload> =
  Event.make

let _check_listen: (Event.t<'payload>, Event.event<'payload> => unit) => promise<Event.unlisten> =
  Event.listen

let _check_once: (Event.t<'payload>, Event.event<'payload> => unit) => promise<Event.unlisten> =
  Event.once

let _check_emit: (Event.t<'payload>, 'payload) => promise<unit> = Event.emit

let _check_emit_to: (Event.t<'payload>, ~target: Event.eventTarget, 'payload) => promise<unit> =
  Event.emitTo

// Construct each eventTarget variant
let _t1: Event.eventTarget = Any
let _t2: Event.eventTarget = AnyLabel("main")
let _t3: Event.eventTarget = App
let _t4: Event.eventTarget = Window("main")
let _t5: Event.eventTarget = Webview("main")
let _t6: Event.eventTarget = WebviewWindow("main")
