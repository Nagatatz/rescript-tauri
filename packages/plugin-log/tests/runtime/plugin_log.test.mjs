import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as PluginLog from "../../src/PluginLog.res.mjs"

describe("PluginLog", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  describe("level functions", () => {
    const levels = [
      ["error", PluginLog.LogLevel.error_],
      ["warn", PluginLog.LogLevel.warn_],
      ["info", PluginLog.LogLevel.info_],
      ["debug", PluginLog.LogLevel.debug_],
      ["trace", PluginLog.LogLevel.trace],
    ]

    for (const [fnName, expectedLevel] of levels) {
      it(`${fnName} dispatches plugin:log|log with level ${expectedLevel}`, async () => {
        let captured = null
        Mocks.mockIPC(async (cmd, args) => {
          captured = { cmd, args }
          return null
        })
        await PluginLog[fnName]("hello")
        expect(captured.cmd).toBe("plugin:log|log")
        expect(captured.args.level).toBe(expectedLevel)
        expect(captured.args.message).toBe("hello")
      })
    }

    it("forwards ~options.file / line / keyValues to the IPC payload", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = args
        return null
      })
      await PluginLog.info("hi", { file: "Main.res", line: 42, keyValues: { user: "alice" } })
      expect(captured.file).toBe("Main.res")
      expect(captured.line).toBe(42)
      expect(captured.keyValues).toEqual({ user: "alice" })
    })
  })

  describe("attachLogger / attachConsole", () => {
    // Both wrap Tauri's `listen` for the `log://log` event. Stub the
    // upstream IPC bridge so the listener registration completes without
    // actually wiring anything up.
    const stubInternals = () => {
      globalThis.window = globalThis.window ?? {}
      let nextId = 1000
      const callbacks = new Map()
      globalThis.window.__TAURI_INTERNALS__ = {
        transformCallback: (cb) => {
          const id = nextId++
          callbacks.set(id, cb)
          return id
        },
        invoke: async () => undefined,
      }
      globalThis.window.__TAURI_EVENT_PLUGIN_INTERNALS__ = {
        unregisterListener: () => {},
      }
    }

    it("attachLogger returns an unlisten function", async () => {
      stubInternals()
      const unlisten = await PluginLog.attachLogger(() => {})
      expect(typeof unlisten).toBe("function")
    })

    it("attachConsole returns an unlisten function", async () => {
      stubInternals()
      const unlisten = await PluginLog.attachConsole()
      expect(typeof unlisten).toBe("function")
    })
  })

  describe("LogLevel constants", () => {
    it("match the upstream numeric enum", () => {
      expect(PluginLog.LogLevel.trace).toBe(1)
      expect(PluginLog.LogLevel.debug_).toBe(2)
      expect(PluginLog.LogLevel.info_).toBe(3)
      expect(PluginLog.LogLevel.warn_).toBe(4)
      expect(PluginLog.LogLevel.error_).toBe(5)
    })
  })
})
