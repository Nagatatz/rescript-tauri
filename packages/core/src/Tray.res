type mouseButton = [#Left | #Right | #Middle]

type mouseButtonState = [#Up | #Down]

type rect = {
  position: Dpi.PhysicalPosition.t,
  size: Dpi.PhysicalSize.t,
}

type trayIconEvent =
  | Click({
      id: string,
      position: Dpi.PhysicalPosition.t,
      rect: rect,
      button: mouseButton,
      buttonState: mouseButtonState,
    })
  | DoubleClick({
      id: string,
      position: Dpi.PhysicalPosition.t,
      rect: rect,
      button: mouseButton,
    })
  | Enter({id: string, position: Dpi.PhysicalPosition.t, rect: rect})
  | Move({id: string, position: Dpi.PhysicalPosition.t, rect: rect})
  | Leave({id: string, position: Dpi.PhysicalPosition.t, rect: rect})

type t

type options<'icon, 'menu> = {
  id?: string,
  menu?: 'menu,
  icon?: 'icon,
  tooltip?: string,
  title?: string,
  tempDirPath?: string,
  iconAsTemplate?: bool,
  showMenuOnLeftClick?: bool,
  action?: trayIconEvent => unit,
}

// JS-side options shape: action receives a raw JSON-shaped object
// that we wrap into the trayIconEvent variant before delivering to
// user handlers.
type _jsOptions<'icon, 'menu, 'raw> = {
  id?: string,
  menu?: 'menu,
  icon?: 'icon,
  tooltip?: string,
  title?: string,
  tempDirPath?: string,
  iconAsTemplate?: bool,
  showMenuOnLeftClick?: bool,
  action?: 'raw => unit,
}

// _eventFromJs: upstream delivers a raw JS object; the `position` and
// `rect` fields are class instances (PhysicalPosition / PhysicalSize)
// which we cast into the opaque Dpi types via Obj.magic.
let _eventFromJs = (raw): trayIconEvent => {
  let r: {..} = Obj.magic(raw)
  let kind: string = r["type"]
  let id: string = r["id"]
  let position: Dpi.PhysicalPosition.t = Obj.magic(r["position"])
  let rect: rect = Obj.magic(r["rect"])
  switch kind {
  | "Click" =>
    Click({
      id,
      position,
      rect,
      button: r["button"],
      buttonState: r["buttonState"],
    })
  | "DoubleClick" => DoubleClick({id, position, rect, button: r["button"]})
  | "Enter" => Enter({id, position, rect})
  | "Move" => Move({id, position, rect})
  | "Leave" => Leave({id, position, rect})
  | _ => Leave({id, position, rect})
  }
}

@module("@tauri-apps/api/tray") @scope("TrayIcon")
external _make: _jsOptions<'icon, 'menu, 'raw> => promise<t> = "new"

let make = (~options: option<options<'icon, 'menu>>=?) =>
  switch options {
  | None => _make({})
  | Some(opts) =>
    _make({
      id: ?opts.id,
      menu: ?opts.menu,
      icon: ?opts.icon,
      tooltip: ?opts.tooltip,
      title: ?opts.title,
      tempDirPath: ?opts.tempDirPath,
      iconAsTemplate: ?opts.iconAsTemplate,
      showMenuOnLeftClick: ?opts.showMenuOnLeftClick,
      action: ?opts.action->Option.map(handler => raw => handler(_eventFromJs(raw))),
    })
  }

@module("@tauri-apps/api/tray") @scope("TrayIcon")
external getById: string => promise<Nullable.t<t>> = "getById"

@module("@tauri-apps/api/tray") @scope("TrayIcon")
external removeById: string => promise<unit> = "removeById"

@get external id: t => string = "id"

@send external setIcon: (t, Nullable.t<'icon>) => promise<unit> = "setIcon"
@send external setMenu: (t, Nullable.t<'menu>) => promise<unit> = "setMenu"
@send external setTooltip: (t, Nullable.t<string>) => promise<unit> = "setTooltip"
@send external setTitle: (t, Nullable.t<string>) => promise<unit> = "setTitle"
@send external setVisible: (t, bool) => promise<unit> = "setVisible"
@send external setTempDirPath: (t, Nullable.t<string>) => promise<unit> = "setTempDirPath"
@send external setIconAsTemplate: (t, bool) => promise<unit> = "setIconAsTemplate"
@send
external setIconWithAsTemplate: (t, Nullable.t<'icon>, bool) => promise<unit> =
  "setIconWithAsTemplate"
@send external setShowMenuOnLeftClick: (t, bool) => promise<unit> = "setShowMenuOnLeftClick"
@send external close: t => promise<unit> = "close"
