/** rescript-schema integration for @rescript-tauri/core.

    Provides Layer 3 of the IPC stack from RFC-0001: declare a
    `Core.Command.t<'args, 'result>`, `Core.Channel.t<'message>`, or
    `Event.t<'payload>` from a `rescript-schema` schema instead of
    writing the encoder and decoder by hand.

    `Schema.S` re-exports `RescriptSchema.S` so callers can reach the
    schema DSL through a single import. The `Core` / `Event`
    sub-aliases used inside the implementation are intentionally not
    re-exported; reach those modules through `@rescript-tauri/core`
    directly.

    See: https://v2.tauri.app/develop/calling-rust/
*/

/** Re-export of `RescriptSchema.S` so `@rescript-tauri/schema`
    callers do not need a separate `rescript-schema` import for the
    schema DSL itself. Both `Schema.S.string` and
    `RescriptSchema.S.string` resolve to the same module. */
module S = RescriptSchema.S

/** Converts a `rescript-schema` schema into the `Core.decoder` shape
    expected by `Core.Command.make`, `Core.Channel.make`, and
    `Event.make`. Decode failures from `S.parseJsonOrThrow` are caught
    via the `S.Raised(error)` exception and surfaced as `Error(message)`.

    Custom transforms must signal failure through `S.Raised` (or
    equivalent schema combinators); throwing JS-native errors bypasses
    this catch and surfaces as an unhandled rejection in
    `Channel.onMessage` / `Event.listen`.

    See: https://v2.tauri.app/develop/calling-rust/
*/
let toDecoder: S.t<'value> => RescriptTauriCore.Core.decoder<'value>

/** Declares a typed Tauri command from a single `S.t<'args>` and
    `S.t<'result>`. Encoding goes through `S.reverseConvertToJsonOrThrow`,
    decoding through `toDecoder`.

    ## Example

    ```rescript
    let greet = Schema.fromSchemas(
      ~name="greet",
      ~args=Schema.S.object(s => {name: s->Schema.S.field("name", Schema.S.string)}),
      ~result=Schema.S.string,
    )
    ```

    See: https://v2.tauri.app/develop/calling-rust/
*/
let fromSchemas: (
  ~name: string,
  ~args: S.t<'args>,
  ~result: S.t<'result>,
) => RescriptTauriCore.Core.Command.t<'args, 'result>

/** Declares a typed Channel using a schema as the message decoder.

    See: https://v2.tauri.app/develop/calling-rust/#channels
*/
let channelFromSchema: (~message: S.t<'message>) => RescriptTauriCore.Core.Channel.t<'message>

/** Declares a typed Event using a schema as the payload decoder.
    The `~schema` label mirrors `channelFromSchema`'s `~message`
    naming so all three Layer-3 helpers read uniformly; the schema
    is wrapped via `toDecoder` and forwarded to `Event.make`'s
    `~decode` argument.

    See: https://v2.tauri.app/develop/calling-frontend/#listening-to-events
*/
let eventFromSchema: (
  ~name: string,
  ~schema: S.t<'payload>,
) => RescriptTauriCore.Event.t<'payload>
