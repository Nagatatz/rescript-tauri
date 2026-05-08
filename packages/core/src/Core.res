module Raw = {
  type invokeOptions = {headers?: Dict.t<string>}

  @module("@tauri-apps/api/core")
  external invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result> =
    "invoke"
}
