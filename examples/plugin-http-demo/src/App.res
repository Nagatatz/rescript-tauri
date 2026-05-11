// rescript-tauri plugin-http example.
//
// Drives `PluginHttp.fetch` in 4 step-shaped buttons against the
// public JSONPlaceholder mock REST API. The scoped `http:default`
// capability in `src-tauri/capabilities/default.json` allows
// requests to `https://jsonplaceholder.typicode.com/*` only.

open RescriptTauriPluginHttp

@val external document: 'a = "document"

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

let safe = (label: string, body: unit => promise<unit>): unit => {
  let _ =
    body()->Promise.catch(err => {
      Console.error2(label, err)
      setResult(
        label
        ++ " failed: "
        ++ err->Obj.magic->JSON.stringifyAny->Option.getOr("(non-serializable)"),
      )
      Promise.resolve()
    })
}

// ----- Step 1: Simple GET -----
//
// Fetches a single user from JSONPlaceholder, exercises the
// polymorphic `'response` via an inline structural type that
// captures only the fields the demo touches.
let runGet = async () => {
  let response: 'response =
    await PluginHttp.fetch("https://jsonplaceholder.typicode.com/users/1")
  let wrapped =
    (Obj.magic(response): {"json": unit => promise<'a>, "status": int})
  let status = wrapped["status"]
  let user = await wrapped["json"]()
  let name = (Obj.magic(user): {"name": string})["name"]
  setResult(
    "GET ok"
    ++ "\n  status = "
    ++ Int.toString(status)
    ++ "\n  user.name = "
    ++ name,
  )
}

// ----- wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-get", runGet)
}

main()
