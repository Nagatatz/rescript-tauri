// Type-level signature test for Schema.

module Core = RescriptTauriCore.Core
module Event = RescriptTauriCore.Event

// Schema.S is the public re-export of RescriptSchema.S.
let _check_s_module_alias: Schema.S.t<string> = Schema.S.string

let _check_to_decoder: Schema.S.t<'value> => Core.decoder<'value> = Schema.toDecoder

let _check_from_schemas: (
  ~name: string,
  ~args: Schema.S.t<'args>,
  ~result: Schema.S.t<'result>,
) => Core.Command.t<'args, 'result> = Schema.fromSchemas

let _check_channel_from_schema: (
  ~message: Schema.S.t<'message>,
) => Core.Channel.t<'message> = Schema.channelFromSchema

let _check_event_from_schema: (
  ~name: string,
  ~schema: Schema.S.t<'payload>,
) => Event.t<'payload> = Schema.eventFromSchema
