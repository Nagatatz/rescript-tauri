/** Bindings for `@tauri-apps/plugin-shell` (Tauri 2.x shell plugin).

    Phase 2+ first iteration: 100% coverage of the stable public
    surface of `@tauri-apps/plugin-shell` v2.3.5. Covers the
    `Command` class (string- and raw-encoded variants, sidecar
    variants), `Child` process handle, the `EventEmitter` base
    class, and the top-level `openPath` function (renamed from the
    upstream `open` to avoid clashing with ReScript's `open`
    keyword).

    The TypeScript-level conditional return type of
    `Command.create({encoding: 'raw'})` is unrolled into
    `Command.create` / `Command.createRaw` / `Command.sidecar` /
    `Command.sidecarRaw` so result types stay static.

    See: https://v2.tauri.app/plugin/shell/
*/

/** Spawn options forwarded to upstream `Command.create` /
    `Command.sidecar`. `encoding` is auto-managed by the `Raw`
    variants — pass it through `options` only when calling
    `Command.create` directly with a custom value other than the
    default `"utf8"`.

    See: https://v2.tauri.app/reference/javascript/shell/#spawnoptions
*/
type spawnOptions = {
  /** Working directory for the spawned process. */
  cwd?: string,
  /** Environment variables. Setting this to an empty `Dict.t` clears
      the inherited env; upstream documents `null` for that case but
      ReScript exposes the empty-dict form. */
  env?: Dict.t<string>,
  /** Output encoding. Defaults to `"utf8"`. Pass `"raw"` (or use the
      `Raw` factory variants) to receive `Uint8Array.t` output. */
  encoding?: string,
}

/** Output collected from a finished command. `'o` is `string` for
    the default encoding, `Uint8Array.t` for raw encoding.

    See: https://v2.tauri.app/reference/javascript/shell/#childprocess
*/
type childProcess<'o> = {
  /** Exit code. `Nullable.null` if the process was terminated by a
      signal on Unix. */
  code: Nullable.t<int>,
  /** Signal that terminated the process (Unix only). `Nullable.null`
      otherwise. */
  signal: Nullable.t<int>,
  /** Captured stdout. */
  stdout: 'o,
  /** Captured stderr. */
  stderr: 'o,
}

/** Payload of the `Command` `"close"` event.

    See: https://v2.tauri.app/reference/javascript/shell/#terminatedpayload
*/
type terminatedPayload = {
  code: Nullable.t<int>,
  signal: Nullable.t<int>,
}

/** Opens a path or URL with the system's default application, or
    the one named by `~openWith` (`firefox`, `chromium`, `safari`,
    `xdg-open`, ...). The path is matched against the regex declared
    under `tauri.conf.json > plugins > shell > open`.

    Renamed from upstream `open` because the latter is reserved by
    ReScript.

    See: https://v2.tauri.app/reference/javascript/shell/#open
*/
let openPath: (string, ~openWith: string=?) => promise<unit>

/** Generic Tauri-style EventEmitter. Used directly by
    `Command.stdout` / `Command.stderr` (which carry `{data: 'o}`)
    and indirectly by `Command` itself (which carries
    `{close, error}` — see the dedicated `onClose` / `onError`
    helpers).

    Each method returns the receiver for chaining, mirroring the
    upstream `Promise<this>` pattern.

    See: https://v2.tauri.app/reference/javascript/shell/#eventemitter
*/
module EventEmitter: {
  /** Opaque handle. `'events` parameterizes the set of named events;
      it is informational — the runtime accepts any string name. */
  type t<'events>

  /** Alias for `on`. */
  let addListener: (t<'events>, string, 'payload => unit) => t<'events>

  /** Alias for `off`. */
  let removeListener: (t<'events>, string, 'payload => unit) => t<'events>

  /** Subscribes to `eventName`. The handler is fired every time the
      event is emitted. */
  let on: (t<'events>, string, 'payload => unit) => t<'events>

  /** Subscribes to `eventName` once; auto-detaches after the first
      emission. */
  let once: (t<'events>, string, 'payload => unit) => t<'events>

