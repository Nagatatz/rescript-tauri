# 設計: Mocks モジュール

## ファイル変更

### `packages/core/src/Mocks.res` (新規)

```rescript
@module("@tauri-apps/api/mocks")
external mockIPC: ((string, JSON.t) => promise<JSON.t>) => unit = "mockIPC"

@module("@tauri-apps/api/mocks") @variadic
external _mockWindows: array<string> => unit = "mockWindows"

let mockWindows = (~current, ~additional=[]) => {
  let labels = [current]->Array.concat(additional)
  _mockWindows(labels)
}

@module("@tauri-apps/api/mocks")
external clearMocks: unit => unit = "clearMocks"
```

### `packages/core/src/Mocks.resi` (新規)

```rescript
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

/** Installs a Window mock. The current window's label is `current`;
    additional named windows can be supplied via `~additional`.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#mockwindows
*/
let mockWindows: (~current: string, ~additional: array<string>=?) => unit

/** Removes any previously installed mocks. Call in `afterEach` to
    keep tests isolated.

    See: https://v2.tauri.app/reference/javascript/api/namespacemocks/#clearmocks
*/
let clearMocks: unit => unit
```

### `packages/core/tests/mocks_signature.res`

```rescript
let _check_mock_ipc: ((string, JSON.t) => promise<JSON.t>) => unit = Mocks.mockIPC
let _check_mock_windows: (~current: string, ~additional: array<string>=?) => unit = Mocks.mockWindows
let _check_clear_mocks: unit => unit = Mocks.clearMocks
```

### `packages/core/tests/runtime/mocks.test.mjs`

```javascript
import { describe, it, expect, beforeEach, afterEach } from "vitest"

describe("Mocks", () => {
  let Mocks
  let Core
  let Command

  beforeEach(async () => {
    Mocks = await import("../../src/Mocks.res.mjs")
    Core = await import("../../src/Core.res.mjs")
    Command = Core.Command
  })

  afterEach(() => {
    Mocks.clearMocks()
  })

  it("mockIPC routes Core.Raw.invoke to the supplied handler", async () => {
    Mocks.mockIPC(async (cmd, args) => {
      if (cmd === "greet" && args && typeof args === "object" && args.name) {
        return `hello, ${args.name}!`
      }
      return null
    })

    const result = await Core.Raw.invoke("greet", { name: "ReScript" })
    expect(result).toBe("hello, ReScript!")
  })

  it("Core.Command.invoke round-trips through mockIPC (PRD Story 6-1)", async () => {
    Mocks.mockIPC(async (cmd, args) => {
      if (cmd === "echo") return args
      return null
    })

    const Ok = (v) => ({ TAG: "Ok", _0: v })
    const Err = (m) => ({ TAG: "Error", _0: m })

    const echo = Command.make(
      "echo",
      ({ name }) => ({ name }),
      (raw) =>
        raw && typeof raw === "object" && typeof raw.name === "string"
          ? Ok(raw.name)
          : Err("expected {name: string}"),
    )

    const result = await Command.invoke(echo, { name: "ReScript" })
    expect(result).toEqual(Ok("ReScript"))
  })

  it("clearMocks removes the IPC handler so subsequent invokes fail", async () => {
    Mocks.mockIPC(async () => "intercepted")
    let result1 = await Core.Raw.invoke("anything", {})
    expect(result1).toBe("intercepted")

    Mocks.clearMocks()

    // After clearMocks the IPC bridge is gone; invoke is expected to throw.
    await expect(Core.Raw.invoke("anything", {})).rejects.toBeDefined()
  })
})
```

## コミット粒度

| # | コミット |
|---|---|
| 1 | 📝 Add steering for 20260508-015 (mocks-module) |
| 2 | ✨ Add Mocks module wrapper |
| 3 | ✅ Add type-level + runtime tests for Mocks |
| 4 | 📝 Mark steering 20260508-015 complete |

## worktree

`EnterWorktree(name="mocks-module")`。
