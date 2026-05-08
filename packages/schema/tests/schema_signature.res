// Type-level signature test for Schema.

module Core = RescriptTauriCore.Core
module Event = RescriptTauriCore.Event
module S = RescriptSchema.S

let _check_to_decoder: S.t<'value> => Core.decoder<'value> = Schema.toDecoder

let _check_from_schemas: (
  ~name: string,
  ~args: S.t<'args>,
  ~result: S.t<'result>,
) => Core.Command.t<'args, 'result> = Schema.fromSchemas

let _check_channel_from_schema: (~message: S.t<'message>) => Core.Channel.t<'message> = Schema.channelFromSchema

let _check_event_from_schema: (
  ~name: string,
  ~payload: S.t<'payload>,
) => Event.t<'payload> = Schema.eventFromSchema
