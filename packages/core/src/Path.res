module BaseDirectory = {
  type t = int

  // Numeric values mirror the upstream JS enum
  // (https://v2.tauri.app/reference/javascript/api/namespacepath/#basedirectory).
  let audio: t = 1
  let cache: t = 2
  let config: t = 3
  let data: t = 4
  let localData: t = 5
  let document: t = 6
  let download: t = 7
  let picture: t = 8
  let public: t = 9
  let video: t = 10
  let resource: t = 11
  let temp: t = 12
  let appConfig: t = 13
  let appData: t = 14
  let appLocalData: t = 15
  let appCache: t = 16
  let appLog: t = 17
  let desktop: t = 18
  let executable: t = 19
  let font: t = 20
  let home: t = 21
  let runtime: t = 22
  let template: t = 23
}

@module("@tauri-apps/api/path")
external appConfigDir: unit => promise<string> = "appConfigDir"

@module("@tauri-apps/api/path")
external appDataDir: unit => promise<string> = "appDataDir"

@module("@tauri-apps/api/path")
external appLocalDataDir: unit => promise<string> = "appLocalDataDir"

@module("@tauri-apps/api/path")
external appCacheDir: unit => promise<string> = "appCacheDir"

@module("@tauri-apps/api/path")
external appLogDir: unit => promise<string> = "appLogDir"

@module("@tauri-apps/api/path")
external audioDir: unit => promise<string> = "audioDir"

@module("@tauri-apps/api/path")
external cacheDir: unit => promise<string> = "cacheDir"

@module("@tauri-apps/api/path")
external configDir: unit => promise<string> = "configDir"

@module("@tauri-apps/api/path")
external dataDir: unit => promise<string> = "dataDir"

@module("@tauri-apps/api/path")
external localDataDir: unit => promise<string> = "localDataDir"

@module("@tauri-apps/api/path")
external desktopDir: unit => promise<string> = "desktopDir"

@module("@tauri-apps/api/path")
external documentDir: unit => promise<string> = "documentDir"

@module("@tauri-apps/api/path")
external downloadDir: unit => promise<string> = "downloadDir"

@module("@tauri-apps/api/path")
external executableDir: unit => promise<string> = "executableDir"

@module("@tauri-apps/api/path")
external fontDir: unit => promise<string> = "fontDir"

@module("@tauri-apps/api/path")
external homeDir: unit => promise<string> = "homeDir"

@module("@tauri-apps/api/path")
external pictureDir: unit => promise<string> = "pictureDir"

@module("@tauri-apps/api/path")
external publicDir: unit => promise<string> = "publicDir"

@module("@tauri-apps/api/path")
external resourceDir: unit => promise<string> = "resourceDir"

@module("@tauri-apps/api/path")
external runtimeDir: unit => promise<string> = "runtimeDir"

@module("@tauri-apps/api/path")
external templateDir: unit => promise<string> = "templateDir"

@module("@tauri-apps/api/path")
external tempDir: unit => promise<string> = "tempDir"

@module("@tauri-apps/api/path")
external videoDir: unit => promise<string> = "videoDir"

@module("@tauri-apps/api/path")
external resolveResource: string => promise<string> = "resolveResource"

@module("@tauri-apps/api/path")
external sep: unit => string = "sep"

@module("@tauri-apps/api/path")
external delimiter: unit => string = "delimiter"

@module("@tauri-apps/api/path") @variadic
external join: array<string> => promise<string> = "join"

@module("@tauri-apps/api/path")
external normalize: string => promise<string> = "normalize"

@module("@tauri-apps/api/path")
external dirname: string => promise<string> = "dirname"

@module("@tauri-apps/api/path")
external basename: (string, ~ext: string=?) => promise<string> = "basename"

@module("@tauri-apps/api/path")
external extname: string => promise<string> = "extname"

@module("@tauri-apps/api/path")
external isAbsolute: string => promise<bool> = "isAbsolute"

@module("@tauri-apps/api/path") @variadic
external resolve: array<string> => promise<string> = "resolve"
