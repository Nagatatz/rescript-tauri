type unlisten = unit => unit

type logOptions = {
  file?: string,
  line?: int,
  keyValues?: Dict.t<string>,
}

module LogLevel = {
  @unboxed
  type t =
    | @as(1) Trace
    | @as(2) Debug
    | @as(3) Info
    | @as(4) Warn
    | @as(5) Error
}

type recordPayload = {
  level: LogLevel.t,
  message: string,
}

@module("@tauri-apps/plugin-log")
external error: (string, ~options: logOptions=?) => promise<unit> = "error"

@module("@tauri-apps/plugin-log")
external warn: (string, ~options: logOptions=?) => promise<unit> = "warn"

@module("@tauri-apps/plugin-log")
external info: (string, ~options: logOptions=?) => promise<unit> = "info"

@module("@tauri-apps/plugin-log")
external debug: (string, ~options: logOptions=?) => promise<unit> = "debug"

@module("@tauri-apps/plugin-log")
external trace: (string, ~options: logOptions=?) => promise<unit> = "trace"

@module("@tauri-apps/plugin-log")
external attachLogger: (recordPayload => unit) => promise<unlisten> = "attachLogger"

@module("@tauri-apps/plugin-log")
external attachConsole: unit => promise<unlisten> = "attachConsole"
