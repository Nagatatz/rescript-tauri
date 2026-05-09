type unlisten = unit => unit

type color = {r: int, g: int, b: int, a: int}

type dragDropEvent =
  | Enter({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Over({position: Dpi.PhysicalPosition.t})
  | Drop({paths: array<string>, position: Dpi.PhysicalPosition.t})
  | Leave

// Internal: shared decoder for the Tauri drag-drop event payload. The
// raw event delivered by `@tauri-apps/api/window` and
// `@tauri-apps/api/webview` has shape
// `{ payload: { type: 'enter' | 'over' | 'drop' | 'leave', paths?, position }, ... }`.
// `position` is a `Dpi.PhysicalPosition` class instance which we cast
// through `Obj.magic` since the type is opaque on the ReScript side.
let decodeDragDropEvent = (raw, handler) => {
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
}
