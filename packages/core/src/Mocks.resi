/** Installs an IPC mock handler. The handler receives the command
    name and the raw JSON payload, and must return a `promise<JSON.t>`
    representing what the Rust side would have replied with.

    Available in production builds — this module is intentionally
    test-oriented and should only be imported from test files.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#mockipc

    ## Example

    ```rescript
    Mocks.mockIPC((cmd, _args) =>
      switch cmd {
      | "greet" => Promise.resolve(JSON.Encode.string("hello"))
      | _ => Promise.resolve(JSON.Null)
      }
    )
    ```
*/
let mockIPC: ((string, JSON.t) => promise<JSON.t>) => unit

/** Installs Window mocks. The current window's label is `current`;
    additional named windows can be supplied via `~additional`.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#mockwindows
*/
let mockWindows: (~current: string, ~additional: array<string>=?) => unit

/** Removes any previously installed mocks. Call in `afterEach` to
    keep tests isolated.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#clearmocks
*/
let clearMocks: unit => unit
