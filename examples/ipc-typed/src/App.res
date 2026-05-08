// rescript-tauri ipc-typed example.
//
// Declares two Rust commands once via Core.Command.make and exercises
// the full result<_, invokeError> error path on each invocation.

open RescriptTauriCore.Tauri

@val external document: 'a = "document"

// Layer 2: typed command for `fn greet(name: &str) -> String`.
let greet = Core.Command.make(
  ~name="greet",
  ~encodeArgs=(name: string) => JSON.Encode.object(Dict.fromArray([("name", JSON.Encode.string(name))])),
  ~decodeResult=json =>
    switch json->JSON.Decode.string {
    | Some(s) => Ok(s)
    | None => Error("expected string")
    },
)

// Layer 2: typed command for `fn add(a: i32, b: i32) -> i32`.
type addArgs = {a: int, b: int}

let add = Core.Command.make(
  ~name="add",
  ~encodeArgs=({a, b}: addArgs) =>
    JSON.Encode.object(
      Dict.fromArray([
        ("a", JSON.Encode.float(Int.toFloat(a))),
        ("b", JSON.Encode.float(Int.toFloat(b))),
      ]),
    ),
  ~decodeResult=json =>
    switch json->JSON.Decode.float {
    | Some(f) => Ok(Float.toInt(f))
    | None => Error("expected number")
    },
)

let invokeErrorToString = (err: Core.invokeError): string =>
  switch err {
  | DecodeError(msg) => "decode error: " ++ msg
  | RustError(payload) => "rust error: " ++ JSON.stringify(payload)
  }

let runGreet = async () => {
  let name = document["getElementById"]("name")["value"]
  let out = document["getElementById"]("greet-out")
  switch await greet->Core.Command.invoke(name) {
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

let main = (): unit => {
  let _ = document["getElementById"]("run-greet")["addEventListener"]("click", () => {
    let _ = runGreet()
  })
  let _ = document["getElementById"]("run-add")["addEventListener"]("click", () => {
    let _ = runAdd()
  })
}

main()
