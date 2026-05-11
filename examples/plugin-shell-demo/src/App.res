// rescript-tauri plugin-shell example.
//
// Wires every public function of @rescript-tauri/plugin-shell to a
// button so the full surface (openPath / Command / Child /
// EventEmitter chains) can be exercised inside a real Tauri 2.x app.

open RescriptTauriPluginShell

@val external document: 'a = "document"

// Helper: write `text` to the result <pre>.
let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

// Helper: wrap an async handler so a thrown exn becomes a readable
// result line instead of an unhandled rejection.
let safe = (label: string, body: unit => promise<unit>): unit => {
  let _ =
    body()->Promise.catch(err => {
      Console.error2(label, err)
      let serialized =
        err->Obj.magic->JSON.stringifyAny->Option.getOr("(non-serializable)")
      setResult(label ++ " failed: " ++ serialized)
      Promise.resolve()
    })
}

// Helper: nullable<int> to "n" / "null" for display.
let nullableIntToString = (v: Nullable.t<int>): string =>
  switch v->Nullable.toOption {
  | Some(n) => Int.toString(n)
  | None => "null"
  }

// ----- openPath -----

let runOpenUrl = async () => {
  await PluginShell.openPath("https://tauri.app/")
  setResult("openPath('https://tauri.app/') resolved")
}

let runOpenWithFirefox = async () => {
  // `^https?://` is allowlisted under shell:allow-open. The
  // ~openWith hint is best-effort; if firefox is unavailable the
  // upstream call rejects and `safe` reports it.
  await PluginShell.openPath(
    "https://github.com/tauri-apps/tauri",
    ~openWith="firefox",
  )
  setResult("openPath(~openWith='firefox') resolved")
}

// ----- Command.execute (utf8) -----

let runExecuteUtf8 = async () => {
  let cmd = PluginShell.Command.create("echo", ~args=["hello", "rescript-tauri"])
  let output = await cmd->PluginShell.Command.execute
  setResult(
    "code="
      ++ nullableIntToString(output.code)
      ++ " signal="
      ++ nullableIntToString(output.signal)
      ++ "\nstdout: "
      ++ output.stdout
      ++ "\nstderr: "
      ++ output.stderr,
  )
}

// ----- Command.execute (raw) -----

let runExecuteRaw = async () => {
  let cmd = PluginShell.Command.createRaw("echo", ~args=["hello"])
  let output = await cmd->PluginShell.Command.execute
  let stdoutLen = TypedArray.length(output.stdout)
  let stderrLen = TypedArray.length(output.stderr)
  setResult(
    "raw stdout bytes: "
      ++ Int.toString(stdoutLen)
      ++ " / stderr bytes: "
      ++ Int.toString(stderrLen),
  )
}

// ----- spawn + Child -----

let runSpawnCat = async () => {
  let cmd = PluginShell.Command.create("cat")
  let child = await cmd->PluginShell.Command.spawn
  let pid = PluginShell.Child.pid(child)
  await child->PluginShell.Child.write("hello from rescript-tauri\n")
  await child->PluginShell.Child.kill
  setResult("spawned cat pid=" ++ Int.toString(pid) ++ ", wrote line, killed")
}

// ----- streaming events -----

// Keep the most recent streaming command so the "removeAllListeners"
// button can address it.
let streamCmdRef: ref<option<PluginShell.Command.t<string>>> = ref(None)

let runStreamEcho = async () => {
  let lines = ref([])
  let cmd =
    PluginShell.Command.create("echo", ~args=["line one", "line two"])
    ->PluginShell.Command.onStdoutData(line => {
      lines := Array.concat(lines.contents, [line])
      Console.log2("stdout:", line)
    })
    ->PluginShell.Command.onStderrData(line => Console.log2("stderr:", line))
    ->PluginShell.Command.onClose(payload => {
      let stdout = Array.join(lines.contents, "")
      setResult(
        "closed code="
          ++ nullableIntToString(payload.code)
          ++ " signal="
          ++ nullableIntToString(payload.signal)
          ++ "\ncollected stdout: "
          ++ stdout,
      )
    })
    ->PluginShell.Command.onError(err => Console.error2("stream error:", err))
  streamCmdRef := Some(cmd)
  let _child = await cmd->PluginShell.Command.spawn
}

let runStreamRemove = async () => {
  switch streamCmdRef.contents {
  | Some(cmd) =>
    let _ = cmd->PluginShell.Command.removeAllListeners
    setResult("removeAllListeners called on streaming command")
  | None => setResult("no streaming command active yet")
  }
}

// ----- type-only references for sidecar variants -----
// Sidecar binaries are out of scope (no binary bundled). Bind the
// factory variants so the symbols stay reachable from this demo for
// readers comparing API shapes.
let _demoSidecar: PluginShell.Command.t<string> =
  PluginShell.Command.sidecar("placeholder")
let _demoSidecarRaw: PluginShell.Command.t<Uint8Array.t> =
  PluginShell.Command.sidecarRaw("placeholder")

// ----- low-level EventEmitter reachability -----
// Reference `Command.stdout` so readers can find the path from
// `Command.t` to the underlying EventEmitter. Not invoked at runtime.
let _demoStdoutEmitter = (cmd: PluginShell.Command.t<string>): unit => {
  let emitter = PluginShell.Command.stdout(cmd)
  let _ =
    emitter
    ->PluginShell.EventEmitter.on("data", _payload => ())
    ->PluginShell.EventEmitter.once("data", _payload => ())
    ->PluginShell.EventEmitter.removeAllListeners(~event="data")
}

// ----- wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-open-url", runOpenUrl)
  bind("btn-open-with-firefox", runOpenWithFirefox)
  bind("btn-execute-utf8", runExecuteUtf8)
  bind("btn-execute-raw", runExecuteRaw)
  bind("btn-spawn-cat", runSpawnCat)
  bind("btn-stream-echo", runStreamEcho)
  bind("btn-stream-remove", runStreamRemove)
}

main()
