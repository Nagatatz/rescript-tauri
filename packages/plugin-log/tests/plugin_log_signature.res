// Type-level signature test for PluginLog.

let _check_log_options: PluginLog.logOptions = {file: ?Some("Main.res"), line: ?Some(1)}

let _check_record_payload: PluginLog.recordPayload = {level: PluginLog.LogLevel.Info, message: "x"}

let _check_unlisten: PluginLog.unlisten = () => ()

let _check_log_level_trace: PluginLog.LogLevel.t = PluginLog.LogLevel.Trace
let _check_log_level_debug: PluginLog.LogLevel.t = PluginLog.LogLevel.Debug
let _check_log_level_info: PluginLog.LogLevel.t = PluginLog.LogLevel.Info
let _check_log_level_warn: PluginLog.LogLevel.t = PluginLog.LogLevel.Warn
let _check_log_level_error: PluginLog.LogLevel.t = PluginLog.LogLevel.Error

let _check_error: (string, ~options: PluginLog.logOptions=?) => promise<unit> = PluginLog.error
let _check_warn: (string, ~options: PluginLog.logOptions=?) => promise<unit> = PluginLog.warn
let _check_info: (string, ~options: PluginLog.logOptions=?) => promise<unit> = PluginLog.info
let _check_debug: (string, ~options: PluginLog.logOptions=?) => promise<unit> = PluginLog.debug
let _check_trace: (string, ~options: PluginLog.logOptions=?) => promise<unit> = PluginLog.trace

let _check_attach_logger: (PluginLog.recordPayload => unit) => promise<PluginLog.unlisten> =
  PluginLog.attachLogger
let _check_attach_console: unit => promise<PluginLog.unlisten> = PluginLog.attachConsole
