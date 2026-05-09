/** Options forwarded to `mockIPC`'s second argument.

    `shouldMockEvents` (default `false`) makes Tauri's `listen` /
    `emit` round-trip through the in-process mock store as well —
    enabling event-handling tests without a real backend.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#mockipcoptions
*/
type mockIPCOptions = {shouldMockEvents?: bool}

/** Installs an IPC mock handler. The handler receives the command
    name and the raw JSON payload, and must return a `promise<JSON.t>`
    representing what the Rust side would have replied with.

    Available in production builds — this module is intentionally
    test-oriented and should only be imported from test files.

    Packaging: this module is part of `@rescript-tauri/core` and
    will not be split into a separate `@rescript-tauri/mocks`
    package — confirmed 2026-05-09 (PRD §10 #5, steering
    `20260509-045-mocks-packaging-decision`). All Phase 2 packages
    (`schema` / `plugin-fs` / `plugin-dialog`) consume it via the
    core peer dependency.

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
let mockIPC: (
  (string, JSON.t) => promise<JSON.t>,
  ~options: mockIPCOptions=?,
) => unit

/** Installs Window mocks. The current window's label is `current`;
    additional named windows can be supplied via `~additional`.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#mockwindows
*/
let mockWindows: (~current: string, ~additional: array<string>=?) => unit

/** Mocks `Core.Raw.convertFileSrc` for the given OS so tests run
    consistently across platforms. `~osName` accepts `"linux"`,
    `"macos"`, or `"windows"`.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#mockconvertfilesrc
*/
let mockConvertFileSrc: (~osName: string) => unit

/** Removes any previously installed mocks. Call in `afterEach` to
    keep tests isolated.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#clearmocks
*/
let clearMocks: unit => unit
