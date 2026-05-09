module Core = RescriptTauriCore.Core
module Event = RescriptTauriCore.Event
module S = RescriptSchema.S

// Schema decoders **must** route failures through `S.Raised`. Throwing
// JS-native errors from a custom transform bypasses this catch and
// surfaces as an unhandled rejection in `Channel.onMessage` /
// `Event.listen` — those paths assume the decoder is total over its
// declared `Core.decoder<_>` contract.
let toDecoder = (schema: S.t<'value>): Core.decoder<'value> =>
  json =>
    try Ok(json->S.parseJsonOrThrow(schema)) catch {
    | S.Raised(error) => Error(S.Error.message(error))
    }

let fromSchemas = (
  ~name,
  ~args: S.t<'args>,
  ~result: S.t<'result>,
): Core.Command.t<'args, 'result> =>
  Core.Command.make(
    ~name,
    ~encodeArgs=value => value->S.reverseConvertToJsonOrThrow(args),
    ~decodeResult=toDecoder(result),
  )

let channelFromSchema = (~message: S.t<'message>): Core.Channel.t<'message> =>
  Core.Channel.make(~decode=toDecoder(message))

let eventFromSchema = (~name, ~payload: S.t<'payload>): Event.t<'payload> =>
  Event.make(~name, ~decode=toDecoder(payload))
