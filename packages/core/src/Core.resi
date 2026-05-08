module Raw: {
  /** Optional headers passed alongside the IPC call. */
  type invokeOptions = {headers?: Dict.t<string>}

  /** Calls a Tauri command on the Rust backend.

      This is the **Layer 1 (Raw)** binding — a near-1:1 mirror of
      `@tauri-apps/api/core`'s `invoke`. Use it when you want the
      lightest possible binding or as an escape hatch from the typed
      `Core.Command` layer.

      The return type is fully polymorphic; the caller is responsible
      for narrowing it via a type annotation. Promise rejection from
      the Rust side surfaces as a thrown `exn` when awaited, matching
      the JS API behavior exactly.

      See: https://v2.tauri.app/develop/calling-rust/

      ## Example

      ```rescript
      let greeting: string =
        await Tauri.Core.Raw.invoke("greet", ~args={"name": "World"})
      ```
  */
  let invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result>

  /** Converts a file path into a URL accessible by the webview.

      Tauri's protocol scheme (`asset://`, `https://asset.localhost/...`)
      differs across operating systems; `convertFileSrc` returns the
      right URL for the current platform. Pass an explicit `protocol`
      to override the default `asset` scheme — for example `stream` or
      a custom protocol registered via the Tauri config.

      See: https://v2.tauri.app/reference/javascript/api/namespacecore/#convertfilesrc

      ## Example

      ```rescript
      let url = Tauri.Core.Raw.convertFileSrc("/Users/me/photo.png")
      ```
  */
  let convertFileSrc: (string, ~protocol: string=?) => string
}

/** Maps a raw IPC JSON payload to a typed value. Used by `Command`,
    `Channel`, and `Event` for decoder definitions; re-exported so the
    Phase 2 `Schema` package can target it from its schema-derived
    decoders. */
type decoder<'value> = JSON.t => result<'value, string>

/** Internal: decode a raw JSON payload and forward the `result` to a
    user callback. Shared by `Channel.onMessage` and `Event._wrap` so
    decode-then-dispatch lives in one place. Public to allow
    intra-package access; not part of the stable user-facing API. */
let _applyDecoder: (decoder<'a>, JSON.t, result<'a, string> => unit) => unit

/** Errors surfaced by the typed `Command` layer. */
type invokeError =
  /** The Rust call succeeded but `decodeResult` could not interpret
      the returned JSON. The string is the decoder's error message. */
  | DecodeError(string)
  /** The Rust handler rejected the promise. The payload is the raw
      value Tauri rejected with (typically a string or a JSON object). */
  | RustError(JSON.t)

module Command: {
  /** A typed handle to a single Rust command. */
  type t<'args, 'result>

  /** Declares one Rust command with its encoder and decoder.

      Centralizes the contract with the Rust backend in a single
      declaration per command, and decouples the encoder/decoder
      from any specific schema library so the core stays
      dependency-free.

      See: https://v2.tauri.app/develop/calling-rust/

      ## Example

      ```rescript
      let greet = Core.Command.make(
        ~name="greet",
        ~encodeArgs=({name}) =>
          JSON.Encode.object([("name", JSON.Encode.string(name))]),
        ~decodeResult=json =>
          switch json->JSON.Decode.string {
          | Some(s) => Ok(s)
          | None => Error("expected string")
          },
      )
      ```
  */
  let make: (
    ~name: string,
    ~encodeArgs: 'args => JSON.t,
    ~decodeResult: decoder<'result>,
  ) => t<'args, 'result>

  /** Runs the command. Returns:
      - `Ok(value)` when both the Rust call and the decoder succeed.
      - `Error(DecodeError(msg))` when the Rust side returned but the
        decoder could not interpret the JSON.
      - `Error(RustError(json))` when the Rust handler rejected.
  */
  let invoke: (
    t<'args, 'result>,
    'args,
    ~options: Raw.invokeOptions=?,
  ) => promise<result<'result, invokeError>>

  /** Like `invoke` but raises on failure. The original Rust-side
      rejection propagates as a thrown `exn`; decode failures are
      raised as a JS `Error` with a descriptive message. */
  let invokeExn: (
    t<'args, 'result>,
    'args,
    ~options: Raw.invokeOptions=?,
  ) => promise<'result>
}

module Channel: {
  /** A typed handle to a Tauri Channel — a one-way streaming bridge
      from Rust to the frontend.

      Pass the channel as an argument to a `Command.invoke` call; the
      Rust side calls `channel.send(...)` and each call surfaces here
      via the callback registered with `onMessage`.

      Decoder failures (Rust sends a value that `decode` cannot
      interpret) are silently dropped on purpose: a malformed message
      is an infrastructure issue, and surfacing it through the user
      callback would force every call site to handle a parallel
      error channel.

      See: https://v2.tauri.app/develop/calling-rust/#channels
  */
  type t<'message>

  /** Creates a new Channel handle with its decoder. The underlying
      JS Channel is constructed eagerly so the Rust side can be told
      the channel id immediately. */
  let make: (~decode: decoder<'message>) => t<'message>

  /** Registers (or replaces) the message handler. Tauri delivers each
      Rust-side `channel.send(...)` here. */
  let onMessage: (t<'message>, 'message => unit) => unit

  /** Returns the integer id of the underlying JS Channel, useful when
      correlating with Rust-side logs. */
  let id: t<'message> => int
}
