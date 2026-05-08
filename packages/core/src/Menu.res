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

// Encodes the predefinedItem variant into the JS-side discriminator
// (a string, except for `About` which is `{ About: AboutMetadata | null }`).
let _predefinedToJs = (item: predefinedItem) =>
  switch item {
  | Separator => Obj.magic("Separator")
  | Copy => Obj.magic("Copy")
  | Cut => Obj.magic("Cut")
  | Paste => Obj.magic("Paste")
  | SelectAll => Obj.magic("SelectAll")
  | Undo => Obj.magic("Undo")
  | Redo => Obj.magic("Redo")
  | Minimize => Obj.magic("Minimize")
  | Maximize => Obj.magic("Maximize")
  | Fullscreen => Obj.magic("Fullscreen")
  | Hide => Obj.magic("Hide")
  | HideOthers => Obj.magic("HideOthers")
  | ShowAll => Obj.magic("ShowAll")
  | CloseWindow => Obj.magic("CloseWindow")
  | Quit => Obj.magic("Quit")
  | Services => Obj.magic("Services")
  | BringAllToFront => Obj.magic("BringAllToFront")
  | About(meta) => Obj.magic({"About": meta})
  }

module MenuItem = {
  type t

  type options = {
    id?: string,
    text: string,
    enabled?: bool,
    accelerator?: string,
    action?: string => unit,
  }

  @module("@tauri-apps/api/menu") @scope("MenuItem")
  external make: options => promise<t> = "new"

  @get external id: t => string = "id"
  @send external text: t => promise<string> = "text"
  @send external setText: (t, string) => promise<unit> = "setText"
  @send external isEnabled: t => promise<bool> = "isEnabled"
  @send external setEnabled: (t, bool) => promise<unit> = "setEnabled"
  @send external setAccelerator: (t, Nullable.t<string>) => promise<unit> = "setAccelerator"
}

module CheckMenuItem = {
  type t

  type options = {
    id?: string,
    text: string,
    enabled?: bool,
    accelerator?: string,
    checked?: bool,
    action?: string => unit,
  }

  @module("@tauri-apps/api/menu") @scope("CheckMenuItem")
  external make: options => promise<t> = "new"

  @get external id: t => string = "id"
  @send external text: t => promise<string> = "text"
  @send external setText: (t, string) => promise<unit> = "setText"
  @send external isEnabled: t => promise<bool> = "isEnabled"
  @send external setEnabled: (t, bool) => promise<unit> = "setEnabled"
  @send external setAccelerator: (t, Nullable.t<string>) => promise<unit> = "setAccelerator"
  @send external isChecked: t => promise<bool> = "isChecked"
  @send external setChecked: (t, bool) => promise<unit> = "setChecked"
}

module IconMenuItem = {
  type t

  type options<'icon> = {
    id?: string,
    text: string,
    enabled?: bool,
    accelerator?: string,
    icon?: 'icon,
    action?: string => unit,
  }

  @module("@tauri-apps/api/menu") @scope("IconMenuItem")
  external make: options<'icon> => promise<t> = "new"

  @get external id: t => string = "id"
  @send external text: t => promise<string> = "text"
  @send external setText: (t, string) => promise<unit> = "setText"
  @send external isEnabled: t => promise<bool> = "isEnabled"
  @send external setEnabled: (t, bool) => promise<unit> = "setEnabled"
  @send external setAccelerator: (t, Nullable.t<string>) => promise<unit> = "setAccelerator"
  @send external setIcon: (t, 'icon) => promise<unit> = "setIcon"
}

module PredefinedMenuItem = {
  type t

  type options = {
    text?: string,
    item: predefinedItem,
  }

  type _jsOptions<'jsItem> = {
    text?: string,
    item: 'jsItem,
  }

  @module("@tauri-apps/api/menu") @scope("PredefinedMenuItem")
  external _make: _jsOptions<'jsItem> => promise<t> = "new"

  let make = (opts: options) =>
    _make({text: ?opts.text, item: _predefinedToJs(opts.item)})

  @get external id: t => string = "id"
  @send external text: t => promise<string> = "text"
  @send external setText: (t, string) => promise<unit> = "setText"
}

module Submenu = {
  type t

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

  // Strips the variant tag down to the underlying JS instance, which
  // is what the upstream API expects.
  let _itemToJs = (item: itemKind) =>
    switch item {
    | Item(v) => Obj.magic(v)
    | Check(v) => Obj.magic(v)
    | Icon(v) => Obj.magic(v)
    | Predefined(v) => Obj.magic(v)
    | Submenu(v) => Obj.magic(v)
    }

