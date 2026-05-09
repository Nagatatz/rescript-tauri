import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

describe("Core extras", () => {
  let Core
  let Mocks

  beforeEach(async () => {
    Core = await import("../../src/Core.res.mjs")
    Mocks = await import("../../src/Mocks.res.mjs")
  })

  afterEach(() => {
    Mocks.clearMocks()
  })

  describe("isTauri", () => {
    it("returns false in vitest (no Tauri internals globals)", () => {
      expect(Core.isTauri()).toBe(false)
    })
  })

  describe("LowLevel.serializeToIpcFn", () => {
    it("exposes the upstream constant", () => {
      expect(Core.LowLevel.serializeToIpcFn).toBe("__TAURI_TO_IPC_KEY__")
    })
  })

  describe("LowLevel.transformCallback", () => {
    it("returns a numeric callback id when Tauri internals exist", () => {
      // mockIPC installs __TAURI_INTERNALS__ which exposes transformCallback.
      Mocks.mockIPC(async () => null)
      const id = Core.LowLevel.transformCallback(() => {}, false)
      expect(typeof id).toBe("number")
    })
  })

  describe("checkPermissions / requestPermissions", () => {
    it("dispatches via mocked IPC with the plugin permission command names", async () => {
      const seen = []
      Mocks.mockIPC(async (cmd, _args) => {
        seen.push(cmd)
        return { foo: "granted" }
      })

      const got = await Core.checkPermissions("fs")
      expect(got).toEqual({ foo: "granted" })

      const got2 = await Core.requestPermissions("fs")
      expect(got2).toEqual({ foo: "granted" })

      expect(seen).toEqual([
        "plugin:fs|check_permissions",
        "plugin:fs|request_permissions",
      ])
    })
  })

  describe("addPluginListener", () => {
    it("registers a listener via the plugin event registry IPC", async () => {
      const seen = []
      Mocks.mockIPC(async (cmd, _args) => {
        seen.push(cmd)
        return 0
      })

      const handler = vi.fn()
      const listener = await Core.addPluginListener("fs", "watch", handler)

      expect(seen).toEqual(["plugin:fs|register_listener"])
      expect(Core.PluginListener.plugin(listener)).toBe("fs")
      expect(Core.PluginListener.event(listener)).toBe("watch")
      expect(typeof Core.PluginListener.channelId(listener)).toBe("number")
    })
  })
})
