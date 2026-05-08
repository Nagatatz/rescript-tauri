// rescript-tauri plugin-dialog example.
//
// Wires every public function of @rescript-tauri/plugin-dialog to a
// button so the full surface (open / save / message / ask / confirm)
// can be exercised inside a real Tauri 2.x app.

open RescriptTauriPluginDialog

@val external document: 'a = "document"

// Helper: write `text` to the result <pre>.
let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

// Helper: wrap an async dialog handler so a thrown exn becomes a
// readable result line instead of an unhandled rejection.
let safe = (label: string, body: unit => promise<unit>): unit => {
  let _ =
    body()->Promise.catch(err => {
      Console.error2(label, err)
      setResult(label ++ " failed: " ++ err->Obj.magic->JSON.stringifyAny->Option.getOr("(non-serializable)"))
      Promise.resolve()
    })
}

// ----- open* -----

// Single-file selection with a text-file filter to demonstrate
// `dialogFilter` + `openOptions`.
let runOpenFile = async () => {
  let opts: PluginDialog.openOptions = {
    title: "Pick a text file",
    filters: [{name: "Text", extensions: ["txt", "md", "log"]}],
  }
  let result = await PluginDialog.openFile(~options=opts)
  switch result->Nullable.toOption {
  | Some(path) => setResult("openFile picked: " ++ path)
  | None => setResult("openFile cancelled")
  }
}

let runOpenFiles = async () => {
  let opts: PluginDialog.openOptions = {title: "Pick one or more files"}
  let result = await PluginDialog.openFiles(~options=opts)
  switch result->Nullable.toOption {
  | Some(paths) =>
    setResult("openFiles picked " ++ Int.toString(Array.length(paths)) ++ " file(s):\n  " ++ Array.join(paths, "\n  "))
  | None => setResult("openFiles cancelled")
  }
}

let runOpenDirectory = async () => {
  let result = await PluginDialog.openDirectory()
  switch result->Nullable.toOption {
  | Some(path) => setResult("openDirectory picked: " ++ path)
  | None => setResult("openDirectory cancelled")
  }
}

let runOpenDirectories = async () => {
  let opts: PluginDialog.openOptions = {recursive: true}
  let result = await PluginDialog.openDirectories(~options=opts)
  switch result->Nullable.toOption {
  | Some(paths) =>
    setResult("openDirectories picked " ++ Int.toString(Array.length(paths)) ++ " dir(s):\n  " ++ Array.join(paths, "\n  "))
  | None => setResult("openDirectories cancelled")
  }
}

// ----- save -----

let runSave = async () => {
  let opts: PluginDialog.saveOptions = {
    title: "Save as",
    defaultPath: "untitled.txt",
    filters: [{name: "Text", extensions: ["txt"]}],
  }
  let result = await PluginDialog.save(~options=opts)
  switch result->Nullable.toOption {
  | Some(path) => setResult("save target: " ++ path)
  | None => setResult("save cancelled")
  }
}

// ----- message / ask / confirm -----

let runMessageInfo = async () => {
  let opts: PluginDialog.messageOptions = {
    title: "Notice",
    kind: #info,
    buttons: #Ok,
  }
  let label = await PluginDialog.message("Hello from rescript-tauri.", ~options=opts)
  setResult("message (info) returned: " ++ label)
}

let runMessageError = async () => {
  let opts: PluginDialog.messageOptions = {
    title: "Something went wrong",
    kind: #error,
    buttons: #OkCancel,
    okLabel: "Acknowledge",
  }
  let label = await PluginDialog.message("This is just a demo error dialog.", ~options=opts)
  setResult("message (error) returned: " ++ label)
}

let runAsk = async () => {
  let opts: PluginDialog.confirmOptions = {
    title: "Confirm action",
    kind: #warning,
    okLabel: "Yes, do it",
    cancelLabel: "Not now",
  }
  let answer = await PluginDialog.ask("Run the imaginary action?", ~options=opts)
  setResult("ask returned: " ++ (answer ? "yes" : "no"))
}

let runConfirm = async () => {
  let answer = await PluginDialog.confirm("Confirm with default OK / Cancel buttons?")
  setResult("confirm returned: " ++ (answer ? "yes" : "no"))
}

// ----- type-only references for mobile-only options -----
// These keep `pickerMode` / `fileAccessMode` reachable from the
// example so a reader can locate them without launching a mobile
// build.
let _demoPickerMode: option<PluginDialog.pickerMode> = Some(#document)
let _demoFileAccessMode: option<PluginDialog.fileAccessMode> = Some(#copy)

// ----- wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-open-file", runOpenFile)
  bind("btn-open-files", runOpenFiles)
  bind("btn-open-dir", runOpenDirectory)
  bind("btn-open-dirs", runOpenDirectories)
  bind("btn-save", runSave)
  bind("btn-message-info", runMessageInfo)
  bind("btn-message-error", runMessageError)
  bind("btn-ask", runAsk)
  bind("btn-confirm", runConfirm)
}

main()
