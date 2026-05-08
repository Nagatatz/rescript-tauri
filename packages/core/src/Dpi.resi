/** DPI-aware size and position types from `@tauri-apps/api/dpi`.

    Tauri's IPC layer requires `LogicalSize` / `PhysicalSize` / etc.
    to be passed as class instances (the JS classes carry a discriminating
    `type` field that Rust deserializes). The bindings expose each class
    as an opaque type with a constructor and read-only accessors so the
    same instances flow back into `Window.setSize`, `setPosition`,
    `cursorPosition`, etc.

    See: https://v2.tauri.app/reference/javascript/api/namespacedpi/
*/

/** A size in logical (DPI-scaled) pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#logicalsize
*/
module LogicalSize: {
  type t

  /** Constructs a new logical size.

      See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#logicalsize
  */
  let make: (~width: float, ~height: float) => t

  /** The width in logical pixels. */
  let width: t => float

  /** The height in logical pixels. */
  let height: t => float
}

/** A size in physical (DPI-independent) pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#physicalsize
*/
module PhysicalSize: {
  type t

  /** Constructs a new physical size.

      See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#physicalsize
  */
  let make: (~width: float, ~height: float) => t

  /** The width in physical pixels. */
  let width: t => float

  /** The height in physical pixels. */
  let height: t => float

  /** Converts to a logical size given the current scale factor.

      See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#tological
  */
  let toLogical: (t, float) => LogicalSize.t
}

/** A position in logical (DPI-scaled) pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#logicalposition
*/
module LogicalPosition: {
  type t

  /** Constructs a new logical position.

      See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#logicalposition
  */
  let make: (~x: float, ~y: float) => t

  /** The x coordinate in logical pixels. */
  let x: t => float

  /** The y coordinate in logical pixels. */
  let y: t => float
}

/** A position in physical (DPI-independent) pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#physicalposition
*/
module PhysicalPosition: {
  type t

  /** Constructs a new physical position.

      See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#physicalposition
  */
  let make: (~x: float, ~y: float) => t

  /** The x coordinate in physical pixels. */
  let x: t => float

  /** The y coordinate in physical pixels. */
  let y: t => float

  /** Converts to a logical position given the current scale factor.

      See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#tological-1
  */
  let toLogical: (t, float) => LogicalPosition.t
}

/** A union type usable as a `tauri::Size` argument in Rust commands.
    Wraps a `LogicalSize.t` or `PhysicalSize.t` and serializes as the
    `{ Logical | Physical: { width, height } }` shape Tauri expects.

    See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#size
*/
module Size: {
  type t

  /** Wraps a logical size. */
  let fromLogical: LogicalSize.t => t

  /** Wraps a physical size. */
  let fromPhysical: PhysicalSize.t => t

  /** Converts the wrapped value to physical pixels. */
  let toPhysical: (t, float) => PhysicalSize.t

  /** Converts the wrapped value to logical pixels. */
  let toLogical: (t, float) => LogicalSize.t
}

/** A union type usable as a `tauri::Position` argument in Rust
    commands. Mirrors `Size` for positions.

    See: https://v2.tauri.app/reference/javascript/api/namespacedpi/#position
*/
module Position: {
  type t

  /** Wraps a logical position. */
  let fromLogical: LogicalPosition.t => t

  /** Wraps a physical position. */
  let fromPhysical: PhysicalPosition.t => t

  /** Converts the wrapped value to physical pixels. */
  let toPhysical: (t, float) => PhysicalPosition.t

  /** Converts the wrapped value to logical pixels. */
  let toLogical: (t, float) => LogicalPosition.t
}
