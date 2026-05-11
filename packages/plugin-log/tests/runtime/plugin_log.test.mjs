import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import {
  installEventPluginInternals,
  installTauriInternals,
} from "../../../../tools/tauri-mocks.mjs"
import * as PluginLog from "../../src/PluginLog.res.mjs"

describe("PluginLog", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  describe("level functions", () => {
    // Numeric level values match the upstream enum:
    // trace=1 / debug=2 / info=3 / warn=4 / error=5
    const levels = [
      ["error", 5],
      ["warn", 4],
      ["info", 3],
      ["debug", 2],
      ["trace", 1],
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
    let cleanups = []
    const stubInternals = () => {
      cleanups.push(installTauriInternals())
      cleanups.push(installEventPluginInternals())
    }
    afterEach(() => {
      for (const cleanup of cleanups) cleanup()
      cleanups = []
    })

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

  // LogLevel runtime representation is verified indirectly via the
  // "level functions" describe block above — each level function
  // dispatches its `@as(N)` value through IPC, exercising the wire
  // format end-to-end. @unboxed variant constructors do not materialize
  // as runtime JS values, so direct assertion is not possible.
})
