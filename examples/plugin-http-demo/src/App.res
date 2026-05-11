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

// ----- Step 2: POST with JSON body -----
//
// Sends a JSON body to JSONPlaceholder's /posts endpoint. The
// service echoes the payload back with a freshly assigned `id`.
// The `~init` argument is a JS object literal mixing standard
// `RequestInit` fields (`method`, `headers`, `body`) with
// Tauri-specific `clientOptions` (none used here).
let runPost = async () => {
  let body = JSON.stringify(
    Dict.fromArray([
      ("title", JSON.Encode.string("rescript-tauri demo")),
      ("body", JSON.Encode.string("Hello from plugin-http-demo")),
      ("userId", JSON.Encode.float(1.0)),
    ])->JSON.Encode.object,
  )
  let response: 'response = await PluginHttp.fetch(
    "https://jsonplaceholder.typicode.com/posts",
    ~init={
      "method": "POST",
      "headers": {"content-type": "application/json"},
      "body": body,
    },
  )
  let wrapped =
    (Obj.magic(response): {"json": unit => promise<'a>, "status": int})
  let created = await wrapped["json"]()
  let id = (Obj.magic(created): {"id": float})["id"]
  setResult(
    "POST ok"
    ++ "\n  status = "
    ++ Int.toString(wrapped["status"])
    ++ "\n  created.id = "
    ++ Float.toString(id),
  )
}

// ----- Step 3: clientOptions demo -----
//
// Shows the Tauri-specific `~init` extensions (`connectTimeout`
// in ms, `maxRedirections`) being passed straight through. The
// values are validated by the Rust side; this step confirms that
// the demo compiles with them set.
let runClientOptions = async () => {
  let response: 'response = await PluginHttp.fetch(
    "https://jsonplaceholder.typicode.com/posts/1",
    ~init={
      "connectTimeout": 5000,
      "maxRedirections": 0,
    },
  )
  let wrapped = (Obj.magic(response): {"status": int})
  setResult(
    "clientOptions ok"
    ++ "\n  connectTimeout=5000ms  maxRedirections=0"
    ++ "\n  status = "
    ++ Int.toString(wrapped["status"]),
  )
}

// ----- Step 4: Headers & status inspection -----
//
// Pulls a richer slice off the response: status code, a single
// header via `headers.get(...)`, and the raw body text. The
// inline structural type captures every accessor up front so
// `Obj.magic` is only invoked once.
let runHeaders = async () => {
  let response: 'response =
    await PluginHttp.fetch("https://jsonplaceholder.typicode.com/posts/1")
  let wrapped =
    (Obj.magic(response): {
      "status": int,
      "headers": {"get": string => Nullable.t<string>},
      "text": unit => promise<string>,
    })
  let contentType =
    wrapped["headers"]["get"]("content-type")
    ->Nullable.toOption
    ->Option.getOr("(missing)")
  let body = await wrapped["text"]()
  let bodyLen = String.length(body)
  let previewLen = bodyLen < 60 ? bodyLen : 60
  let preview = String.slice(body, ~start=0, ~end=previewLen)
  setResult(
    "headers ok"
    ++ "\n  status = "
    ++ Int.toString(wrapped["status"])
    ++ "\n  content-type = "
    ++ contentType
    ++ "\n  body preview = "
    ++ preview
    ++ "...",
  )
}

// ----- wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-get", runGet)
  bind("btn-post", runPost)
  bind("btn-client-options", runClientOptions)
  bind("btn-headers", runHeaders)
}

main()
