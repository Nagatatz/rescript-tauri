/** Bindings for `@tauri-apps/plugin-log` (Tauri 2.x logging plugin).

    Phase 2+ first iteration: 100% coverage of the stable public
    surface of `@tauri-apps/plugin-log` v2.8.0 — 5 log-level functions
    plus `attachLogger` / `attachConsole` for log-stream subscription.

    See: https://v2.tauri.app/plugin/logging/
*/

/** Returned by `attachLogger` / `attachConsole`. Call to detach. */
type unlisten = unit => unit

/** Optional metadata attached to a log record.

    See: https://v2.tauri.app/reference/javascript/log/#logoptions
*/
type logOptions = {
  /** Source file the log call originated from. */
  file?: string,
  /** Source line number. */
  line?: int,
  /** Free-form structured fields appended to the record. */
  keyValues?: Dict.t<string>,
}

/** Numeric log level matching the upstream enum:
    `trace=1` / `debug_=2` / `info_=3` / `warn_=4` / `error_=5`.

    `debug_` / `info_` / `warn_` / `error_` are suffixed because the
    bare names are reserved words in the JavaScript output (ReScript
    would otherwise emit `$$debug` / `$$info` / `$$warn` / `$$error`).
    `trace` is unchanged.

    See: https://v2.tauri.app/reference/javascript/log/#loglevel
*/
module LogLevel: {
  let trace: int
  let debug_: int
  let info_: int
  let warn_: int
  let error_: int
}

/** Payload delivered to `attachLogger`'s callback.

    See: https://v2.tauri.app/reference/javascript/log/#recordpayload
*/
type recordPayload = {
  /** Numeric level (use `LogLevel` constants for comparison). */
  level: int,
  /** Log message. */
  message: string,
}

/** Logs at the error level.

    See: https://v2.tauri.app/reference/javascript/log/#error
*/
let error: (string, ~options: logOptions=?) => promise<unit>

/** Logs at the warn level.

    See: https://v2.tauri.app/reference/javascript/log/#warn
*/
let warn: (string, ~options: logOptions=?) => promise<unit>

/** Logs at the info level.

    See: https://v2.tauri.app/reference/javascript/log/#info
*/
let info: (string, ~options: logOptions=?) => promise<unit>

/** Logs at the debug level.

    See: https://v2.tauri.app/reference/javascript/log/#debug
*/
let debug: (string, ~options: logOptions=?) => promise<unit>

/** Logs at the trace level.

    See: https://v2.tauri.app/reference/javascript/log/#trace
*/
let trace: (string, ~options: logOptions=?) => promise<unit>

/** Subscribes to the log stream. Returns an `unlisten`.

    See: https://v2.tauri.app/reference/javascript/log/#attachlogger
*/
let attachLogger: (recordPayload => unit) => promise<unlisten>

/** Subscribes a JS-console writer to the log stream. Returns an
    `unlisten`.

    See: https://v2.tauri.app/reference/javascript/log/#attachconsole
*/
let attachConsole: unit => promise<unlisten>
