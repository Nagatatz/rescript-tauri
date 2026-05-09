// Type-level signature test for Common. Compilation success = the
// shared cross-cutting types still match the documented signatures.

let _check_unlisten: Common.unlisten = () => ()

let _check_color: Common.color = {r: 0, g: 0, b: 0, a: 255}

let _check_drag_drop_enter: Common.dragDropEvent = Enter({
  paths: ["/tmp/file"],
  position: Dpi.PhysicalPosition.make(~x=0.0, ~y=0.0),
})

let _check_drag_drop_over: Common.dragDropEvent = Over({
  position: Dpi.PhysicalPosition.make(~x=0.0, ~y=0.0),
})

let _check_drag_drop_drop: Common.dragDropEvent = Drop({
  paths: ["/tmp/file"],
  position: Dpi.PhysicalPosition.make(~x=0.0, ~y=0.0),
})

let _check_drag_drop_leave: Common.dragDropEvent = Leave
