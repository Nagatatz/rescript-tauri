import { afterEach, beforeEach, describe, expect, it } from "vitest"

// ReScript's `result` and variant runtime representation:
//   Ok(v)    →  { TAG: "Ok", _0: v }
//   Error(v) →  { TAG: "Error", _0: v }
//   DecodeError(s) → { TAG: "DecodeError", _0: s }
//   RustError(j)   → { TAG: "RustError", _0: j }
const Ok = (v) => ({ TAG: "Ok", _0: v })
const Err = (v) => ({ TAG: "Error", _0: v })

describe("Core.Command", () => {
  let Mocks
  let Command

  beforeEach(async () => {
    Mocks = await import("../../src/Mocks.res.mjs")
    Command = (await import("../../src/Core.res.mjs")).Command
  })

  afterEach(() => {
    Mocks.clearMocks()
  })

  it("invoke returns Ok on a successful round-trip", async () => {
    Mocks.mockIPC(async (cmd, args) => {
      expect(cmd).toBe("greet")
      expect(args).toEqual({ name: "ReScript" })
      return "hello"
    })

    const greet = Command.make(
      "greet",
      ({ name }) => ({ name }),
      (raw) => (typeof raw === "string" ? Ok(raw) : Err("expected string")),
    )

    const result = await Command.invoke(greet, { name: "ReScript" })
    expect(result).toEqual(Ok("hello"))
  })

  it("invoke returns Error(DecodeError) when the decoder fails", async () => {
    Mocks.mockIPC(async () => 42) // wrong shape

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
    Mocks.mockIPC(async () => {
      throw new Error("rust fail")
    })

    const greet = Command.make(
      "greet",
      () => ({}),
      () => Ok(""),
    )

    const result = await Command.invoke(greet, {})
    expect(result.TAG).toBe("Error")
    expect(result._0.TAG).toBe("RustError")
  })

  it("invokeExn rethrows the rust-side rejection as-is", async () => {
    Mocks.mockIPC(async () => {
      throw new Error("boom")
    })

    const greet = Command.make(
      "greet",
      () => ({}),
      () => Ok(""),
    )

    await expect(Command.invokeExn(greet, {})).rejects.toThrow("boom")
  })

  it("invokeExn raises a descriptive error on decoder failure", async () => {
    Mocks.mockIPC(async () => 42)

    const greet = Command.make(
      "greet",
      () => ({}),
      (raw) => (typeof raw === "string" ? Ok(raw) : Err("expected string")),
    )

    await expect(Command.invokeExn(greet, {})).rejects.toThrow(/Core\.Command decode error/)
  })
})
