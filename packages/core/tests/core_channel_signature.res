// Type-level signature test for Core.Channel.

let _check_make: (~decode: JSON.t => result<'message, string>) => Core.Channel.t<'message> =
  Core.Channel.make

let _check_on_message: (Core.Channel.t<'message>, 'message => unit) => unit =
  Core.Channel.onMessage

let _check_id: Core.Channel.t<'message> => int = Core.Channel.id
