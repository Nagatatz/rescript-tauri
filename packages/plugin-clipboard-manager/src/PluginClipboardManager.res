type writeTextOptions = {label?: string}

@module("@tauri-apps/plugin-clipboard-manager")
external writeText: (string, ~opts: writeTextOptions=?) => promise<unit> = "writeText"

@module("@tauri-apps/plugin-clipboard-manager")
external readText: unit => promise<string> = "readText"

@module("@tauri-apps/plugin-clipboard-manager")
external writeImage: 'image => promise<unit> = "writeImage"

@module("@tauri-apps/plugin-clipboard-manager")
external readImage: unit => promise<RescriptTauriCore.Image.t> = "readImage"

@module("@tauri-apps/plugin-clipboard-manager")
external writeHtml: (string, ~altText: string=?) => promise<unit> = "writeHtml"

@module("@tauri-apps/plugin-clipboard-manager")
external clear: unit => promise<unit> = "clear"
