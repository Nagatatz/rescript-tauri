/** Bindings for `@tauri-apps/api/menu`.

    Tauri's menu hierarchy is split across 6 JS modules upstream
    (`menu`, `menuItem`, `checkMenuItem`, `iconMenuItem`,
    `predefinedMenuItem`, `submenu`); they are gathered here as nested
    ReScript sub-modules so callers can `open Tauri.Menu` and reach
    every type from one import.

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/
*/

/** Application metadata for the predefined "About" item.

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#aboutmetadata
*/
type aboutMetadata = {
  name?: string,
  version?: string,
  shortVersion?: string,
  authors?: array<string>,
  comments?: string,
  copyright?: string,
  license?: string,
  website?: string,
  websiteLabel?: string,
  credits?: string,
  icon?: string,
}

/** macOS-only `NSImage` system icon names usable as the `icon` field
    of `IconMenuItem.options` / `Submenu.options`. The polymorphic
    variant lets users still pass arbitrary string / `Image.t` values
    via the existing `'icon` parameter — this enum is purely a
    convenience for the named macOS icons.

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#nativeicon
*/
type nativeIcon = [
  | #Add
  | #Advanced
  | #Bluetooth
  | #Bookmarks
  | #Caution
  | #ColorPanel
  | #ColumnView
  | #Computer
  | #EnterFullScreen
  | #Everyone
  | #ExitFullScreen
  | #FlowView
  | #Folder
  | #FolderBurnable
  | #FolderSmart
  | #FollowLinkFreestanding
  | #FontPanel
  | #GoLeft
  | #GoRight
  | #Home
  | #IChatTheater
  | #IconView
  | #Info
  | #InvalidDataFreestanding
  | #LeftFacingTriangle
  | #ListView
  | #LockLocked
  | #LockUnlocked
  | #MenuMixedState
  | #MenuOnState
  | #MobileMe
  | #MultipleDocuments
  | #Network
  | #Path
  | #PreferencesGeneral
  | #QuickLook
  | #RefreshFreestanding
  | #Refresh
  | #Remove
  | #RevealFreestanding
  | #RightFacingTriangle
  | #Share
  | #Slideshow
  | #SmartBadge
  | #StatusAvailable
  | #StatusNone
  | #StatusPartiallyAvailable
  | #StatusUnavailable
  | #StopProgressFreestanding
  | #StopProgress
  | #TrashEmpty
  | #TrashFull
  | #User
  | #UserAccounts
  | #UserGroup
  | #UserGuest
]

/** Identifies the OS-provided behavior backing a `PredefinedMenuItem`.

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#predefinedmenuitemoptions
*/
type predefinedItem =
  | Separator
  | Copy
  | Cut
  | Paste
  | SelectAll
  | Undo
  | Redo
  | Minimize
  | Maximize
  | Fullscreen
  | Hide
  | HideOthers
  | ShowAll
  | CloseWindow
  | Quit
  | Services
  | BringAllToFront
  | About(aboutMetadata)

/** Plain text menu item.

    The `id` / `text` / `setText` / `isEnabled` / `setEnabled` /
    `setAccelerator` group is shared verbatim with `CheckMenuItem`
    and `IconMenuItem`; consult any one of the three for parameter
    semantics. Each module re-declares them so the type-system can
    enforce the right `t` is passed.

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#menuitem
*/
module MenuItem: {
  type t

  type options = {
    id?: string,
    text: string,
    enabled?: bool,
    accelerator?: string,
    action?: string => unit,
  }

  /** Creates a new menu item.

      See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#new-1
  */
  let make: options => promise<t>

  /** The item's id. */
  let id: t => string

  /** Returns the current text. */
  let text: t => promise<string>

  /** Sets the text. */
  let setText: (t, string) => promise<unit>

  /** Whether the item is enabled. */
  let isEnabled: t => promise<bool>

  /** Toggles whether the item is enabled. */
  let setEnabled: (t, bool) => promise<unit>

  /** Sets the keyboard accelerator (`null` clears it). */
  let setAccelerator: (t, Nullable.t<string>) => promise<unit>
}

/** Menu item with a check-mark toggle. The first 6 methods mirror
    `MenuItem` (see that module's note); `isChecked` / `setChecked`
    are specific to this kind.

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#checkmenuitem
*/
module CheckMenuItem: {
  type t

  type options = {
    id?: string,
    text: string,
    enabled?: bool,
    accelerator?: string,
    checked?: bool,
    action?: string => unit,
  }

  let make: options => promise<t>
  let id: t => string
  let text: t => promise<string>
  let setText: (t, string) => promise<unit>
  let isEnabled: t => promise<bool>
  let setEnabled: (t, bool) => promise<unit>
  let setAccelerator: (t, Nullable.t<string>) => promise<unit>

  /** Whether the check is on. */
  let isChecked: t => promise<bool>

  /** Toggles the check state. */
  let setChecked: (t, bool) => promise<unit>
}

