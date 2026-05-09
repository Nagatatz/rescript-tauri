type spawnOptions = {
  cwd?: string,
  env?: Dict.t<string>,
  encoding?: string,
}

type childProcess<'o> = {
  code: Nullable.t<int>,
  signal: Nullable.t<int>,
  stdout: 'o,
  stderr: 'o,
}

type terminatedPayload = {
  code: Nullable.t<int>,
  signal: Nullable.t<int>,
}

@module("@tauri-apps/plugin-shell")
external openPath: (string, ~openWith: string=?) => promise<unit> = "open"

module EventEmitter = {
  type t<'events>

  @send
  external addListener: (t<'events>, string, 'payload => unit) => t<'events> = "addListener"

  @send
  external removeListener: (t<'events>, string, 'payload => unit) => t<'events> = "removeListener"

  @send
  external on: (t<'events>, string, 'payload => unit) => t<'events> = "on"

  @send
  external once: (t<'events>, string, 'payload => unit) => t<'events> = "once"

  @send
  external off: (t<'events>, string, 'payload => unit) => t<'events> = "off"

  @send
  external removeAllListeners: (t<'events>, ~event: string=?) => t<'events> = "removeAllListeners"

  @send external listenerCount: (t<'events>, string) => int = "listenerCount"

  @send
  external prependListener: (t<'events>, string, 'payload => unit) => t<'events> = "prependListener"

  @send
  external prependOnceListener: (t<'events>, string, 'payload => unit) => t<'events> =
    "prependOnceListener"
}

module Child = {
  type t

  @get external pid: t => int = "pid"

  @send external write: (t, 'data) => promise<unit> = "write"

  @send external kill: t => promise<unit> = "kill"
}

module Command = {
  type t<'o>

  @scope("Command") @module("@tauri-apps/plugin-shell")
  external create: (string, ~args: array<string>=?, ~options: spawnOptions=?) => t<string> =
    "create"

  // Internal: positional 3-arg form to force `encoding: "raw"` and
  // surface the `Uint8Array.t` return type statically.
  @scope("Command") @module("@tauri-apps/plugin-shell")
  external _createRaw: (string, array<string>, spawnOptions) => t<Uint8Array.t> = "create"

  let createRaw = (program, ~args=[], ~options: spawnOptions={}) => {
    let withRaw: spawnOptions = {...options, encoding: "raw"}
    _createRaw(program, args, withRaw)
  }

  @scope("Command") @module("@tauri-apps/plugin-shell")
  external sidecar: (string, ~args: array<string>=?, ~options: spawnOptions=?) => t<string> =
    "sidecar"

  @scope("Command") @module("@tauri-apps/plugin-shell")
  external _sidecarRaw: (string, array<string>, spawnOptions) => t<Uint8Array.t> = "sidecar"

  let sidecarRaw = (program, ~args=[], ~options: spawnOptions={}) => {
    let withRaw: spawnOptions = {...options, encoding: "raw"}
    _sidecarRaw(program, args, withRaw)
  }

  @send external spawn: t<'o> => promise<Child.t> = "spawn"

  @send external execute: t<'o> => promise<childProcess<'o>> = "execute"

  // The Command class extends EventEmitter<{close, error}> upstream.
  // We expose typed helpers for the two named events plus a generic
  // removeAllListeners.
  @send
  external _onCloseEvent: (t<'o>, string, terminatedPayload => unit) => t<'o> = "on"

  let onClose = (cmd, handler) => _onCloseEvent(cmd, "close", handler)

  @send
  external _onErrorEvent: (t<'o>, string, string => unit) => t<'o> = "on"

  let onError = (cmd, handler) => _onErrorEvent(cmd, "error", handler)

  @get external stdout: t<'o> => EventEmitter.t<{"data": 'o}> = "stdout"
  @get external stderr: t<'o> => EventEmitter.t<{"data": 'o}> = "stderr"

  let onStdoutData = (cmd: t<'o>, handler: 'o => unit): t<'o> => {
    let _ = stdout(cmd)->EventEmitter.on("data", handler)
    cmd
  }

  let onStderrData = (cmd: t<'o>, handler: 'o => unit): t<'o> => {
    let _ = stderr(cmd)->EventEmitter.on("data", handler)
    cmd
  }

  @send external _removeAllListeners: t<'o> => t<'o> = "removeAllListeners"

  let removeAllListeners = cmd => _removeAllListeners(cmd)
}