  /** Removes the handler from `eventName`'s subscriber list. */
  let off: (t<'events>, string, 'payload => unit) => t<'events>

  /** Removes all listeners. Pass `~event` to scope removal to one
      event name. */
  let removeAllListeners: (t<'events>, ~event: string=?) => t<'events>

  /** Number of listeners currently subscribed to `eventName`. */
  let listenerCount: (t<'events>, string) => int

  /** Adds the listener at the *beginning* of the listener list — it
      runs before listeners added with `on`. */
  let prependListener: (t<'events>, string, 'payload => unit) => t<'events>

  /** Adds a one-time listener at the *beginning* of the listener
      list. */
  let prependOnceListener: (t<'events>, string, 'payload => unit) => t<'events>
}

/** A spawned child process handle.

    See: https://v2.tauri.app/reference/javascript/shell/#child
*/
module Child: {
  type t

  /** The OS process id. */
  let pid: t => int

  /** Writes `data` to the child's stdin. Accepts `string`,
      `Uint8Array.t`, or `array<int>` matching upstream's
      `IOPayload | number[]`. */
  let write: (t, 'data) => promise<unit>

  /** Kills the child process. */
  let kill: t => promise<unit>
}

/** A buildable command. `'o` is `string` for default encoding,
    `Uint8Array.t` for raw encoding.

    See: https://v2.tauri.app/reference/javascript/shell/#command
*/
module Command: {
  /** Opaque command handle. */
  type t<'o>

  /** Builds a string-encoded command (default upstream behavior).

      `program` must be allowlisted in
      `tauri.conf.json > plugins > shell > scope`.

      See: https://v2.tauri.app/reference/javascript/shell/#create
  */
  let create: (string, ~args: array<string>=?, ~options: spawnOptions=?) => t<string>

  /** Builds a raw-bytes command (`encoding: "raw"`). The
      TypeScript-level conditional return type is split into a
      separate function so the `Uint8Array.t` result type is static. */
  let createRaw: (
    string,
    ~args: array<string>=?,
    ~options: spawnOptions=?,
  ) => t<Uint8Array.t>

  /** Sidecar variant. `program` is looked up in
      `tauri.conf.json > bundle > externalBin` rather than `PATH`.

      See: https://v2.tauri.app/reference/javascript/shell/#sidecar
  */
  let sidecar: (string, ~args: array<string>=?, ~options: spawnOptions=?) => t<string>

  /** Raw-encoded sidecar variant. */
  let sidecarRaw: (
    string,
    ~args: array<string>=?,
    ~options: spawnOptions=?,
  ) => t<Uint8Array.t>

  /** Spawns the command, returning a handle to the running process. */
  let spawn: t<'o> => promise<Child.t>

  /** Runs the command to completion and collects its output. */
  let execute: t<'o> => promise<childProcess<'o>>

  /** Subscribes to the `"close"` event. Returns the command for
      chaining. */
  let onClose: (t<'o>, terminatedPayload => unit) => t<'o>

  /** Subscribes to the `"error"` event. Returns the command for
      chaining. */
  let onError: (t<'o>, string => unit) => t<'o>

  /** Underlying stdout `EventEmitter`. Use this directly for
      advanced subscriptions; otherwise prefer `onStdoutData`. */
  let stdout: t<'o> => EventEmitter.t<{"data": 'o}>

  /** Underlying stderr `EventEmitter`. Use this directly for
      advanced subscriptions; otherwise prefer `onStderrData`. */
  let stderr: t<'o> => EventEmitter.t<{"data": 'o}>

  /** Subscribes to the stdout `"data"` event. Returns the command
      for chaining. */
  let onStdoutData: (t<'o>, 'o => unit) => t<'o>

  /** Subscribes to the stderr `"data"` event. Returns the command
      for chaining. */
  let onStderrData: (t<'o>, 'o => unit) => t<'o>

  /** Detaches every Command-level listener (close / error). For
      stdout / stderr listeners, use the `EventEmitter.removeAllListeners`
      method on the corresponding accessor. */
  let removeAllListeners: t<'o> => t<'o>
}
