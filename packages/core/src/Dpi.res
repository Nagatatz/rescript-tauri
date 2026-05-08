module LogicalSize = {
  type t

  @module("@tauri-apps/api/dpi") @new
  external make: (~width: float, ~height: float) => t = "LogicalSize"

  @get external width: t => float = "width"
  @get external height: t => float = "height"
}

module PhysicalSize = {
  type t

  @module("@tauri-apps/api/dpi") @new
  external make: (~width: float, ~height: float) => t = "PhysicalSize"

  @get external width: t => float = "width"
  @get external height: t => float = "height"

  @send external toLogical: (t, float) => LogicalSize.t = "toLogical"
}

module LogicalPosition = {
  type t

  @module("@tauri-apps/api/dpi") @new
  external make: (~x: float, ~y: float) => t = "LogicalPosition"

  @get external x: t => float = "x"
  @get external y: t => float = "y"
}

module PhysicalPosition = {
  type t

  @module("@tauri-apps/api/dpi") @new
  external make: (~x: float, ~y: float) => t = "PhysicalPosition"

  @get external x: t => float = "x"
  @get external y: t => float = "y"

  @send external toLogical: (t, float) => LogicalPosition.t = "toLogical"
}

module Size = {
  type t

  @module("@tauri-apps/api/dpi") @new
  external _make: 'inner => t = "Size"

  let fromLogical = (logical: LogicalSize.t) => _make(logical)
  let fromPhysical = (physical: PhysicalSize.t) => _make(physical)

  @send external toPhysical: (t, float) => PhysicalSize.t = "toPhysical"
  @send external toLogical: (t, float) => LogicalSize.t = "toLogical"
}

module Position = {
  type t

  @module("@tauri-apps/api/dpi") @new
  external _make: 'inner => t = "Position"

  let fromLogical = (logical: LogicalPosition.t) => _make(logical)
  let fromPhysical = (physical: PhysicalPosition.t) => _make(physical)

  @send external toPhysical: (t, float) => PhysicalPosition.t = "toPhysical"
  @send external toLogical: (t, float) => LogicalPosition.t = "toLogical"
}
