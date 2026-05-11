// rescript-tauri plugin-log example.
//
// Wires every public function of @rescript-tauri/plugin-log to a
// button so the 5 log levels plus the attachLogger / attachConsole
// listeners can be exercised inside a real Tauri 2.x app.

open RescriptTauriPluginLog

@val external document: 'a = "document"

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

let appendResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  let current = el["textContent"]
  let next = current === "(no action yet)" ? text : current ++ "\n" ++ text
  el["textContent"] = next
}

let safe = (label: string, body: unit => promise<unit>): unit => {
  let _ =
    body()->Promise.catch(err => {
      Console.error2(label, err)
      let serialized =
        err->Obj.magic->JSON.stringifyAny->Option.getOr("(non-serializable)")
      appendResult(label ++ " failed: " ++ serialized)
      Promise.resolve()
    })
}

let levelToString = (level: PluginLog.LogLevel.t): string =>
  switch level {
  | Error => "ERROR"
  | Warn => "WARN"
  | Info => "INFO"
  | Debug => "DEBUG"
  | Trace => "TRACE"
  }

// Latest unlisten handles so the Detach button can call them.
let loggerUnlisten: ref<option<PluginLog.unlisten>> = ref(None)
let consoleUnlisten: ref<option<PluginLog.unlisten>> = ref(None)

// ----- log level buttons -----

let runError = async () => {
  await PluginLog.error("Sample error from rescript-tauri")
  appendResult("sent error")
}

let runWarn = async () => {
  await PluginLog.warn("Sample warning from rescript-tauri")
  appendResult("sent warn")
}

let runInfo = async () => {
  await PluginLog.info("Sample info from rescript-tauri")
  appendResult("sent info")
}

let runDebug = async () => {
  await PluginLog.debug("Sample debug from rescript-tauri")
  appendResult("sent debug")
}

let runTrace = async () => {
  await PluginLog.trace("Sample trace from rescript-tauri")
  appendResult("sent trace")
}

// ----- attachLogger / attachConsole / detach -----

let runAttachLogger = async () => {
  let un = await PluginLog.attachLogger(record => {
    appendResult("[" ++ levelToString(record.level) ++ "] " ++ record.message)
  })
  loggerUnlisten := Some(un)
  setResult("attachLogger: listening. Press log buttons to see records here.")
}

let runAttachConsole = async () => {
  let un = await PluginLog.attachConsole()
  consoleUnlisten := Some(un)
  appendResult("attachConsole: log records will also appear in the JS console")
}

let runDetach = async () => {
  switch loggerUnlisten.contents {
  | Some(un) => {
      un()
      loggerUnlisten := None
    }
  | None => ()
  }
  switch consoleUnlisten.contents {
  | Some(un) => {
      un()
      consoleUnlisten := None
    }
  | None => ()
  }
  appendResult("detached all listeners")
}

// ----- type-only references for option records -----
// Keep `logOptions` and the `recordPayload` shape reachable so
// readers can locate them without chasing through the .resi file.

let _demoLogOptions: PluginLog.logOptions = {
  file: "App.res",
  line: 1,
  keyValues: Dict.fromArray([("source", "rescript-tauri-demo")]),
}

let _demoFormatPayload = (r: PluginLog.recordPayload): string =>
  "[" ++ levelToString(r.level) ++ "] " ++ r.message

// ----- wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-log-error", runError)
  bind("btn-log-warn", runWarn)
  bind("btn-log-info", runInfo)
  bind("btn-log-debug", runDebug)
  bind("btn-log-trace", runTrace)
  bind("btn-attach-logger", runAttachLogger)
  bind("btn-attach-console", runAttachConsole)
  bind("btn-detach", runDetach)
}

main()
