// Type-level signature test for Dpi.

let _check_logical_size_make: (~width: float, ~height: float) => Dpi.LogicalSize.t = Dpi.LogicalSize.make
let _check_logical_size_width: Dpi.LogicalSize.t => float = Dpi.LogicalSize.width
let _check_logical_size_height: Dpi.LogicalSize.t => float = Dpi.LogicalSize.height

let _check_physical_size_make: (~width: float, ~height: float) => Dpi.PhysicalSize.t = Dpi.PhysicalSize.make
let _check_physical_size_width: Dpi.PhysicalSize.t => float = Dpi.PhysicalSize.width
let _check_physical_size_height: Dpi.PhysicalSize.t => float = Dpi.PhysicalSize.height
let _check_physical_size_to_logical: (Dpi.PhysicalSize.t, float) => Dpi.LogicalSize.t = Dpi.PhysicalSize.toLogical

let _check_logical_position_make: (~x: float, ~y: float) => Dpi.LogicalPosition.t = Dpi.LogicalPosition.make
let _check_logical_position_x: Dpi.LogicalPosition.t => float = Dpi.LogicalPosition.x
let _check_logical_position_y: Dpi.LogicalPosition.t => float = Dpi.LogicalPosition.y

let _check_physical_position_make: (~x: float, ~y: float) => Dpi.PhysicalPosition.t = Dpi.PhysicalPosition.make
let _check_physical_position_x: Dpi.PhysicalPosition.t => float = Dpi.PhysicalPosition.x
let _check_physical_position_y: Dpi.PhysicalPosition.t => float = Dpi.PhysicalPosition.y
let _check_physical_position_to_logical: (Dpi.PhysicalPosition.t, float) => Dpi.LogicalPosition.t = Dpi.PhysicalPosition.toLogical

let _check_size_from_logical: Dpi.LogicalSize.t => Dpi.Size.t = Dpi.Size.fromLogical
let _check_size_from_physical: Dpi.PhysicalSize.t => Dpi.Size.t = Dpi.Size.fromPhysical
let _check_size_to_logical: (Dpi.Size.t, float) => Dpi.LogicalSize.t = Dpi.Size.toLogical
let _check_size_to_physical: (Dpi.Size.t, float) => Dpi.PhysicalSize.t = Dpi.Size.toPhysical

let _check_position_from_logical: Dpi.LogicalPosition.t => Dpi.Position.t = Dpi.Position.fromLogical
let _check_position_from_physical: Dpi.PhysicalPosition.t => Dpi.Position.t = Dpi.Position.fromPhysical
let _check_position_to_logical: (Dpi.Position.t, float) => Dpi.LogicalPosition.t = Dpi.Position.toLogical
let _check_position_to_physical: (Dpi.Position.t, float) => Dpi.PhysicalPosition.t = Dpi.Position.toPhysical
