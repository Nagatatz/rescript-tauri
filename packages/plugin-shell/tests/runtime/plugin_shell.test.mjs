import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import * as PluginShell from "../../src/PluginShell.res.mjs"

describe("PluginShell", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  describe("openPath", () => {
    it("dispatches plugin:shell|open with the path and openWith fields", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })

      await PluginShell.openPath("https://example.com")

      expect(captured.cmd).toBe("plugin:shell|open")
      expect(captured.args.path).toBe("https://example.com")
    })

    it("forwards ~openWith to the IPC payload", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })

      await PluginShell.openPath("/home/me/notes.txt", "firefox")

      expect(captured.args.with).toBe("firefox")
    })
  })

  describe("Command.execute", () => {
    it("dispatches plugin:shell|execute and returns the childProcess record", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        if (cmd === "plugin:shell|execute") {
          return {
            code: 0,
            signal: null,
            stdout: "hello\n",
            stderr: "",
          }
        }
        return null
      })

      const cmd = PluginShell.Command.create("echo", ["hello"])
      const out = await PluginShell.Command.execute(cmd)

      expect(captured.cmd).toBe("plugin:shell|execute")
      expect(captured.args.program).toBe("echo")
      expect(captured.args.args).toEqual(["hello"])
      expect(out.code).toBe(0)
      expect(out.stdout).toBe("hello\n")
    })
  })

  describe("Command.createRaw", () => {
    it("forces encoding: 'raw' on the IPC payload", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        if (cmd === "plugin:shell|execute") {
          return {
            code: 0,
            signal: null,
            stdout: new Uint8Array([104, 105]),
            stderr: new Uint8Array(),
          }
        }
        return null
      })

      const cmd = PluginShell.Command.createRaw("printf", ["hi"])
      await PluginShell.Command.execute(cmd)

      expect(captured.args.options.encoding).toBe("raw")
    })
  })

  describe("Command.spawn + Child", () => {
    it("dispatches plugin:shell|spawn and Child.write/kill use stdin_write/kill", async () => {
      const seen = []
      Mocks.mockIPC(async (cmd, _args) => {
        seen.push(cmd)
        if (cmd === "plugin:shell|spawn") return 1234
        return null
      })

      const cmd = PluginShell.Command.create("cat")
      const child = await PluginShell.Command.spawn(cmd)

      expect(seen).toEqual(["plugin:shell|spawn"])
      expect(typeof PluginShell.Child.pid(child)).toBe("number")

      await PluginShell.Child.write(child, "hello")
      await PluginShell.Child.kill(child)

      expect(seen).toEqual(["plugin:shell|spawn", "plugin:shell|stdin_write", "plugin:shell|kill"])
    })
  })

  describe("Command event subscriptions", () => {
    it("onClose / onError / onStdoutData / onStderrData chain and return the command", () => {
      // No mockIPC needed — these are pure JS listener registrations
      // on the EventEmitter side, they don't hit IPC until spawn/execute.
      Mocks.mockIPC(async () => null)

      const closeHandler = vi.fn()
      const errorHandler = vi.fn()
      const stdoutHandler = vi.fn()
      const stderrHandler = vi.fn()

      const cmd = PluginShell.Command.create("true")
      const chained = PluginShell.Command.onClose(
        PluginShell.Command.onError(
          PluginShell.Command.onStdoutData(
            PluginShell.Command.onStderrData(cmd, stderrHandler),
            stdoutHandler,
          ),
          errorHandler,
        ),
        closeHandler,
      )

      // Each helper returns the same command instance to support chaining.
      expect(chained).toBe(cmd)
    })

    it("removeAllListeners returns the command for chaining", () => {
      Mocks.mockIPC(async () => null)
      const cmd = PluginShell.Command.create("true")
      const chained = PluginShell.Command.removeAllListeners(cmd)
      expect(chained).toBe(cmd)
    })
  })

  describe("EventEmitter accessors", () => {
    it("Command.stdout / Command.stderr expose EventEmitter handles", () => {
      Mocks.mockIPC(async () => null)
      const cmd = PluginShell.Command.create("true")
      const stdoutEE = PluginShell.Command.stdout(cmd)
      const stderrEE = PluginShell.Command.stderr(cmd)

      expect(stdoutEE).toBeDefined()
      expect(stderrEE).toBeDefined()
      // listenerCount("data") should be 0 before any subscription.
      expect(PluginShell.EventEmitter.listenerCount(stdoutEE, "data")).toBe(0)
      expect(PluginShell.EventEmitter.listenerCount(stderrEE, "data")).toBe(0)
    })
  })
})
