import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

describe("Core.Raw.invoke", () => {
  let Mocks
  let Raw

  beforeEach(async () => {
    Mocks = await import("../../src/Mocks.res.mjs")
    Raw = (await import("../../src/Core.res.mjs")).Raw
  })

  afterEach(() => {
    Mocks.clearMocks()
  })

  it("routes through Mocks.mockIPC with the command name and args", async () => {
    const handler = vi.fn(async (cmd, args) => {
      expect(cmd).toBe("greet")
      expect(args).toEqual({ name: "ReScript" })
      return "hello, ReScript!"
    })
    Mocks.mockIPC(handler)

    const result = await Raw.invoke("greet", { name: "ReScript" })

    expect(handler).toHaveBeenCalledTimes(1)
    expect(result).toBe("hello, ReScript!")
  })

  it("propagates a thrown handler error as the awaited rejection", async () => {
    Mocks.mockIPC(async () => {
      throw new Error("rust-side failure")
    })

    await expect(Raw.invoke("any", {})).rejects.toThrow("rust-side failure")
  })
})
