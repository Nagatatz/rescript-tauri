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
