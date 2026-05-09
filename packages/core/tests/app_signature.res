// Type-level signature test for App.

let _check_get_name: unit => promise<string> = App.getName
let _check_get_version: unit => promise<string> = App.getVersion
let _check_get_tauri_version: unit => promise<string> = App.getTauriVersion
let _check_get_identifier: unit => promise<string> = App.getIdentifier
let _check_show: unit => promise<unit> = App.show
let _check_hide: unit => promise<unit> = App.hide
let _check_default_window_icon: unit => promise<Nullable.t<Image.t>> = App.defaultWindowIcon
let _check_set_theme: Nullable.t<App.theme> => promise<unit> = App.setTheme
let _check_set_dock_visibility: bool => promise<unit> = App.setDockVisibility

let _check_theme_value: App.theme = #light

let _check_data_store_identifier_type: App.dataStoreIdentifier = []

let _check_bundle_type_nsis: App.bundleType = #nsis
let _check_bundle_type_msi: App.bundleType = #msi
let _check_bundle_type_deb: App.bundleType = #deb
let _check_bundle_type_rpm: App.bundleType = #rpm
let _check_bundle_type_appimage: App.bundleType = #appimage
let _check_bundle_type_app: App.bundleType = #app

let _check_back_payload: App.onBackButtonPressPayload = {canGoBack: false}

let _check_fetch_data_store_identifiers: unit => promise<array<App.dataStoreIdentifier>> =
  App.fetchDataStoreIdentifiers
let _check_remove_data_store: App.dataStoreIdentifier => promise<unit> = App.removeDataStore
let _check_get_bundle_type: unit => promise<App.bundleType> = App.getBundleType
let _check_on_back_button_press: (
  App.onBackButtonPressPayload => unit,
) => promise<Core.PluginListener.t> = App.onBackButtonPress
let _check_supports_multiple_windows: unit => promise<bool> = App.supportsMultipleWindows
