import { describe, it, expect, beforeEach, afterEach } from "vitest"
import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import * as PluginDialog from "../../src/PluginDialog.res.mjs"

describe("PluginDialog", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  describe("openFile / openFiles / openDirectory / openDirectories", () => {
    it("openFile dispatches open with multiple=false, directory=false", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return "/Users/me/x.txt"
      })

      const result = await PluginDialog.openFile()

      expect(captured.cmd).toBe("plugin:dialog|open")
      expect(captured.args.options.multiple).toBe(false)
      expect(captured.args.options.directory).toBe(false)
      expect(result).toBe("/Users/me/x.txt")
    })

    it("openFiles dispatches with multiple=true", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return ["/a", "/b"]
      })

      const result = await PluginDialog.openFiles()

      expect(captured.args.options.multiple).toBe(true)
      expect(captured.args.options.directory).toBe(false)
      expect(result).toEqual(["/a", "/b"])
    })

    it("openDirectory dispatches with directory=true", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return "/tmp"
      })

      await PluginDialog.openDirectory()

      expect(captured.args.options.multiple).toBe(false)
      expect(captured.args.options.directory).toBe(true)
    })

    it("openDirectories dispatches with multiple+directory=true", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return ["/a", "/b"]
      })

      await PluginDialog.openDirectories()

      expect(captured.args.options.multiple).toBe(true)
      expect(captured.args.options.directory).toBe(true)
    })

    it("returns null when the user cancels", async () => {
      Mocks.mockIPC(async () => null)
      const result = await PluginDialog.openFile()
      expect(result).toBeNull()
    })

    it("forwards user-supplied options (filters / defaultPath / etc.)", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })

      await PluginDialog.openFile({
        title: "Pick file",
        defaultPath: "/Users",
        filters: [{ name: "Images", extensions: ["png", "jpg"] }],
      })

      expect(captured.args.options.title).toBe("Pick file")
      expect(captured.args.options.defaultPath).toBe("/Users")
      expect(captured.args.options.filters).toHaveLength(1)
      expect(captured.args.options.filters[0].name).toBe("Images")
    })
  })

  describe("save", () => {
    it("dispatches plugin:dialog|save and returns the chosen path", async () => {
      Mocks.mockIPC(async (cmd) => {
        expect(cmd).toBe("plugin:dialog|save")
        return "/tmp/out.txt"
      })

      const result = await PluginDialog.save()
      expect(result).toBe("/tmp/out.txt")
    })
  })

  describe("message / ask / confirm", () => {
    it("message returns the result string from upstream", async () => {
      Mocks.mockIPC(async (cmd, args) => {
        expect(cmd).toBe("plugin:dialog|message")
        expect(args.message).toBe("Saved!")
        return "Ok"
      })

      const result = await PluginDialog.message("Saved!")
      expect(result).toBe("Ok")
    })

    // ask / confirm both go through plugin:dialog|message internally
    // (upstream wraps them around messageCommand). Their booleans come
    // from comparing the dialog result string against the expected
    // ok-label.

    it("ask returns true when the user picks the affirmative button", async () => {
      Mocks.mockIPC(async (cmd) => {
        expect(cmd).toBe("plugin:dialog|message")
        return "Yes"
      })

      const result = await PluginDialog.ask("Continue?")
      expect(result).toBe(true)
    })

    it("confirm returns false when the user dismisses", async () => {
      Mocks.mockIPC(async (cmd) => {
        expect(cmd).toBe("plugin:dialog|message")
        return "Cancel"
      })

      const result = await PluginDialog.confirm("Are you sure?")
      expect(result).toBe(false)
    })
  })
})
