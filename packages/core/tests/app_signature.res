// Type-level signature test for App.

let _check_get_name: unit => promise<string> = App.getName
let _check_get_version: unit => promise<string> = App.getVersion
let _check_get_tauri_version: unit => promise<string> = App.getTauriVersion
let _check_get_identifier: unit => promise<string> = App.getIdentifier
let _check_show: unit => promise<unit> = App.show
let _check_hide: unit => promise<unit> = App.hide
let _check_default_window_icon: unit => promise<Nullable.t<Image.t>> = App.defaultWindowIcon
let _check_set_theme: (~theme: Nullable.t<App.theme>=?) => promise<unit> = App.setTheme
let _check_set_dock_visibility: bool => promise<unit> = App.setDockVisibility

let _check_theme_value: App.theme = #light
