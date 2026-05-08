type theme = [#light | #dark]

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
external setTheme: (~theme: Nullable.t<theme>=?) => promise<unit> = "setTheme"

@module("@tauri-apps/api/app")
external setDockVisibility: bool => promise<unit> = "setDockVisibility"
