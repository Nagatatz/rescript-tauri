// rescript-tauri plugin-clipboard-manager example.
//
// Wires every public function of
// @rescript-tauri/plugin-clipboard-manager (writeText / readText /
// writeImage / readImage / writeHtml / clear) to a button so the
// full surface can be exercised from a real Tauri 2.x desktop app.

open RescriptTauriPluginClipboardManager
open RescriptTauriCore

@val external document: 'a = "document"

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

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

// Holds the latest Image.t obtained from `readImage` so the
// `writeImage` round-trip button can re-publish it.
let lastImage: ref<option<Image.t>> = ref(None)

// ----- writeText / readText -----

let runWriteText = async () => {
  await PluginClipboardManager.writeText("hello from rescript-tauri")
  setResult("writeText ok — clipboard now holds 'hello from rescript-tauri'")
}

let runReadText = async () => {
  let s = await PluginClipboardManager.readText()
  setResult("readText: " ++ s)
}

// ----- readImage / writeImage round-trip -----

let runReadImage = async () => {
  let img = await PluginClipboardManager.readImage()
  lastImage := Some(img)
  let bytes = await Image.rgba(img)
  setResult(
    "readImage ok — captured Image.t, "
      ++ Int.toString(TypedArray.length(bytes))
      ++ " RGBA bytes",
  )
}

let runWriteImageRoundtrip = async () => {
  switch lastImage.contents {
  | Some(img) =>
    await PluginClipboardManager.writeImage(img)
    setResult("writeImage round-trip ok — Image.t re-published to clipboard")
  | None =>
    setResult("Run `readImage` first to capture an Image.t into memory.")
  }
}

// ----- writeHtml -----

let runWriteHtml = async () => {
  await PluginClipboardManager.writeHtml(
    "<b>hello</b> from <i>rescript-tauri</i>",
    ~altText="hello from rescript-tauri",
  )
  setResult("writeHtml ok — clipboard now holds rich HTML with alt text")
}

// ----- clear -----

let runClear = async () => {
  await PluginClipboardManager.clear()
  setResult("clear ok — clipboard emptied")
}

// ----- type-only reference for writeTextOptions -----
// Keep the option record reachable so readers can locate it without
// chasing through the .resi file.
let _demoWriteTextOpts: PluginClipboardManager.writeTextOptions = {
  label: "rescript-tauri demo",
}

// ----- wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-write-text", runWriteText)
  bind("btn-read-text", runReadText)
  bind("btn-read-image", runReadImage)
  bind("btn-write-image-roundtrip", runWriteImageRoundtrip)
  bind("btn-write-html", runWriteHtml)
  bind("btn-clear", runClear)
}

main()