/** Menu item with an icon. The first 6 methods mirror `MenuItem`
    (see that module's note); `setIcon` is specific to this kind.

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#iconmenuitem
*/
module IconMenuItem: {
  type t

  type options<'icon> = {
    id?: string,
    text: string,
    enabled?: bool,
    accelerator?: string,
    /** `'icon` accepts `Image.t`, a path string, `Uint8Array`,
        `ArrayBuffer`, `array<int>`, or a NativeIcon string.
    */
    icon?: 'icon,
    action?: string => unit,
  }

  let make: options<'icon> => promise<t>
  let id: t => string
  let text: t => promise<string>
  let setText: (t, string) => promise<unit>
  let isEnabled: t => promise<bool>
  let setEnabled: (t, bool) => promise<unit>
  let setAccelerator: (t, Nullable.t<string>) => promise<unit>

  /** Sets a new icon. Polymorphic (same shape as `options.icon`). */
  let setIcon: (t, 'icon) => promise<unit>
}

/** OS-provided predefined item (separator, copy, paste, ...).

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#predefinedmenuitem
*/
module PredefinedMenuItem: {
  type t

  type options = {
    text?: string,
    item: predefinedItem,
  }

  let make: options => promise<t>
  let id: t => string
  let text: t => promise<string>
  let setText: (t, string) => promise<unit>
}

/** Container that can host other menu items.

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#submenu
*/
module Submenu: {
  type t

  /** A child of a Submenu / Menu. */
  type itemKind =
    | Item(MenuItem.t)
    | Check(CheckMenuItem.t)
    | Icon(IconMenuItem.t)
    | Predefined(PredefinedMenuItem.t)
    | Submenu(t)

  type options<'icon> = {
    id?: string,
    text: string,
    enabled?: bool,
    items?: array<itemKind>,
    icon?: 'icon,
  }

  let make: options<'icon> => promise<t>
  let id: t => string
  let text: t => promise<string>
  let setText: (t, string) => promise<unit>
  let isEnabled: t => promise<bool>
  let setEnabled: (t, bool) => promise<unit>

  /** Appends one or more items to the end of the submenu. */
  let append: (t, array<itemKind>) => promise<unit>

  /** Inserts items at the beginning. */
  let prepend: (t, array<itemKind>) => promise<unit>

  /** Inserts items at the given position. */
  let insert: (t, array<itemKind>, ~position: int) => promise<unit>

  /** Removes a specific item. */
  let remove: (t, itemKind) => promise<unit>

  /** Removes the item at `position`, returning the removed item or
      `Nullable.null`. */
  let removeAt: (t, int) => promise<Nullable.t<itemKind>>

  /** Returns the current child items. */
  let items: t => promise<array<itemKind>>

  /** Looks up a child by id. */
  let get: (t, string) => promise<Nullable.t<itemKind>>

  /** Pops the submenu up as a context menu on the given window
      (default: current). `~at` accepts a `Dpi.Position.t` constructed
      via `Dpi.Position.fromLogical` / `fromPhysical`.

      See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#popup-1
  */
  let popup: (t, ~at: Dpi.Position.t=?, ~window: Window.t=?) => promise<unit>

  /** Sets this submenu as the macOS Window menu. */
  let setAsWindowsMenuForNSApp: t => promise<unit>

  /** Sets this submenu as the macOS Help menu. */
  let setAsHelpMenuForNSApp: t => promise<unit>
}

/** Top-level menu (menu bar on Windows / Linux, app menu on macOS).

    See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#menu
*/
module Menu: {
  type t

  type options = {
    id?: string,
    items?: array<Submenu.itemKind>,
  }

  /** Creates an empty menu (or pre-populated via `~options`). */
  let make: (~options: options=?) => promise<t>

  /** Creates the OS-default app menu. */
  let default: unit => promise<t>

  let id: t => string

  let append: (t, array<Submenu.itemKind>) => promise<unit>
  let prepend: (t, array<Submenu.itemKind>) => promise<unit>
  let insert: (t, array<Submenu.itemKind>, ~position: int) => promise<unit>
  let remove: (t, Submenu.itemKind) => promise<unit>
  let removeAt: (t, int) => promise<Nullable.t<Submenu.itemKind>>
  let items: t => promise<array<Submenu.itemKind>>
  let get: (t, string) => promise<Nullable.t<Submenu.itemKind>>

  /** Pops the menu up as a context menu. See `Submenu.popup`. */
  let popup: (t, ~at: Dpi.Position.t=?, ~window: Window.t=?) => promise<unit>

  /** Sets this menu as the app-wide menu, returning the previous one.

      See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#setasappmenu
  */
  let setAsAppMenu: t => promise<Nullable.t<t>>

  /** Sets this menu as the menu of `~window`, returning the previous
      one.

      See: https://v2.tauri.app/reference/javascript/api/namespacemenu/#setaswindowmenu
  */
  let setAsWindowMenu: (t, ~window: Window.t=?) => promise<Nullable.t<t>>
}
