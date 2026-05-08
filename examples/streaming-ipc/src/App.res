// rescript-tauri streaming-ipc example.
//
// Shows how to subscribe to a Tauri Channel for one-way streaming
// from Rust to the frontend without polling.

open RescriptTauriCore.Tauri

@val external document: 'a = "document"

// Layer 2: typed command for `fn count_to(channel: Channel<u32>, target: u32)`.
type countArgs<'channel> = {
  channel: 'channel,
  target: int,
}

let countTo = Core.Command.make(
  ~name="count_to",
  ~encodeArgs=({channel, target}: countArgs<'channel>) => {
    // Channel needs to flow through as the JS instance untouched; the
    // channel handle's identity is what Tauri wires up internally.
    let dict = Dict.fromArray([
      ("channel", Obj.magic(channel)),
      ("target", JSON.Encode.float(Int.toFloat(target))),
    ])
    JSON.Encode.object(dict)
  },
  ~decodeResult=_json => Ok(),
)

let main = () => {
  let log = document["getElementById"]("log")
  let last = document["getElementById"]("last")

  let appendLine = (msg: string) => {
    log["textContent"] = log["textContent"] ++ msg ++ "\n"
  }

  document["getElementById"]("start")["addEventListener"](
    "click",
    () => {
      log["textContent"] = ""
      last["textContent"] = "-"

      // Channel<u32> from Rust: numbers come through as JSON numbers.
      let channel = Core.Channel.make(~decode=json =>
        switch json->JSON.Decode.float {
        | Some(f) => Ok(Float.toInt(f))
        | None => Error("expected number")
        }
      )

      Core.Channel.onMessage(channel, value => {
        last["textContent"] = Int.toString(value)
        appendLine("recv " ++ Int.toString(value))
      })

      let target =
        Int.fromString(document["getElementById"]("target")["value"])->Option.getOr(10)

      let _ = countTo->Core.Command.invoke({channel: channel, target})->Promise.then(result => {
        switch result {
        | Ok(()) => appendLine("(stream finished)")
        | Error(DecodeError(msg)) => appendLine("decode error: " ++ msg)
        | Error(RustError(payload)) => appendLine("rust error: " ++ JSON.stringify(payload))
        }
        Promise.resolve()
      })
    },
  )
}

main()
