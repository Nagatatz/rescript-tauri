type mouseButton = [#Left | #Right | #Middle]

type mouseButtonState = [#Up | #Down]

type rect<'pos, 'size> = {
  position: 'pos,
  size: 'size,
}

type trayIconEvent<'pos, 'size> =
  | Click({
      id: string,
      position: 'pos,
      rect: rect<'pos, 'size>,
      button: mouseButton,
      buttonState: mouseButtonState,
    })
  | DoubleClick({id: string, position: 'pos, rect: rect<'pos, 'size>, button: mouseButton})
  | Enter({id: string, position: 'pos, rect: rect<'pos, 'size>})
  | Move({id: string, position: 'pos, rect: rect<'pos, 'size>})
  | Leave({id: string, position: 'pos, rect: rect<'pos, 'size>})

type t

type options<'icon, 'menu, 'pos, 'size> = {
  id?: string,
  menu?: 'menu,
  icon?: 'icon,
  tooltip?: string,
  title?: string,
  tempDirPath?: string,
  iconAsTemplate?: bool,
  showMenuOnLeftClick?: bool,
  action?: trayIconEvent<'pos, 'size> => unit,
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

let _eventFromJs = (raw): trayIconEvent<'pos, 'size> => {
  let r: {..} = Obj.magic(raw)
  let kind: string = r["type"]
  let id: string = r["id"]
  let position = r["position"]
  let rect = r["rect"]
  switch kind {
  | "Click" =>
    Click({
      id,
      position,
      rect,
      button: r["button"],
      buttonState: r["buttonState"],
    })
  | "DoubleClick" =>
    DoubleClick({id, position, rect, button: r["button"]})
  | "Enter" => Enter({id, position, rect})
  | "Move" => Move({id, position, rect})
  | "Leave" => Leave({id, position, rect})
  | _ => Leave({id, position, rect})
  }
}

@module("@tauri-apps/api/tray") @scope("TrayIcon")
external _make: _jsOptions<'icon, 'menu, 'raw> => promise<t> = "new"

let make = (~options: option<options<'icon, 'menu, 'pos, 'size>>=?) =>
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
