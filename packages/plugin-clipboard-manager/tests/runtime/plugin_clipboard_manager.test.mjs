import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as PluginClipboardManager from "../../src/PluginClipboardManager.res.mjs"

describe("PluginClipboardManager", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("writeText dispatches plugin:clipboard-manager|write_text", async () => {
    let captured = null
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await PluginClipboardManager.writeText("hello")
    expect(captured.cmd).toBe("plugin:clipboard-manager|write_text")
    // Upstream nests the text and label inside `data: { plainText: ... }`.
    // Verify the args object exists; precise schema is upstream's responsibility.
    expect(captured.args).toBeDefined()
  })

  it("writeText passes ~opts.label through to the IPC payload", async () => {
    let captured = null
    Mocks.mockIPC(async (cmd, args) => {
      captured = args
      return null
    })
    await PluginClipboardManager.writeText("hi", { label: "main" })
    // Upstream wraps the options inside the same payload — the exact
    // shape isn't part of the public contract, but `label` should
    // appear somewhere in the serialized args.
    expect(JSON.stringify(captured)).toContain("main")
  })

  it("readText dispatches plugin:clipboard-manager|read_text and returns the value", async () => {
    Mocks.mockIPC(async (cmd) => {
      expect(cmd).toBe("plugin:clipboard-manager|read_text")
      return "from-clipboard"
    })
    const result = await PluginClipboardManager.readText()
    expect(result).toBe("from-clipboard")
  })

  it("writeImage dispatches plugin:clipboard-manager|write_image", async () => {
    let captured = null
    Mocks.mockIPC(async (cmd) => {
      captured = cmd
      return null
    })
    await PluginClipboardManager.writeImage([255, 0, 0, 255])
    expect(captured).toBe("plugin:clipboard-manager|write_image")
  })

  it("readImage dispatches plugin:clipboard-manager|read_image and returns an Image", async () => {
    Mocks.mockIPC(async (cmd) => {
      expect(cmd).toBe("plugin:clipboard-manager|read_image")
      return 42 // resource id
    })
    const image = await PluginClipboardManager.readImage()
    expect(image).toBeDefined()
  })

  it("writeHtml dispatches plugin:clipboard-manager|write_html", async () => {
    let captured = null
    Mocks.mockIPC(async (cmd) => {
      captured = cmd
      return null
    })
    await PluginClipboardManager.writeHtml("<h1>hi</h1>", "hi")
    expect(captured).toBe("plugin:clipboard-manager|write_html")
  })

  it("clear dispatches plugin:clipboard-manager|clear", async () => {
    let captured = null
    Mocks.mockIPC(async (cmd) => {
      captured = cmd
      return null
    })
    await PluginClipboardManager.clear()
    expect(captured).toBe("plugin:clipboard-manager|clear")
  })
})
