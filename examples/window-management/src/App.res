// rescript-tauri window-management example.
//
// Demonstrates Window / WebviewWindow operations with @rescript-tauri/core.
// Each button wires a UI action to the corresponding Tauri API.

open RescriptTauriCore.Tauri

@val external document: 'a = "document"

let setStatus = (msg: string): unit => {
  let el = document["getElementById"]("status")
  el["textContent"] = msg
  ()
}

let onClick = (id: string, handler: unit => promise<unit>): unit => {
  let el = document["getElementById"](id)
  let _ = el["addEventListener"](
    "click",
    () => {
      let _ = handler()->Promise.catch(err => {
        setStatus("error: " ++ JSON.stringifyAny(err)->Option.getOr("(no detail)"))
        Promise.resolve()
      })
    },
  )
}

let main = () => {
  let win = Window.getCurrent()

  onClick("title", async () => {
    let n = Math.random()->Float.toString
    await win->Window.setTitle("rescript-tauri title " ++ n)
    setStatus("title updated to " ++ n)
  })

  onClick("maximize", async () => {
    await win->Window.maximize
    setStatus("maximized")
  })

  onClick("unmaximize", async () => {
    await win->Window.unmaximize
    setStatus("unmaximized")
  })

  onClick("minimize", async () => {
    await win->Window.minimize
    setStatus("minimized — click in the dock / taskbar to restore")
  })

  onClick("center", async () => {
    await win->Window.center
    setStatus("centered")
  })

  onClick("size-small", async () => {
    let size =
      RescriptTauriCore.Dpi.LogicalSize.make(~width=800.0, ~height=600.0)
      ->RescriptTauriCore.Dpi.Size.fromLogical
    await win->Window.setSize(size)
    setStatus("size = 800x600")
  })

  onClick("size-large", async () => {
    let size =
      RescriptTauriCore.Dpi.LogicalSize.make(~width=1200.0, ~height=900.0)
      ->RescriptTauriCore.Dpi.Size.fromLogical
    await win->Window.setSize(size)
    setStatus("size = 1200x900")
  })

  let secondLabel = "secondary"

  onClick("open-second", async () => {
    let _ = WebviewWindow.make(
      secondLabel,
      ~options={
        url: "index.html",
        title: "Secondary window",
        width: 480.0,
        height: 320.0,
      },
    )
    setStatus("opened secondary window (label: " ++ secondLabel ++ ")")
  })

  onClick("close-second", async () => {
    switch await WebviewWindow.getByLabel(secondLabel)->Promise.then(value =>
      Promise.resolve(value->Nullable.toOption)
    ) {
    | Some(w) =>
      await w->WebviewWindow.close
      setStatus("closed secondary window")
    | None => setStatus("no secondary window to close")
    }
  })
}

main()
