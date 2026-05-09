module Raw = {
  type invokeOptions = {headers?: Dict.t<string>}

  @module("@tauri-apps/api/core")
  external invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result> =
    "invoke"

  @module("@tauri-apps/api/core")
  external convertFileSrc: (string, ~protocol: string=?) => string = "convertFileSrc"
}

@module("@tauri-apps/api/core")
external isTauri: unit => bool = "isTauri"

module Resource = {
  type t

  @get external rid: t => int = "rid"
  @send external close: t => promise<unit> = "close"
}

module PluginListener = {
  type t

  @get external plugin: t => string = "plugin"
  @get external event: t => string = "event"
  @get external channelId: t => int = "channelId"
  @send external unregister: t => promise<unit> = "unregister"
}

@module("@tauri-apps/api/core")
external addPluginListener: (
  string,
  string,
  'payload => unit,
) => promise<PluginListener.t> = "addPluginListener"

type permissionState = [#granted | #denied | #prompt | #"prompt-with-rationale"]

@module("@tauri-apps/api/core")
external checkPermissions: string => promise<'state> = "checkPermissions"

@module("@tauri-apps/api/core")
external requestPermissions: string => promise<'state> = "requestPermissions"

module LowLevel = {
  @module("@tauri-apps/api/core")
  external serializeToIpcFn: string = "SERIALIZE_TO_IPC_FN"

  @module("@tauri-apps/api/core")
  external transformCallback: (~callback: 'response => unit=?, ~once: bool=?) => int =
    "transformCallback"
}

/** Maps a raw IPC JSON payload to a typed value. Used by `Command`,
    `Channel`, and `Event` for decoder definitions, and re-used by the
    Phase 2 `Schema` package as the target type for schema-derived
    decoders. */
type decoder<'value> = JSON.t => result<'value, string>

type invokeError =
  | DecodeError(string)
  | RustError(JSON.t)

/** Intra-package helpers. NOT part of the stable public API; do not
    depend on the shape of `Internal` outside `@rescript-tauri/core`. */
module Internal = {
  /** Decode a raw JSON payload and forward the result to a user
      callback. Shared by `Channel.onMessage` and `Event._wrap` so the
      decode-then-dispatch pattern lives in one place. */
  let applyDecoder = (
    decoder: decoder<'a>,
    raw: JSON.t,
    callback: result<'a, string> => unit,
  ): unit => callback(decoder(raw))

  /** Convert a caught JS exception to a JSON value used as the payload
      of `RustError`. JS `Error` objects are encoded as `{name, message}`;
      non-`Error` exceptions fall back to a string marker. */
  let exnToJson = (exn: exn): JSON.t =>
    switch exn->JsExn.fromException {
    | Some(jsExn) =>
      Dict.fromArray([
        ("name", JSON.Encode.string(jsExn->JsExn.name->Option.getOr("Error"))),
        ("message", JSON.Encode.string(jsExn->JsExn.message->Option.getOr(""))),
      ])->JSON.Encode.object
    | None => JSON.Encode.string("(non-Error exception)")
    }
}

module Command = {
  type t<'args, 'result> = {
    name: string,
    encodeArgs: 'args => JSON.t,
    decodeResult: decoder<'result>,
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
    | exn => Error(RustError(Internal.exnToJson(exn)))
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
    decode: decoder<'message>,
  }

  @module("@tauri-apps/api/core") @new
  external _make: unit => internal = "Channel"

  @set external _setOnmessage: (internal, JSON.t => unit) => unit = "onmessage"

  @get external _getId: internal => int = "id"

  let make = (~decode) => {
    instance: _make(),
    decode,
  }

  let onMessage = (chan, callback) =>
    chan.instance->_setOnmessage(raw => Internal.applyDecoder(chan.decode, raw, callback))

  let id = chan => chan.instance->_getId
}
