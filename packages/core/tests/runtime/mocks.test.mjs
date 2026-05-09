import { afterEach, beforeEach, describe, expect, it } from "vitest"

describe("Mocks", () => {
  let Mocks
  let Core

  beforeEach(async () => {
    Mocks = await import("../../src/Mocks.res.mjs")
    Core = await import("../../src/Core.res.mjs")
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

    const echo = Core.Command.make(
      "echo",
      ({ name }) => ({ name }),
      (raw) =>
        raw && typeof raw === "object" && typeof raw.name === "string"
          ? Ok(raw.name)
          : Err("expected {name: string}"),
    )

    const result = await Core.Command.invoke(echo, { name: "ReScript" })
    expect(result).toEqual(Ok("ReScript"))
  })

  it("clearMocks removes the IPC handler so subsequent invokes fail", async () => {
    Mocks.mockIPC(async () => "intercepted")
    const first = await Core.Raw.invoke("anything", {})
    expect(first).toBe("intercepted")

    Mocks.clearMocks()

    // After clearMocks the IPC bridge is gone; invoke must reject.
    let threw = false
    try {
      await Core.Raw.invoke("anything", {})
    } catch (_) {
      threw = true
    }
    expect(threw).toBe(true)
  })

  it("mockWindows + clearMocks are callable without throwing", async () => {
    expect(() => Mocks.mockWindows("main")).not.toThrow()
    expect(() => Mocks.mockWindows("main", ["settings", "about"])).not.toThrow()
    expect(() => Mocks.clearMocks()).not.toThrow()
  })

  it("mockConvertFileSrc rewrites Core.Raw.convertFileSrc per OS", async () => {
    Mocks.mockConvertFileSrc("windows")
    const url = Core.Raw.convertFileSrc("C:\\Users\\me\\photo.png")
    // Tauri's Windows-style convertFileSrc returns an https://asset.localhost
    // URL; the mock follows the same scheme.
    expect(url).toContain("asset.localhost")
  })

  it("mockIPC accepts ~options without throwing", () => {
    expect(() =>
      Mocks.mockIPC(async () => null, { shouldMockEvents: true }),
    ).not.toThrow()
  })
})
