// Type-level signature test for Menu.

// MenuItem
let _check_menu_item_make: Menu.MenuItem.options => promise<Menu.MenuItem.t> = Menu.MenuItem.make
let _check_menu_item_id: Menu.MenuItem.t => string = Menu.MenuItem.id
let _check_menu_item_text: Menu.MenuItem.t => promise<string> = Menu.MenuItem.text
let _check_menu_item_set_text: (Menu.MenuItem.t, string) => promise<unit> = Menu.MenuItem.setText
let _check_menu_item_is_enabled: Menu.MenuItem.t => promise<bool> = Menu.MenuItem.isEnabled
let _check_menu_item_set_enabled: (Menu.MenuItem.t, bool) => promise<unit> = Menu.MenuItem.setEnabled
let _check_menu_item_set_accelerator: (Menu.MenuItem.t, Nullable.t<string>) => promise<unit> = Menu.MenuItem.setAccelerator

// CheckMenuItem
let _check_check_make: Menu.CheckMenuItem.options => promise<Menu.CheckMenuItem.t> = Menu.CheckMenuItem.make
let _check_check_id: Menu.CheckMenuItem.t => string = Menu.CheckMenuItem.id
let _check_check_text: Menu.CheckMenuItem.t => promise<string> = Menu.CheckMenuItem.text
let _check_check_set_text: (Menu.CheckMenuItem.t, string) => promise<unit> = Menu.CheckMenuItem.setText
let _check_check_is_enabled: Menu.CheckMenuItem.t => promise<bool> = Menu.CheckMenuItem.isEnabled
let _check_check_set_enabled: (Menu.CheckMenuItem.t, bool) => promise<unit> = Menu.CheckMenuItem.setEnabled
let _check_check_set_accelerator: (Menu.CheckMenuItem.t, Nullable.t<string>) => promise<unit> = Menu.CheckMenuItem.setAccelerator
let _check_check_is_checked: Menu.CheckMenuItem.t => promise<bool> = Menu.CheckMenuItem.isChecked
let _check_check_set_checked: (Menu.CheckMenuItem.t, bool) => promise<unit> = Menu.CheckMenuItem.setChecked

