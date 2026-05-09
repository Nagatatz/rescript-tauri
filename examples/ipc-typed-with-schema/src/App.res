// rescript-tauri ipc-typed-with-schema example.
//
// Demonstrates @rescript-tauri/schema (Layer 3 IPC) by re-implementing
// the same `greet` / `add` commands as `examples/ipc-typed/` and
// adding `summarize` (record round-trip) plus a schema-decoded
// channel `count_to`. Read alongside `examples/ipc-typed/` to see
// how `Schema.fromSchemas` collapses the manual encoder/decoder pair
// into a single schema declaration.

open RescriptTauriCore.Tauri
open RescriptTauriSchema

@val external document: 'a = "document"

// ----- schema declarations -----

type greetArgs = {name: string}
type addArgs = {a: int, b: int}
type summarizeArgs = {title: string, items: array<string>}
type summary = {count: int, joined: string}

let greetArgsSchema: Schema.S.t<greetArgs> =
  Schema.S.object(s => {name: s.field("name", Schema.S.string)})

let addArgsSchema: Schema.S.t<addArgs> =
  Schema.S.object(s => {
    a: s.field("a", Schema.S.int),
    b: s.field("b", Schema.S.int),
  })

let summarizeArgsSchema: Schema.S.t<summarizeArgs> =
  Schema.S.object(s => {
    title: s.field("title", Schema.S.string),
    items: s.field("items", Schema.S.array(Schema.S.string)),
  })

let summarySchema: Schema.S.t<summary> =
  Schema.S.object(s => {
    count: s.field("count", Schema.S.int),
    joined: s.field("joined", Schema.S.string),
  })

// ----- typed commands -----

let greet = Schema.fromSchemas(
  ~name="greet",
  ~args=greetArgsSchema,
  ~result=Schema.S.string,
)

let add = Schema.fromSchemas(
  ~name="add",
  ~args=addArgsSchema,
  ~result=Schema.S.int,
)

let summarize = Schema.fromSchemas(
  ~name="summarize",
  ~args=summarizeArgsSchema,
  ~result=summarySchema,
)

// ----- channel: schema-decoded Channel<int> -----
//
// The receive side is schema-decoded via `Schema.channelFromSchema`.
// The Tauri command that opens the channel takes the channel handle
// itself as an argument; the channel handle is opaque to schemas, so
// the command stays declared with the legacy `Core.Command.make`.

type countArgs = {channel: Core.Channel.t<int>, target: int}

let countTo = Core.Command.make(
  ~name="count_to",
  ~encodeArgs=({channel, target}: countArgs) =>
    JSON.Encode.object(
      Dict.fromArray([
        ("channel", Obj.magic(channel)),
        ("target", JSON.Encode.float(Int.toFloat(target))),
      ]),
    ),
  ~decodeResult=_json => Ok(),
)

// ----- type-only references for full Schema API surface coverage -----

type appStatus = {state: string, uptimeMs: int}
let appStatusSchema = Schema.S.object(s => {
  state: s.field("state", Schema.S.string),
  uptimeMs: s.field("uptime_ms", Schema.S.int),
})
let appStatusEvent: Event.t<appStatus> =
  Schema.eventFromSchema(~name="app://status", ~schema=appStatusSchema)

let _stringDecoder: Core.decoder<string> = Schema.toDecoder(Schema.S.string)
let _ = appStatusEvent

// ----- helpers -----

let invokeErrorToString = (err: Core.invokeError): string =>
  switch err {
  | DecodeError(msg) => "decode error: " ++ msg
  | RustError(payload) => "rust error: " ++ JSON.stringify(payload)
  }

// ----- handlers -----

let runGreet = async () => {
  let name = document["getElementById"]("name")["value"]
  let out = document["getElementById"]("greet-out")
  switch await greet->Core.Command.invoke({name: name}) {
  | Ok(message) => out["textContent"] = message
  | Error(err) => out["textContent"] = invokeErrorToString(err)
  }
}

let runAdd = async () => {
  let a = Int.fromString(document["getElementById"]("a")["value"])->Option.getOr(0)
  let b = Int.fromString(document["getElementById"]("b")["value"])->Option.getOr(0)
  let out = document["getElementById"]("add-out")
  switch await add->Core.Command.invoke({a, b}) {
  | Ok(sum) => out["textContent"] = Int.toString(sum)
  | Error(err) => out["textContent"] = invokeErrorToString(err)
  }
}

let runSummarize = async () => {
  let title: string = document["getElementById"]("title")["value"]
  let raw: string = document["getElementById"]("items")["value"]
  let items =
    raw
    ->String.split("\n")
    ->Array.map(String.trim)
    ->Array.filter(line => line !== "")
  let out = document["getElementById"]("summarize-out")
  switch await summarize->Core.Command.invoke({title, items}) {
  | Ok({count, joined}) =>
    out["textContent"] = "count=" ++ Int.toString(count) ++ "\njoined=" ++ joined
  | Error(err) => out["textContent"] = invokeErrorToString(err)
  }
}

let runCountTo = () => {
  let log = document["getElementById"]("channel-out")
  let last = document["getElementById"]("channel-last")
  log["textContent"] = ""
  last["textContent"] = "-"

  let appendLine = (msg: string) => {
    log["textContent"] = log["textContent"] ++ msg ++ "\n"
  }

  // Schema-decoded channel: each message JSON is parsed via
  // `Schema.S.int`. Decode failures surface as `Error(string)`.
  let countChannel = Schema.channelFromSchema(~message=Schema.S.int)

  Core.Channel.onMessage(countChannel, result =>
    switch result {
    | Ok(value) =>
      last["textContent"] = Int.toString(value)
      appendLine("recv " ++ Int.toString(value))
    | Error(msg) => appendLine("decode error: " ++ msg)
    }
  )

  let target =
    Int.fromString(document["getElementById"]("target")["value"])->Option.getOr(5)

  let _ =
    countTo
    ->Core.Command.invoke({channel: countChannel, target})
    ->Promise.then(result => {
      switch result {
      | Ok () => appendLine("(stream finished)")
      | Error(err) => appendLine(invokeErrorToString(err))
      }
      Promise.resolve()
    })
}

// ----- wiring -----

let main = (): unit => {
  let _ =
    document["getElementById"]("run-greet")["addEventListener"]("click", () => {
      let _ = runGreet()
    })
  let _ =
    document["getElementById"]("run-add")["addEventListener"]("click", () => {
      let _ = runAdd()
    })
  let _ =
    document["getElementById"]("run-summarize")["addEventListener"]("click", () => {
      let _ = runSummarize()
    })
  let _ =
    document["getElementById"]("run-count-to")["addEventListener"]("click", () => {
      runCountTo()
    })
}

main()
