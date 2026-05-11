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

/** Log level. Matches the upstream numeric enum
    `trace=1` / `debug=2` / `info=3` / `warn=4` / `error=5`.

    The variant is `@unboxed` with per-constructor `@as(N)` so its
    runtime representation is the bare integer — wire-compatible with
    upstream's `recordPayload.level` field.

    See: https://v2.tauri.app/reference/javascript/log/#loglevel
*/
module LogLevel: {
  @unboxed
  type t =
    | @as(1) Trace
    | @as(2) Debug
    | @as(3) Info
    | @as(4) Warn
    | @as(5) Error
}

/** Payload delivered to `attachLogger`'s callback.

    See: https://v2.tauri.app/reference/javascript/log/#recordpayload
*/
type recordPayload = {
  /** Log level — pattern-match on `LogLevel.Error` / `LogLevel.Warn`. */
  level: LogLevel.t,
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
