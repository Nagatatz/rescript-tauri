/** rescript-schema integration for @rescript-tauri/core.

    Provides Layer 3 of the IPC stack from RFC-0001: declare a
    `Core.Command.t<'args, 'result>` from a single `S.t<'args>` +
    `S.t<'result>` pair instead of writing the encoder and decoder
    by hand.

    See: https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0002-schema-integration.md
*/

module Core = RescriptTauriCore.Core
module Event = RescriptTauriCore.Event
module S = RescriptSchema.S

/** Converts a `rescript-schema` schema into the `Core.decoder` shape
    expected by `Core.Command.make`, `Core.Channel.make`, and
    `Event.make`. Decode failures from `S.parseJsonOrThrow` are caught
    via the `S.Raised(error)` exception and surfaced as `Error(message)`.

    See: https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0002-schema-integration.md
*/
let toDecoder: S.t<'value> => Core.decoder<'value>

/** Declares a typed Tauri command from a single `S.t<'args>` and
    `S.t<'result>`. Encoding goes through `S.reverseConvertToJsonOrThrow`,
    decoding through `toDecoder`.

    ## Example

    ```rescript
    let greet = Schema.fromSchemas(
      ~name="greet",
      ~args=S.object(s => {name: s->S.field("name", S.string)}),
      ~result=S.string,
    )
    ```

    See: https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0002-schema-integration.md
*/
let fromSchemas: (
  ~name: string,
  ~args: S.t<'args>,
  ~result: S.t<'result>,
) => Core.Command.t<'args, 'result>

/** Declares a typed Channel using a schema as the message decoder.

    See: https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0002-schema-integration.md
*/
let channelFromSchema: (~message: S.t<'message>) => Core.Channel.t<'message>

/** Declares a typed Event using a schema as the payload decoder.

    See: https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0002-schema-integration.md
*/
let eventFromSchema: (~name: string, ~payload: S.t<'payload>) => Event.t<'payload>
