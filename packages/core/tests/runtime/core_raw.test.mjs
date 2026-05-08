import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

// In-test mocking helper. The full `Mocks` module follows in a later
// steering; for now we directly install a stub on
// globalThis.window.__TAURI_INTERNALS__.invoke.
//
// The Tauri 2.x JS SDK's `invoke` function (in @tauri-apps/api/core)
// internally calls `window.__TAURI_INTERNALS__.invoke(cmd, args, opts)`,
// so installing a stub there is enough to intercept the round-trip.
const installMock = (handler) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = {
    invoke: handler,
  }
}

const clearMock = () => {
  if (globalThis.window) {
    delete globalThis.window.__TAURI_INTERNALS__
  }
}

describe("Core.Raw.invoke", () => {
  beforeEach(clearMock)
  afterEach(clearMock)

  it("calls window.__TAURI_INTERNALS__.invoke with the command name and args", async () => {
    const handler = vi.fn(async (cmd, args) => {
      expect(cmd).toBe("greet")
      expect(args).toEqual({ name: "ReScript" })
      return "hello, ReScript!"
    })
    installMock(handler)

    const { Raw } = await import("../../src/Core.res.mjs")
    const result = await Raw.invoke("greet", { name: "ReScript" })

    expect(handler).toHaveBeenCalledTimes(1)
    expect(result).toBe("hello, ReScript!")
  })

  it("propagates rejection as a thrown error when awaited", async () => {
    installMock(async () => {
      throw new Error("rust-side failure")
    })

    const { Raw } = await import("../../src/Core.res.mjs")
    await expect(Raw.invoke("any", {})).rejects.toThrow("rust-side failure")
  })
})
