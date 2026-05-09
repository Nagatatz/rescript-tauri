type theme = Window.theme

type dataStoreIdentifier = array<int>

type bundleType = [#nsis | #msi | #deb | #rpm | #appimage | #app]

type onBackButtonPressPayload = {canGoBack: bool}

@module("@tauri-apps/api/app")
external getName: unit => promise<string> = "getName"

@module("@tauri-apps/api/app")
external getVersion: unit => promise<string> = "getVersion"

@module("@tauri-apps/api/app")
external getTauriVersion: unit => promise<string> = "getTauriVersion"

@module("@tauri-apps/api/app")
external getIdentifier: unit => promise<string> = "getIdentifier"

@module("@tauri-apps/api/app")
external show: unit => promise<unit> = "show"

@module("@tauri-apps/api/app")
external hide: unit => promise<unit> = "hide"

@module("@tauri-apps/api/app")
external defaultWindowIcon: unit => promise<Nullable.t<Image.t>> = "defaultWindowIcon"

@module("@tauri-apps/api/app")
external setTheme: Nullable.t<theme> => promise<unit> = "setTheme"

@module("@tauri-apps/api/app")
external setDockVisibility: bool => promise<unit> = "setDockVisibility"

@module("@tauri-apps/api/app")
external fetchDataStoreIdentifiers: unit => promise<array<dataStoreIdentifier>> =
  "fetchDataStoreIdentifiers"

@module("@tauri-apps/api/app")
external removeDataStore: dataStoreIdentifier => promise<unit> = "removeDataStore"

@module("@tauri-apps/api/app")
external getBundleType: unit => promise<bundleType> = "getBundleType"

@module("@tauri-apps/api/app")
external onBackButtonPress: (
  onBackButtonPressPayload => unit,
) => promise<Core.PluginListener.t> = "onBackButtonPress"

@module("@tauri-apps/api/app")
external supportsMultipleWindows: unit => promise<bool> = "supportsMultipleWindows"
