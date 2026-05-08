// Type-level signature test for Core.Command and the invokeError variant.

let _check_invoke_error_decode: Core.invokeError = Core.DecodeError("test")
let _check_invoke_error_rust: Core.invokeError = Core.RustError(JSON.Null)

let _check_make: (
  ~name: string,
  ~encodeArgs: 'args => JSON.t,
  ~decodeResult: JSON.t => result<'result, string>,
) => Core.Command.t<'args, 'result> = Core.Command.make

let _check_invoke: (
  Core.Command.t<'args, 'result>,
  'args,
  ~options: Core.Raw.invokeOptions=?,
) => promise<result<'result, Core.invokeError>> = Core.Command.invoke

let _check_invoke_exn: (
  Core.Command.t<'args, 'result>,
  'args,
  ~options: Core.Raw.invokeOptions=?,
) => promise<'result> = Core.Command.invokeExn
