// Type-level signature test for Tray.

let _check_make: (
  ~options: Tray.options<'icon, 'menu, 'pos, 'size>=?,
) => promise<Tray.t> = Tray.make
let _check_get_by_id: string => promise<Nullable.t<Tray.t>> = Tray.getById
let _check_remove_by_id: string => promise<unit> = Tray.removeById
let _check_id: Tray.t => string = Tray.id
let _check_set_icon: (Tray.t, Nullable.t<'icon>) => promise<unit> = Tray.setIcon
let _check_set_menu: (Tray.t, Nullable.t<'menu>) => promise<unit> = Tray.setMenu
let _check_set_tooltip: (Tray.t, Nullable.t<string>) => promise<unit> = Tray.setTooltip
let _check_set_title: (Tray.t, Nullable.t<string>) => promise<unit> = Tray.setTitle
let _check_set_visible: (Tray.t, bool) => promise<unit> = Tray.setVisible
let _check_set_temp_dir_path: (Tray.t, Nullable.t<string>) => promise<unit> = Tray.setTempDirPath
let _check_set_icon_as_template: (Tray.t, bool) => promise<unit> = Tray.setIconAsTemplate
let _check_set_icon_with_as_template: (Tray.t, Nullable.t<'icon>, bool) => promise<unit> = Tray.setIconWithAsTemplate
let _check_set_show_menu_on_left_click: (Tray.t, bool) => promise<unit> = Tray.setShowMenuOnLeftClick
let _check_close: Tray.t => promise<unit> = Tray.close

// Variant smoke checks
let _check_button: Tray.mouseButton = #Left
let _check_button_state: Tray.mouseButtonState = #Up
