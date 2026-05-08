import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// Upstream `convertFileSrc` calls
// `window.__TAURI_INTERNALS__.convertFileSrc(filePath, protocol)`,
// so the mock must live there. Default protocol is "asset" upstream.
const installMock = (handler) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = globalThis.window.__TAURI_INTERNALS__ ?? {}
  globalThis.window.__TAURI_INTERNALS__.convertFileSrc = handler
}

const clearMock = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}

describe("Core.Raw.convertFileSrc", () => {
  beforeEach(clearMock)
  afterEach(clearMock)

  it("invokes the underlying convertFileSrc with the default protocol when omitted", async () => {
    const handler = vi.fn((path, protocol) => `${protocol}://${path}`)
    installMock(handler)

    const { Raw } = await import("../../src/Core.res.mjs")
    const url = Raw.convertFileSrc("/Users/me/photo.png")

    expect(handler).toHaveBeenCalledTimes(1)
    expect(handler).toHaveBeenCalledWith("/Users/me/photo.png", "asset")
    expect(url).toBe("asset:///Users/me/photo.png")
  })

  it("forwards an explicit protocol argument", async () => {
    const handler = vi.fn((path, protocol) => `${protocol}://${path}`)
    installMock(handler)

    const { Raw } = await import("../../src/Core.res.mjs")
    const url = Raw.convertFileSrc("/tmp/x", "stream")

    expect(handler).toHaveBeenCalledWith("/tmp/x", "stream")
    expect(url).toBe("stream:///tmp/x")
  })
})
