// rescript-tauri plugin-fs example.
//
// Drives every public function of @rescript-tauri/plugin-fs in 5
// step-shaped buttons. All operations target the
// `$APPLOCALDATA/plugin-fs-demo/` sandbox so the demo runs without
// extra OS-level permissions.

open RescriptTauriPluginFs

@val external document: 'a = "document"

let demoDir = "plugin-fs-demo"
let textFile = "plugin-fs-demo/notes.txt"
let bytesFile = "plugin-fs-demo/bytes.bin"
let copiedFile = "plugin-fs-demo/notes.copy.txt"
let renamedFile = "plugin-fs-demo/notes.renamed.txt"

let baseDir = PluginFs.BaseDirectory.appLocalData

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

let safe = (label: string, body: unit => promise<unit>): unit => {
  let _ =
    body()->Promise.catch(err => {
      Console.error2(label, err)
      setResult(label ++ " failed: " ++ err->Obj.magic->JSON.stringifyAny->Option.getOr("(non-serializable)"))
      Promise.resolve()
    })
}

// ----- Step 1: Setup -----
//
// Creates the demo dir and lays down a text file plus a binary file
// (the four bytes spelling "Hi!\n").
let runSetup = async () => {
  await PluginFs.mkdir(demoDir, ~options={baseDir, recursive: true})
  await PluginFs.writeTextFile(
    textFile,
    "Hello from rescript-tauri plugin-fs.\nLine two.\n",
    ~options={baseDir, create: true},
  )
  let bytes = Uint8Array.fromArray([0x48, 0x69, 0x21, 0x0a]) // "Hi!\n"
  await PluginFs.writeFile(bytesFile, bytes, ~options={baseDir, create: true})
  setResult(
    "setup ok\n  mkdir " ++ demoDir ++ "\n  wrote " ++ textFile ++ "\n  wrote " ++ bytesFile,
  )
}

// ----- Step 2: Read back -----
//
// Confirms the files written by Step 1 with all read-side APIs.
let runRead = async () => {
  let textExists = await PluginFs.exists(textFile, ~options={baseDir: baseDir})
  let textBody = await PluginFs.readTextFile(textFile, ~options={baseDir: baseDir})
  let bytes = await PluginFs.readFile(bytesFile, ~options={baseDir: baseDir})
  let stat = await PluginFs.stat(textFile, ~options={baseDir: baseDir})
  // Layer 1 path string for `size` is the absolute path; in this
  // demo we resolve it via stat result rather than crossing the API
  // again. `size` is exercised against the bytes file using the
  // baseDir-relative form once Tauri >=2.7 supports it; here we use
  // a relative path and let the plugin resolve it.
  let byteSize = await PluginFs.size(bytesFile)
  setResult(
    "read ok"
    ++ "\n  exists(" ++ textFile ++ ") = " ++ (textExists ? "true" : "false")
    ++ "\n  readTextFile bytes = " ++ Int.toString(String.length(textBody))
    ++ "\n  readFile length = " ++ Int.toString(TypedArray.length(bytes))
    ++ "\n  stat.size = " ++ Float.toString(stat.size)
    ++ "\n  size(" ++ bytesFile ++ ") = " ++ Float.toString(byteSize)
    ++ "\n--- text body ---\n" ++ textBody,
  )
}

// ----- Step 3: Inspect directory -----
let runList = async () => {
  let entries = await PluginFs.readDir(demoDir, ~options={baseDir: baseDir})
  let lines = await entries->Array.map(async entry => {
    let path = demoDir ++ "/" ++ entry.name
    let info = await PluginFs.lstat(path, ~options={baseDir: baseDir})
    let kind =
      info.isDirectory ? "dir" : info.isSymlink ? "link" : info.isFile ? "file" : "other"
    "  " ++ entry.name ++ " [" ++ kind ++ ", " ++ Float.toString(info.size) ++ "B]"
  })->Promise.all
  setResult("readDir " ++ demoDir ++ ":\n" ++ Array.join(lines, "\n"))
}

// ----- Step 4: Modify -----
let runModify = async () => {
  await PluginFs.copyFile(textFile, copiedFile, ~options={fromPathBaseDir: baseDir, toPathBaseDir: baseDir})
  await PluginFs.rename(copiedFile, renamedFile, ~options={oldPathBaseDir: baseDir, newPathBaseDir: baseDir})
  await PluginFs.truncate(bytesFile, ~len=2, ~options={baseDir: baseDir})
  setResult(
    "modify ok"
    ++ "\n  copyFile -> " ++ copiedFile
    ++ "\n  rename -> " ++ renamedFile
    ++ "\n  truncate(" ++ bytesFile ++ ", len=2)",
  )
}

// ----- Step 5: Cleanup -----
let runCleanup = async () => {
  await PluginFs.remove(demoDir, ~options={baseDir, recursive: true})
  setResult("cleanup ok\n  removed " ++ demoDir ++ " (recursive)")
}

// ----- wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-setup", runSetup)
  bind("btn-read", runRead)
  bind("btn-list", runList)
  bind("btn-modify", runModify)
  bind("btn-cleanup", runCleanup)
}

main()
