# 設計: Core.Command

## ファイル変更

### `packages/core/src/Core.res` (追記)

```rescript
type invokeError =
  | DecodeError(string)
  | RustError(JSON.t)

module Command = {
  type t<'args, 'result> = {
    name: string,
    encodeArgs: 'args => JSON.t,
    decodeResult: JSON.t => result<'result, string>,
  }

  let make = (~name, ~encodeArgs, ~decodeResult) => {name, encodeArgs, decodeResult}

  let invoke = async (cmd, args, ~options=?) => {
    let encoded = cmd.encodeArgs(args)
    try {
      let raw = await Raw.invoke(cmd.name, ~args=encoded, ~options?)
      switch cmd.decodeResult(raw) {
      | Ok(v) => Ok(v)
      | Error(msg) => Error(DecodeError(msg))
      }
    } catch {
    | Exn.Error(e) => Error(RustError(e->Obj.magic))
    }
  }

  let invokeExn = async (cmd, args, ~options=?) => {
    let encoded = cmd.encodeArgs(args)
    let raw = await Raw.invoke(cmd.name, ~args=encoded, ~options?)
    switch cmd.decodeResult(raw) {
    | Ok(v) => v
    | Error(msg) => Exn.raiseError("Core.Command decode error: " ++ msg)
    }
  }
}
```

### `packages/core/src/Core.resi` (追記)

```rescript
/** IPC error reported to the typed Command layer. */
type invokeError =
  /** The Rust call succeeded but the JSON shape did not match what
      `decodeResult` expected. The string is the decoder's error message. */
  | DecodeError(string)
  /** The Rust handler rejected the call. The payload is the raw value
      Tauri rejected with (typically a string or a JSON object). */
  | RustError(JSON.t)

module Command: {
  /** A typed handle to a single Rust command. */
  type t<'args, 'result>

  /** Declares one Rust command with its encoder and decoder.

      See: https://v2.tauri.app/develop/calling-rust/

      ## Example
      ```rescript
      let greet = Core.Command.make(
        ~name="greet",
        ~encodeArgs=({name}) => JSON.Encode.object([("name", JSON.Encode.string(name))]),
        ~decodeResult=json =>
          switch json->JSON.Decode.string {
          | Some(s) => Ok(s)
          | None => Error("expected string")
          },
      )
      ```
  */
  let make: (
    ~name: string,
    ~encodeArgs: 'args => JSON.t,
    ~decodeResult: JSON.t => result<'result, string>,
  ) => t<'args, 'result>

  /** Runs the command. Returns `Ok(value)` on success, or `Error(...)`:
      - `DecodeError(msg)` if the JSON shape did not match.
      - `RustError(json)` if the Rust handler rejected the promise.
  */
  let invoke: (
    t<'args, 'result>,
    'args,
    ~options: Raw.invokeOptions=?,
  ) => promise<result<'result, invokeError>>

  /** Like `invoke` but raises on failure. The original Rust-side
      rejection propagates as a thrown `exn`; decode failures are
      raised as `Failure` with a descriptive message. */
  let invokeExn: (
    t<'args, 'result>,
    'args,
    ~options: Raw.invokeOptions=?,
  ) => promise<'result>
}
```

### `packages/core/tests/core_command_signature.res`

```rescript
let _check_invoke_error: invokeError = DecodeError("test")
let _check_rust_error: invokeError = RustError(JSON.Null)

let _check_make: (
  ~name: string,
  ~encodeArgs: 'args => JSON.t,
  ~decodeResult: JSON.t => result<'result, string>,
) => Core.Command.t<'args, 'result> = Core.Command.make

let _check_invoke: (
  Core.Command.t<'args, 'result>,
  'args,
  ~options: Core.Raw.invokeOptions=?,
) => promise<result<'result, invokeError>> = Core.Command.invoke

let _check_invoke_exn: (
  Core.Command.t<'args, 'result>,
  'args,
  ~options: Core.Raw.invokeOptions=?,
) => promise<'result> = Core.Command.invokeExn
```

### `packages/core/tests/runtime/core_command.test.mjs`

```javascript
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

const installInvokeMock = (handler) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = { invoke: handler }
}
const clearMock = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}

describe("Core.Command", () => {
  beforeEach(clearMock)
  afterEach(clearMock)

  it("invoke returns Ok on successful round-trip", async () => {
    installInvokeMock(async (cmd, args) => {
      expect(cmd).toBe("greet")
      expect(args).toEqual({ name: "ReScript" })
      return "hello"
    })
    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make(
      "greet",
      ({ name }) => ({ name }),
      (raw) => (typeof raw === "string" ? { TAG: "Ok", _0: raw } : { TAG: "Error", _0: "expected string" }),
    )
    const result = await Command.invoke(greet, { name: "ReScript" })
    expect(result).toEqual({ TAG: "Ok", _0: "hello" })
  })

  it("invoke returns Error(DecodeError) when the decoder fails", async () => {
    installInvokeMock(async () => 42) // wrong shape
    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make(
      "greet",
      ({ name }) => ({ name }),
      (raw) => (typeof raw === "string" ? { TAG: "Ok", _0: raw } : { TAG: "Error", _0: "expected string" }),
    )
    const result = await Command.invoke(greet, { name: "ReScript" })
    expect(result.TAG).toBe("Error")
    expect(result._0.TAG).toBe("DecodeError")
    expect(result._0._0).toBe("expected string")
  })

  it("invoke returns Error(RustError) when the rust side rejects", async () => {
    installInvokeMock(async () => { throw new Error("rust fail") })
    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make("greet", () => ({}), () => ({ TAG: "Ok", _0: "" }))
    const result = await Command.invoke(greet, {})
    expect(result.TAG).toBe("Error")
    expect(result._0.TAG).toBe("RustError")
  })

  it("invokeExn raises on rust rejection", async () => {
    installInvokeMock(async () => { throw new Error("boom") })
    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make("greet", () => ({}), () => ({ TAG: "Ok", _0: "" }))
    await expect(Command.invokeExn(greet, {})).rejects.toThrow("boom")
  })
})
```

> **Note**: `result` 値の JS 表現は ReScript の出力形式 (`{ TAG: "Ok", _0: ... }`) に依存。実装時に異なれば test を実行値で調整。

## コミット粒度

| # | コミット |
|---|---|
| 1 | 📝 Add steering for 20260508-011 (core-command) |
| 2 | ✨ Add Core.invokeError variant + Core.Command (Layer 2) |
| 3 | ✅ Add type-level + runtime tests for Core.Command |
| 4 | 📝 Mark steering 20260508-011 complete |

## worktree

`EnterWorktree(name="core-command")`、commit 1 main + commits 2-4 worktree + マージ。
