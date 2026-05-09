/** Bindings for `@tauri-apps/api/tray`.

    A `TrayIcon` is the OS-level system tray entry. This module wraps
    the upstream `TrayIcon` class as an opaque type. `'icon` and `'menu`
    are kept polymorphic so callers can pass `Image.t`, path strings,
    `Uint8Array`, etc. for the icon and `Menu.Menu.t` / `Menu.Submenu.t`
    for the menu.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/
*/

/** Mouse button identity for `Click` / `DoubleClick` events.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#mousebutton
*/
type mouseButton = [#Left | #Right | #Middle]

/** Press / release state for `Click` events.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#mousebuttonstate
*/
type mouseButtonState = [#Up | #Down]

/** Bounding rectangle delivered with each tray-icon event. Both
    coordinates are reported in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#trayiconeventbase
*/
type rect = {
  position: Dpi.PhysicalPosition.t,
  size: Dpi.PhysicalSize.t,
}

/** Tray-icon lifecycle event. Positions are reported in physical
    pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#trayiconevent
*/
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

/** Opaque tray-icon handle.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#trayicon
*/
type t

/** Construction options for `make`.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#trayiconoptions
*/
type options<'icon, 'menu> = {
  id?: string,
  /** `'menu` accepts a `Menu.Menu.t` or `Menu.Submenu.t`. */
  menu?: 'menu,
  /** `'icon` accepts `Image.t`, a path string, `Uint8Array`,
      `ArrayBuffer`, or `array<int>`.
  */
  icon?: 'icon,
  tooltip?: string,
  title?: string,
  tempDirPath?: string,
  iconAsTemplate?: bool,
  showMenuOnLeftClick?: bool,
  action?: trayIconEvent => unit,
}

/** Creates a new tray icon.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#new
*/
let make: (~options: options<'icon, 'menu>=?) => promise<t>

/** Looks up an existing tray icon by id.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#getbyid
*/
let getById: string => promise<Nullable.t<t>>

/** Removes the tray icon registered with the given id.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#removebyid
*/
let removeById: string => promise<unit>

/** The tray icon's id. */
let id: t => string

/** Sets the tray icon (`Nullable.null` clears it).

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#seticon
*/
let setIcon: (t, Nullable.t<'icon>) => promise<unit>

/** Sets the tray menu (`Nullable.null` to clear; on Linux clearing
    has no effect once set).

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#setmenu
*/
let setMenu: (t, Nullable.t<'menu>) => promise<unit>

/** Sets the tooltip (`Nullable.null` clears it).

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#settooltip
*/
let setTooltip: (t, Nullable.t<string>) => promise<unit>

/** Sets the title (`Nullable.null` clears it).

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#settitle
*/
let setTitle: (t, Nullable.t<string>) => promise<unit>

/** Toggles tray-icon visibility.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#setvisible
*/
let setVisible: (t, bool) => promise<unit>

/** Sets the temporary icon directory (Linux-only).

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#settempdirpath
*/
let setTempDirPath: (t, Nullable.t<string>) => promise<unit>

/** Toggles whether the icon is rendered as a macOS template image.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#seticonastemplate
*/
let setIconAsTemplate: (t, bool) => promise<unit>

/** Atomically sets the icon and template flag (macOS-only).

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#seticonwithastemplate
*/
let setIconWithAsTemplate: (t, Nullable.t<'icon>, bool) => promise<unit>

/** Toggles whether the tray menu opens on left-click.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#setshowmenuonleftclick
*/
let setShowMenuOnLeftClick: (t, bool) => promise<unit>

/** Releases the tray-icon resource immediately. Without this call
    the resource is kept alive until the Tauri app exits.

    See: https://v2.tauri.app/reference/javascript/api/namespacetray/#close
*/
let close: t => promise<unit>
