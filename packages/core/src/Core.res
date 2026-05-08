module Raw = {
  type invokeOptions = {headers?: Dict.t<string>}

  @module("@tauri-apps/api/core")
  external invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result> =
    "invoke"

  @module("@tauri-apps/api/core")
  external convertFileSrc: (string, ~protocol: string=?) => string = "convertFileSrc"
}

type invokeError =
  | DecodeError(string)
  | RustError(JSON.t)

/** Internal: convert a caught JS exception to a JSON value used as the
    payload of `RustError`. JS `Error` objects are encoded as
    `{name, message}`; non-`Error` exceptions fall back to their
    `Exn.toString` form. */
let _exnToJson = (exn: exn): JSON.t =>
  switch exn->JsExn.fromException {
  | Some(jsExn) =>
    Dict.fromArray([
      ("name", JSON.Encode.string(jsExn->JsExn.name->Option.getOr("Error"))),
      ("message", JSON.Encode.string(jsExn->JsExn.message->Option.getOr(""))),
    ])->JSON.Encode.object
  | None => JSON.Encode.string("(non-Error exception)")
  }

module Command = {
  type t<'args, 'result> = {
    name: string,
    encodeArgs: 'args => JSON.t,
    decodeResult: JSON.t => result<'result, string>,
  }

  let make = (~name, ~encodeArgs, ~decodeResult) => {name, encodeArgs, decodeResult}

  let invoke = async (cmd, args, ~options=?) => {
    let encoded = cmd.encodeArgs(args)
    try {
      let raw = await Raw.invoke(cmd.name, ~args=encoded, ~options?)
      switch cmd.decodeResult(raw) {
      | Ok(v) => Ok(v)
      | Error(msg) => Error(DecodeError(msg))
      }
    } catch {
    | exn => Error(RustError(_exnToJson(exn)))
    }
  }

  let invokeExn = async (cmd, args, ~options=?) => {
    let encoded = cmd.encodeArgs(args)
    let raw = await Raw.invoke(cmd.name, ~args=encoded, ~options?)
    switch cmd.decodeResult(raw) {
    | Ok(v) => v
    | Error(msg) => JsError.throwWithMessage("Core.Command decode error: " ++ msg)
    }
  }
}

module Channel = {
  type internal

  type t<'message> = {
    instance: internal,
    decode: JSON.t => result<'message, string>,
  }

  @module("@tauri-apps/api/core") @new
  external _make: unit => internal = "Channel"

  @set external _setOnmessage: (internal, JSON.t => unit) => unit = "onmessage"

  @get external _getId: internal => int = "id"

  let make = (~decode) => {
    instance: _make(),
    decode,
  }

  let onMessage = (chan, callback) => {
    chan.instance->_setOnmessage(raw =>
      switch chan.decode(raw) {
      | Ok(msg) => callback(msg)
      | Error(_) => ()
      }
    )
  }

  let id = chan => chan.instance->_getId
}
