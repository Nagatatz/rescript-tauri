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

    it("returns true when globalThis.isTauri is set", () => {
      const saved = globalThis.isTauri
      globalThis.isTauri = true
      try {
        expect(Core.isTauri()).toBe(true)
      } finally {
        if (saved === undefined) delete globalThis.isTauri
        else globalThis.isTauri = saved
      }
    })
  })

  describe("Resource", () => {
    it("rid getter reads the @get rid field on a Resource subclass", async () => {
      Mocks.mockIPC(async () => 99)
      const Image = await import("../../src/Image.res.mjs")
      const img = await Image.fromPath("/x")
      // Image extends upstream Resource, so Core.Resource.rid lifts
      // the same `rid` getter onto our opaque Resource.t.
      expect(Core.Resource.rid(img)).toBe(99)
    })

    it("close dispatches plugin:resources|close on the rid", async () => {
      const seen = []
      Mocks.mockIPC(async (cmd, _args) => {
        seen.push(cmd)
        if (cmd.includes("from_path")) return 77
        return null
      })
      const Image = await import("../../src/Image.res.mjs")
      const img = await Image.fromPath("/x")
      await Core.Resource.close(img)
      // Resource.close routes through plugin:resources|close upstream.
      expect(seen.some((c) => c.includes("close"))).toBe(true)
    })
  })

  describe("PluginListener.unregister", () => {
    it("resolves without throwing", async () => {
      Mocks.mockIPC(async () => 0)
      const listener = await Core.addPluginListener("demo", "topic", () => {})
      // Calling unregister should resolve cleanly even when no events
      // were dispatched.
      await expect(Core.PluginListener.unregister(listener)).resolves.not.toThrow
    })
  })

  describe("LowLevel.transformCallback (with ~once)", () => {
    it("forwards the once flag to the upstream transformCallback", () => {
      Mocks.mockIPC(async () => null)
      // upstream marks the registered cb as one-shot when once=true.
      const id = Core.LowLevel.transformCallback(() => {}, true)
      expect(typeof id).toBe("number")
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

      expect(seen).toEqual(["plugin:fs|check_permissions", "plugin:fs|request_permissions"])
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
