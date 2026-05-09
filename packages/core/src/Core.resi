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

      **Security**: `~protocol` is intended for built-in or
      app-registered Tauri protocols (`asset`, `stream`, ...). Do not
      derive it from untrusted user input — combined with a custom
      protocol handler this would enable scheme confusion. Treat the
      returned URL as untrusted markup as well; insert it via DOM APIs
      (`element.src = url`) rather than `innerHTML` interpolation.

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

/** Intra-package helpers. **NOT** part of the stable public API; do not
    depend on its shape outside `@rescript-tauri/core`. */
module Internal: {
  /** Decode a raw JSON payload and forward the result to a user
      callback. Used by `Channel.onMessage` and `Event._wrap`. */
  let applyDecoder: (decoder<'a>, JSON.t, result<'a, string> => unit) => unit

  /** Convert a caught JS exception into a JSON value usable as the
      payload of `invokeError.RustError`. */
  let exnToJson: exn => JSON.t
}

/** Errors surfaced by the typed `Command` layer. */
type invokeError =
  /** The Rust call succeeded but `decodeResult` could not interpret
      the returned JSON. The string is the decoder's error message. */
  | DecodeError(string)
  /** The Rust handler rejected the promise. The payload is the raw
      value Tauri rejected with (typically a string or a JSON object).

      **Security**: this payload mirrors the captured Rust-side error
      and may include internal details (file paths, SQL fragments,
      stack traces, etc.). Sanitize before surfacing it in user-facing
      UI or sending it to remote telemetry. */
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

      The callback receives `Ok(message)` on a successful decode and
      `Error(decoderMessage)` when the JSON cannot be interpreted.
      Callers handle the two branches explicitly — to mimic the
      previous silent-drop behavior, ignore the `Error` case.

      See: https://v2.tauri.app/develop/calling-rust/#channels
  */
  type t<'message>

  /** Creates a new Channel handle with its decoder. The underlying
      JS Channel is constructed eagerly so the Rust side can be told
      the channel id immediately. */
  let make: (~decode: decoder<'message>) => t<'message>

  /** Registers (or replaces) the message handler. Tauri delivers each
      Rust-side `channel.send(...)` here as `Ok(message)`; decoder
      failures arrive as `Error(decoderMessage)`.

      ## Example

      ```rescript
      chan->Core.Channel.onMessage(result =>
        switch result {
        | Ok(msg) => Console.log(msg)
        | Error(_) => () // ignore decode failures
        }
      )
      ```
  */
  let onMessage: (t<'message>, result<'message, string> => unit) => unit

  /** Returns the integer id of the underlying JS Channel, useful when
      correlating with Rust-side logs. */
  let id: t<'message> => int
}