  let _itemFromJs: 'a => itemKind = raw => {
    let kind: string = (Obj.magic(raw): {"kind": string})["kind"]
    switch kind {
    | "MenuItem" => Item(Obj.magic(raw))
    | "Check" => Check(Obj.magic(raw))
    | "Icon" => Icon(Obj.magic(raw))
    | "Predefined" => Predefined(Obj.magic(raw))
    | "Submenu" => Submenu(Obj.magic(raw))
    | _ => Item(Obj.magic(raw))
    }
  }

  type _jsOptions<'icon, 'jsItem> = {
    id?: string,
    text: string,
    enabled?: bool,
    items?: array<'jsItem>,
    icon?: 'icon,
  }

  @module("@tauri-apps/api/menu") @scope("Submenu")
  external _make: _jsOptions<'icon, 'jsItem> => promise<t> = "new"

  let make = (opts: options<'icon>) =>
    _make({
      id: ?opts.id,
      text: opts.text,
      enabled: ?opts.enabled,
      items: ?opts.items->Option.map(arr => arr->Array.map(_itemToJs)),
      icon: ?opts.icon,
    })

  @get external id: t => string = "id"
  @send external text: t => promise<string> = "text"
  @send external setText: (t, string) => promise<unit> = "setText"
  @send external isEnabled: t => promise<bool> = "isEnabled"
  @send external setEnabled: (t, bool) => promise<unit> = "setEnabled"

  @send external _append: (t, array<'jsItem>) => promise<unit> = "append"
  let append = (sub, items) => _append(sub, items->Array.map(_itemToJs))

  @send external _prepend: (t, array<'jsItem>) => promise<unit> = "prepend"
  let prepend = (sub, items) => _prepend(sub, items->Array.map(_itemToJs))

  @send external _insert: (t, array<'jsItem>, int) => promise<unit> = "insert"
  let insert = (sub, items, ~position) => _insert(sub, items->Array.map(_itemToJs), position)

  @send external _remove: (t, 'jsItem) => promise<unit> = "remove"
  let remove = (sub, item) => _remove(sub, _itemToJs(item))

  @send external _removeAt: (t, int) => promise<Nullable.t<'jsItem>> = "removeAt"
  let removeAt = async (sub, position) => {
    let raw = await _removeAt(sub, position)
    raw->Nullable.toOption->Option.map(_itemFromJs)->Nullable.fromOption
  }

  @send external _items: t => promise<array<'jsItem>> = "items"
  let items = async sub => {
    let raw = await _items(sub)
    raw->Array.map(_itemFromJs)
  }

  @send external _get: (t, string) => promise<Nullable.t<'jsItem>> = "get"
  let get = async (sub, id) => {
    let raw = await _get(sub, id)
    raw->Nullable.toOption->Option.map(_itemFromJs)->Nullable.fromOption
  }

  @send
  external popup: (t, ~at: 'pos=?, ~window: Window.t=?) => promise<unit> = "popup"

  @send
  external setAsWindowsMenuForNSApp: t => promise<unit> = "setAsWindowsMenuForNSApp"

  @send external setAsHelpMenuForNSApp: t => promise<unit> = "setAsHelpMenuForNSApp"
}

module Menu = {
  type t

  type options = {
    id?: string,
    items?: array<Submenu.itemKind>,
  }

  type _jsOptions<'jsItem> = {
    id?: string,
    items?: array<'jsItem>,
  }

  @module("@tauri-apps/api/menu") @scope("Menu")
  external _make: _jsOptions<'jsItem> => promise<t> = "new"

  let make = (~options: option<options>=?) =>
    switch options {
    | None => _make({})
    | Some(opts) =>
      _make({
        id: ?opts.id,
        items: ?opts.items->Option.map(arr => arr->Array.map(Submenu._itemToJs)),
      })
    }

  @module("@tauri-apps/api/menu") @scope("Menu")
  external default: unit => promise<t> = "default"

  @get external id: t => string = "id"

  @send external _append: (t, array<'jsItem>) => promise<unit> = "append"
  let append = (menu, items) => _append(menu, items->Array.map(Submenu._itemToJs))

  @send external _prepend: (t, array<'jsItem>) => promise<unit> = "prepend"
  let prepend = (menu, items) => _prepend(menu, items->Array.map(Submenu._itemToJs))

  @send external _insert: (t, array<'jsItem>, int) => promise<unit> = "insert"
  let insert = (menu, items, ~position) => _insert(menu, items->Array.map(Submenu._itemToJs), position)

  @send external _remove: (t, 'jsItem) => promise<unit> = "remove"
  let remove = (menu, item) => _remove(menu, Submenu._itemToJs(item))

  @send external _removeAt: (t, int) => promise<Nullable.t<'jsItem>> = "removeAt"
  let removeAt = async (menu, position) => {
    let raw = await _removeAt(menu, position)
    raw->Nullable.toOption->Option.map(Submenu._itemFromJs)->Nullable.fromOption
  }

  @send external _items: t => promise<array<'jsItem>> = "items"
  let items = async menu => {
    let raw = await _items(menu)
    raw->Array.map(Submenu._itemFromJs)
  }

  @send external _get: (t, string) => promise<Nullable.t<'jsItem>> = "get"
  let get = async (menu, id) => {
    let raw = await _get(menu, id)
    raw->Nullable.toOption->Option.map(Submenu._itemFromJs)->Nullable.fromOption
  }

  @send
  external popup: (t, ~at: 'pos=?, ~window: Window.t=?) => promise<unit> = "popup"

  @send external setAsAppMenu: t => promise<Nullable.t<t>> = "setAsAppMenu"

  @send
  external setAsWindowMenu: (t, ~window: Window.t=?) => promise<Nullable.t<t>> = "setAsWindowMenu"
}
