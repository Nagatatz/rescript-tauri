// plugin-fs is a thin wrapper over Core.invoke. Each function dispatches
// to "plugin:fs|<name>" with the arguments. Mocks.mockIPC intercepts
// every invoke at the Tauri internals layer, so we can assert the
// command name + payload that each binding emits.
import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as PluginFs from "../../src/PluginFs.res.mjs"

describe("PluginFs", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("readTextFile dispatches plugin:fs|read_text_file and decodes UTF-8 bytes", async () => {
    // upstream returns the raw bytes; readTextFile then UTF-8 decodes them.
    Mocks.mockIPC(async (cmd, args) => {
      expect(cmd).toBe("plugin:fs|read_text_file")
      expect(args.path).toBe("/tmp/x")
      return Array.from(new TextEncoder().encode("hello"))
    })

    const out = await PluginFs.readTextFile("/tmp/x", undefined)
    expect(out).toBe("hello")
  })

  it("writeTextFile dispatches plugin:fs|write_text_file with the encoded bytes", async () => {
    // upstream calls invoke(cmd, encodedBytes, { headers: { path, options } }).
    // mockIPC strips the headers; we only see (cmd, args) where args is the
    // encoded bytes. So assert the command name and that args is non-null
    // bytes-like.
    let captured = null
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })

    await PluginFs.writeTextFile("/tmp/x", "payload", undefined)

    expect(captured.cmd).toBe("plugin:fs|write_text_file")
    expect(captured.args).toBeDefined()
    expect(captured.args).not.toBeNull()
  })

  it("mkdir forwards options", async () => {
    let captured = null
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })

    await PluginFs.mkdir("/tmp/d", { recursive: true })

    expect(captured.cmd).toBe("plugin:fs|mkdir")
    expect(captured.args.path).toBe("/tmp/d")
    expect(captured.args.options.recursive).toBe(true)
  })

  it("stat returns the FileInfo from the rust side", async () => {
    Mocks.mockIPC(async (cmd) => {
      expect(cmd).toBe("plugin:fs|stat")
      return {
        isFile: true,
        isDirectory: false,
        isSymlink: false,
        size: 42,
        mtime: null,
        atime: null,
        birthtime: null,
        readonly: false,
        fileAttributes: null,
        dev: null,
        ino: null,
        mode: null,
        nlink: null,
        uid: null,
        gid: null,
        rdev: null,
        blksize: null,
        blocks: null,
      }
    })

    const info = await PluginFs.stat("/tmp/x", undefined)
    expect(info.isFile).toBe(true)
    expect(info.size).toBe(42)
  })

  it("readDir returns the DirEntry array", async () => {
    Mocks.mockIPC(async () => [
      { name: "a.txt", isFile: true, isDirectory: false, isSymlink: false },
      { name: "sub", isFile: false, isDirectory: true, isSymlink: false },
    ])

    const entries = await PluginFs.readDir("/tmp", undefined)
    expect(entries).toHaveLength(2)
    expect(entries[0].name).toBe("a.txt")
    expect(entries[1].isDirectory).toBe(true)
  })

  it("exists reports true / false", async () => {
    Mocks.mockIPC(async () => true)
    expect(await PluginFs.exists("/tmp/x", undefined)).toBe(true)

    Mocks.clearMocks()
    Mocks.mockIPC(async () => false)
    expect(await PluginFs.exists("/no", undefined)).toBe(false)
  })

  it("readFile returns Uint8Array bytes from the rust side", async () => {
    Mocks.mockIPC(async (cmd) => {
      expect(cmd).toBe("plugin:fs|read_file")
      return Array.from(new Uint8Array([1, 2, 3, 4]))
    })
    const out = await PluginFs.readFile("/tmp/x", undefined)
    expect(out).toBeInstanceOf(Uint8Array)
    expect(Array.from(out)).toEqual([1, 2, 3, 4])
  })

  it("writeFile dispatches plugin:fs|write_file with the bytes payload", async () => {
    let captured = null
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    const bytes = new Uint8Array([0xde, 0xad, 0xbe, 0xef])
    await PluginFs.writeFile("/tmp/bin", bytes, undefined)
    expect(captured.cmd).toBe("plugin:fs|write_file")
  })

  it("remove dispatches plugin:fs|remove and forwards options.recursive", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await PluginFs.remove("/tmp/dir", { recursive: true })
    expect(captured.cmd).toBe("plugin:fs|remove")
    expect(captured.args.path).toBe("/tmp/dir")
    expect(captured.args.options.recursive).toBe(true)
  })

  it("rename dispatches plugin:fs|rename with both paths", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await PluginFs.rename("/tmp/a", "/tmp/b", undefined)
    expect(captured.cmd).toBe("plugin:fs|rename")
    expect(captured.args.oldPath).toBe("/tmp/a")
    expect(captured.args.newPath).toBe("/tmp/b")
  })

  it("lstat returns the FileInfo for a symlink (no follow)", async () => {
    Mocks.mockIPC(async (cmd) => {
      expect(cmd).toBe("plugin:fs|lstat")
      return {
        isFile: false,
        isDirectory: false,
        isSymlink: true,
        size: 0,
        mtime: null,
        atime: null,
        birthtime: null,
        readonly: false,
        fileAttributes: null,
        dev: null,
        ino: null,
        mode: null,
        nlink: null,
        uid: null,
        gid: null,
        rdev: null,
        blksize: null,
        blocks: null,
      }
    })
    const info = await PluginFs.lstat("/tmp/link", undefined)
    expect(info.isSymlink).toBe(true)
    expect(info.isFile).toBe(false)
  })

  it("copyFile dispatches plugin:fs|copy_file with from/to paths", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await PluginFs.copyFile("/tmp/src", "/tmp/dst", undefined)
    expect(captured.cmd).toBe("plugin:fs|copy_file")
    expect(captured.args.fromPath).toBe("/tmp/src")
    expect(captured.args.toPath).toBe("/tmp/dst")
  })

  it("truncate dispatches plugin:fs|truncate with the length", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await PluginFs.truncate("/tmp/big", 1024, undefined)
    expect(captured.cmd).toBe("plugin:fs|truncate")
    expect(captured.args.path).toBe("/tmp/big")
    expect(captured.args.len).toBe(1024)
  })

  it("size dispatches plugin:fs|size and returns the byte count", async () => {
    Mocks.mockIPC(async (cmd) => {
      expect(cmd).toBe("plugin:fs|size")
      return 42
    })
    expect(await PluginFs.size("/tmp/x")).toBe(42)
  })
})
