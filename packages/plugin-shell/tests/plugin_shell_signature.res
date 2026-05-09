// Type-level signature test for PluginShell. Compilation success =
// every public symbol of `PluginShell` matches its documented
// signature.

// ---- Top-level types ----
let _check_spawn_options: PluginShell.spawnOptions = {
  cwd: ?None,
  env: ?None,
  encoding: ?None,
}

let _check_terminated_payload: PluginShell.terminatedPayload = {
  code: Nullable.null,
  signal: Nullable.null,
}

// childProcess<'o> is generic; instantiating with string here.
let _check_child_process_string: PluginShell.childProcess<string> = {
  code: Nullable.make(0),
  signal: Nullable.null,
  stdout: "",
  stderr: "",
}

// ---- Top-level functions ----
let _check_open_path: (string, ~openWith: string=?) => promise<unit> = PluginShell.openPath

// ---- Child ----
let _check_child_pid: PluginShell.Child.t => int = PluginShell.Child.pid
let _check_child_write: (PluginShell.Child.t, 'data) => promise<unit> = PluginShell.Child.write
let _check_child_kill: PluginShell.Child.t => promise<unit> = PluginShell.Child.kill

// ---- Command factories ----
let _check_create: (
  string,
  ~args: array<string>=?,
  ~options: PluginShell.spawnOptions=?,
) => PluginShell.Command.t<string> = PluginShell.Command.create

let _check_create_raw: (
  string,
  ~args: array<string>=?,
  ~options: PluginShell.spawnOptions=?,
) => PluginShell.Command.t<Uint8Array.t> = PluginShell.Command.createRaw

let _check_sidecar: (
  string,
  ~args: array<string>=?,
  ~options: PluginShell.spawnOptions=?,
) => PluginShell.Command.t<string> = PluginShell.Command.sidecar

let _check_sidecar_raw: (
  string,
  ~args: array<string>=?,
  ~options: PluginShell.spawnOptions=?,
) => PluginShell.Command.t<Uint8Array.t> = PluginShell.Command.sidecarRaw

// ---- Command lifecycle ----
let _check_command_spawn: PluginShell.Command.t<'o> => promise<PluginShell.Child.t> =
  PluginShell.Command.spawn

let _check_command_execute: PluginShell.Command.t<'o> => promise<PluginShell.childProcess<'o>> =
  PluginShell.Command.execute

// ---- Command event helpers ----
let _check_on_close: (
  PluginShell.Command.t<'o>,
  PluginShell.terminatedPayload => unit,
) => PluginShell.Command.t<'o> = PluginShell.Command.onClose

let _check_on_error: (
  PluginShell.Command.t<'o>,
  string => unit,
) => PluginShell.Command.t<'o> = PluginShell.Command.onError

let _check_on_stdout_data: (
  PluginShell.Command.t<'o>,
  'o => unit,
) => PluginShell.Command.t<'o> = PluginShell.Command.onStdoutData

let _check_on_stderr_data: (
  PluginShell.Command.t<'o>,
  'o => unit,
) => PluginShell.Command.t<'o> = PluginShell.Command.onStderrData

let _check_remove_all_listeners: PluginShell.Command.t<'o> => PluginShell.Command.t<'o> =
  PluginShell.Command.removeAllListeners

let _check_stdout: PluginShell.Command.t<'o> => PluginShell.EventEmitter.t<{"data": 'o}> =
  PluginShell.Command.stdout
let _check_stderr: PluginShell.Command.t<'o> => PluginShell.EventEmitter.t<{"data": 'o}> =
  PluginShell.Command.stderr

// ---- EventEmitter generic methods ----
let _check_ee_add_listener: (
  PluginShell.EventEmitter.t<'events>,
  string,
  'payload => unit,
) => PluginShell.EventEmitter.t<'events> = PluginShell.EventEmitter.addListener

let _check_ee_remove_listener: (
  PluginShell.EventEmitter.t<'events>,
  string,
  'payload => unit,
) => PluginShell.EventEmitter.t<'events> = PluginShell.EventEmitter.removeListener

let _check_ee_on: (
  PluginShell.EventEmitter.t<'events>,
  string,
  'payload => unit,
) => PluginShell.EventEmitter.t<'events> = PluginShell.EventEmitter.on

let _check_ee_once: (
  PluginShell.EventEmitter.t<'events>,
  string,
  'payload => unit,
) => PluginShell.EventEmitter.t<'events> = PluginShell.EventEmitter.once

let _check_ee_off: (
  PluginShell.EventEmitter.t<'events>,
  string,
  'payload => unit,
) => PluginShell.EventEmitter.t<'events> = PluginShell.EventEmitter.off

let _check_ee_remove_all: (
  PluginShell.EventEmitter.t<'events>,
  ~event: string=?,
) => PluginShell.EventEmitter.t<'events> = PluginShell.EventEmitter.removeAllListeners

let _check_ee_listener_count: (PluginShell.EventEmitter.t<'events>, string) => int =
  PluginShell.EventEmitter.listenerCount

let _check_ee_prepend_listener: (
  PluginShell.EventEmitter.t<'events>,
  string,
  'payload => unit,
) => PluginShell.EventEmitter.t<'events> = PluginShell.EventEmitter.prependListener

let _check_ee_prepend_once_listener: (
  PluginShell.EventEmitter.t<'events>,
  string,
  'payload => unit,
) => PluginShell.EventEmitter.t<'events> = PluginShell.EventEmitter.prependOnceListener
