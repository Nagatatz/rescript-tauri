import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

const installInvokeMock = (handler) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = { invoke: handler }
}
const clearMock = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}

// ReScript's `result` and variant runtime representation:
//   Ok(v)    →  { TAG: "Ok", _0: v }
//   Error(v) →  { TAG: "Error", _0: v }
//   DecodeError(s) → { TAG: "DecodeError", _0: s }
//   RustError(j)   → { TAG: "RustError", _0: j }
const Ok = (v) => ({ TAG: "Ok", _0: v })
const Err = (v) => ({ TAG: "Error", _0: v })

describe("Core.Command", () => {
  beforeEach(clearMock)
  afterEach(clearMock)

  it("invoke returns Ok on a successful round-trip", async () => {
    installInvokeMock(async (cmd, args) => {
      expect(cmd).toBe("greet")
      expect(args).toEqual({ name: "ReScript" })
      return "hello"
    })

    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make(
      "greet",
      ({ name }) => ({ name }),
      (raw) => (typeof raw === "string" ? Ok(raw) : Err("expected string")),
    )

    const result = await Command.invoke(greet, { name: "ReScript" })
    expect(result).toEqual(Ok("hello"))
  })

  it("invoke returns Error(DecodeError) when the decoder fails", async () => {
    installInvokeMock(async () => 42) // wrong shape

    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make(
      "greet",
      ({ name }) => ({ name }),
      (raw) => (typeof raw === "string" ? Ok(raw) : Err("expected string")),
    )

    const result = await Command.invoke(greet, { name: "ReScript" })
    expect(result.TAG).toBe("Error")
    expect(result._0.TAG).toBe("DecodeError")
    expect(result._0._0).toBe("expected string")
  })

  it("invoke returns Error(RustError) when the rust side rejects", async () => {
    installInvokeMock(async () => {
      throw new Error("rust fail")
    })

    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make("greet", () => ({}), () => Ok(""))

    const result = await Command.invoke(greet, {})
    expect(result.TAG).toBe("Error")
    expect(result._0.TAG).toBe("RustError")
  })

  it("invokeExn rethrows the rust-side rejection as-is", async () => {
    installInvokeMock(async () => {
      throw new Error("boom")
    })

    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make("greet", () => ({}), () => Ok(""))

    await expect(Command.invokeExn(greet, {})).rejects.toThrow("boom")
  })

  it("invokeExn raises a descriptive error on decoder failure", async () => {
    installInvokeMock(async () => 42)

    const { Command } = await import("../../src/Core.res.mjs")
    const greet = Command.make(
      "greet",
      () => ({}),
      (raw) => (typeof raw === "string" ? Ok(raw) : Err("expected string")),
    )

    await expect(Command.invokeExn(greet, {})).rejects.toThrow(
      /Core\.Command decode error/,
    )
  })
})
