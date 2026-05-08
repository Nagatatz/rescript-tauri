import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

const installInternals = (invokeImpl) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = {
    invoke: invokeImpl ?? vi.fn(async () => undefined),
    transformCallback: () => 1,
    metadata: { currentWindow: { label: "main" } },
  }
}
const clear = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}

describe("Window", () => {
  beforeEach(() => installInternals())
  afterEach(clear)

  it("make + label returns the label provided to the constructor", async () => {
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("settings")
    expect(Window.label(w)).toBe("settings")
  })

  it("setTitle invokes the Rust side", async () => {
    const invoke = vi.fn(async () => undefined)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    await Window.setTitle(w, "Hello")
    expect(invoke).toHaveBeenCalled()
  })

  it("isMaximized returns whatever the underlying invoke resolves to", async () => {
    installInternals(vi.fn(async () => true))
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    const v = await Window.isMaximized(w)
    expect(v).toBe(true)
  })

  it("center invokes the Rust side", async () => {
    const invoke = vi.fn(async () => undefined)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    await Window.center(w)
    expect(invoke).toHaveBeenCalled()
  })

  it("getByLabel resolves without throwing when the rust side returns no windows", async () => {
    // Tauri's getByLabel internally calls getAllWindows which expects
    // an array; an empty array means "no match" → null result.
    installInternals(vi.fn(async () => []))
    const Window = await import("../../src/Window.res.mjs")
    const result = await Window.getByLabel("does-not-exist")
    expect(result === null || typeof result === "undefined").toBe(true)
  })
})