// IconMenuItem
let _check_icon_make: Menu.IconMenuItem.options<'icon> => promise<Menu.IconMenuItem.t> = Menu.IconMenuItem.make
let _check_icon_id: Menu.IconMenuItem.t => string = Menu.IconMenuItem.id
let _check_icon_text: Menu.IconMenuItem.t => promise<string> = Menu.IconMenuItem.text
let _check_icon_set_text: (Menu.IconMenuItem.t, string) => promise<unit> = Menu.IconMenuItem.setText
let _check_icon_is_enabled: Menu.IconMenuItem.t => promise<bool> = Menu.IconMenuItem.isEnabled
let _check_icon_set_enabled: (Menu.IconMenuItem.t, bool) => promise<unit> = Menu.IconMenuItem.setEnabled
let _check_icon_set_accelerator: (Menu.IconMenuItem.t, Nullable.t<string>) => promise<unit> = Menu.IconMenuItem.setAccelerator
let _check_icon_set_icon: (Menu.IconMenuItem.t, 'icon) => promise<unit> = Menu.IconMenuItem.setIcon

// PredefinedMenuItem
let _check_predef_make: Menu.PredefinedMenuItem.options => promise<Menu.PredefinedMenuItem.t> = Menu.PredefinedMenuItem.make
let _check_predef_id: Menu.PredefinedMenuItem.t => string = Menu.PredefinedMenuItem.id
let _check_predef_text: Menu.PredefinedMenuItem.t => promise<string> = Menu.PredefinedMenuItem.text
let _check_predef_set_text: (Menu.PredefinedMenuItem.t, string) => promise<unit> = Menu.PredefinedMenuItem.setText

// Submenu
let _check_sub_make: Menu.Submenu.options<'icon> => promise<Menu.Submenu.t> = Menu.Submenu.make
let _check_sub_id: Menu.Submenu.t => string = Menu.Submenu.id
let _check_sub_text: Menu.Submenu.t => promise<string> = Menu.Submenu.text
let _check_sub_set_text: (Menu.Submenu.t, string) => promise<unit> = Menu.Submenu.setText
let _check_sub_is_enabled: Menu.Submenu.t => promise<bool> = Menu.Submenu.isEnabled
let _check_sub_set_enabled: (Menu.Submenu.t, bool) => promise<unit> = Menu.Submenu.setEnabled
let _check_sub_append: (Menu.Submenu.t, array<Menu.Submenu.itemKind>) => promise<unit> = Menu.Submenu.append
let _check_sub_prepend: (Menu.Submenu.t, array<Menu.Submenu.itemKind>) => promise<unit> = Menu.Submenu.prepend
let _check_sub_insert: (Menu.Submenu.t, array<Menu.Submenu.itemKind>, ~position: int) => promise<unit> = Menu.Submenu.insert
let _check_sub_remove: (Menu.Submenu.t, Menu.Submenu.itemKind) => promise<unit> = Menu.Submenu.remove
let _check_sub_remove_at: (Menu.Submenu.t, int) => promise<Nullable.t<Menu.Submenu.itemKind>> = Menu.Submenu.removeAt
let _check_sub_items: Menu.Submenu.t => promise<array<Menu.Submenu.itemKind>> = Menu.Submenu.items
let _check_sub_get: (Menu.Submenu.t, string) => promise<Nullable.t<Menu.Submenu.itemKind>> = Menu.Submenu.get
let _check_sub_popup: (Menu.Submenu.t, ~at: Dpi.Position.t=?, ~window: Window.t=?) => promise<unit> = Menu.Submenu.popup
let _check_sub_set_as_windows_menu: Menu.Submenu.t => promise<unit> = Menu.Submenu.setAsWindowsMenuForNSApp
let _check_sub_set_as_help_menu: Menu.Submenu.t => promise<unit> = Menu.Submenu.setAsHelpMenuForNSApp

// Menu
let _check_menu_make: (~options: Menu.Menu.options=?) => promise<Menu.Menu.t> = Menu.Menu.make
let _check_menu_default: unit => promise<Menu.Menu.t> = Menu.Menu.default
let _check_menu_id: Menu.Menu.t => string = Menu.Menu.id
let _check_menu_append: (Menu.Menu.t, array<Menu.Submenu.itemKind>) => promise<unit> = Menu.Menu.append
let _check_menu_prepend: (Menu.Menu.t, array<Menu.Submenu.itemKind>) => promise<unit> = Menu.Menu.prepend
let _check_menu_insert: (Menu.Menu.t, array<Menu.Submenu.itemKind>, ~position: int) => promise<unit> = Menu.Menu.insert
let _check_menu_remove: (Menu.Menu.t, Menu.Submenu.itemKind) => promise<unit> = Menu.Menu.remove
let _check_menu_remove_at: (Menu.Menu.t, int) => promise<Nullable.t<Menu.Submenu.itemKind>> = Menu.Menu.removeAt
let _check_menu_items: Menu.Menu.t => promise<array<Menu.Submenu.itemKind>> = Menu.Menu.items
let _check_menu_get: (Menu.Menu.t, string) => promise<Nullable.t<Menu.Submenu.itemKind>> = Menu.Menu.get
let _check_menu_popup: (Menu.Menu.t, ~at: Dpi.Position.t=?, ~window: Window.t=?) => promise<unit> = Menu.Menu.popup
let _check_menu_set_as_app: Menu.Menu.t => promise<Nullable.t<Menu.Menu.t>> = Menu.Menu.setAsAppMenu
let _check_menu_set_as_window: (Menu.Menu.t, ~window: Window.t=?) => promise<Nullable.t<Menu.Menu.t>> = Menu.Menu.setAsWindowMenu

// Variant value smoke checks
let _check_predef_separator: Menu.predefinedItem = Separator
let _check_predef_about: Menu.predefinedItem = About({})
