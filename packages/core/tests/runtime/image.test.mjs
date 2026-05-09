// Image is a class wrapper. Static methods (new_, fromBytes, fromPath)
// invoke('plugin:image|...') and chain `.then((rid) => new Image(rid))`.
// Instance methods (rgba, size) invoke through `this.rid`.
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as Image from "../../src/Image.res.mjs"
import * as Mocks from "../../src/Mocks.res.mjs"

describe("Image", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("new_ wraps the rid returned by plugin:image|new", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return 7 // rid
    })
    const rgba = new Uint8Array([255, 0, 0, 255, 0, 255, 0, 255])
    const img = await Image.new_(rgba, 2, 1)
    expect(img).toBeDefined()
    expect(captured.cmd).toContain("image")
  })

  it("fromBytes wraps the rid returned by plugin:image|from_bytes", async () => {
    Mocks.mockIPC(async (cmd) => {
      expect(cmd).toContain("image")
      return 9
    })
    const bytes = new Uint8Array([0x89, 0x50, 0x4e, 0x47]) // PNG header
    const img = await Image.fromBytes(bytes)
    expect(img).toBeDefined()
  })

  it("fromPath wraps the rid returned by plugin:image|from_path", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return 11
    })
    const img = await Image.fromPath("/icons/app.png")
    expect(img).toBeDefined()
    expect(captured.args.path).toBe("/icons/app.png")
  })

  it("rgba round-trips bytes through the rust side", async () => {
    let phase = "create"
    Mocks.mockIPC(async (_cmd) => {
      if (phase === "create") {
        phase = "rgba"
        return 13
      }
      // upstream wraps the result in `new Uint8Array(buffer)` so we
      // need to return something Uint8Array can consume.
      return new Uint8Array([1, 2, 3, 4]).buffer
    })
    const img = await Image.fromPath("/x")
    const out = await Image.rgba(img)
    expect(out).toBeInstanceOf(Uint8Array)
    expect(Array.from(out)).toEqual([1, 2, 3, 4])
  })

  it("size returns the imageSize record from the rust side", async () => {
    let phase = "create"
    Mocks.mockIPC(async () => {
      if (phase === "create") {
        phase = "size"
        return 17
      }
      return { width: 64, height: 32 }
    })
    const img = await Image.fromPath("/x")
    const sz = await Image.size(img)
    expect(sz.width).toBe(64)
    expect(sz.height).toBe(32)
  })
})
