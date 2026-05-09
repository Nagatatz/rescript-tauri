// Path wrappers all call invoke('plugin:path|...') except sep() and
// delimiter(), which read window.__TAURI_INTERNALS__.plugins.path.{sep,delimiter}
// directly. We mock both layers.
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as Mocks from "../../src/Mocks.res.mjs"
import * as Path from "../../src/Path.res.mjs"

const installPathPluginGlobals = (sepValue, delimiterValue) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = globalThis.window.__TAURI_INTERNALS__ ?? {}
  globalThis.window.__TAURI_INTERNALS__.plugins = {
    path: { sep: sepValue, delimiter: delimiterValue },
  }
}

describe("Path.BaseDirectory", () => {
  it("BaseDirectory.t values are integer enum constants", () => {
    expect(Path.BaseDirectory.appConfig).toBe(13)
    expect(Path.BaseDirectory.home).toBe(21)
  })
})

describe("Path directory accessors", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("appConfigDir resolves to the rust-side path", async () => {
    Mocks.mockIPC(async () => "/home/me/.config/app")
    expect(await Path.appConfigDir()).toBe("/home/me/.config/app")
  })

  it("appDataDir resolves to the rust-side path", async () => {
    Mocks.mockIPC(async () => "/home/me/.local/share/app")
    expect(await Path.appDataDir()).toBe("/home/me/.local/share/app")
  })

  it("each directory accessor delegates to plugin:path|resolve_directory", async () => {
    let cmds = []
    Mocks.mockIPC(async (cmd) => {
      cmds.push(cmd)
      return "/dummy"
    })

    await Path.appLocalDataDir()
    await Path.appCacheDir()
    await Path.appLogDir()
    await Path.audioDir()
    await Path.cacheDir()
    await Path.configDir()
    await Path.dataDir()
    await Path.localDataDir()
    await Path.desktopDir()
    await Path.documentDir()
    await Path.downloadDir()
    await Path.executableDir()
    await Path.fontDir()
    await Path.homeDir()
    await Path.pictureDir()
    await Path.publicDir()
    await Path.resourceDir()
    await Path.runtimeDir()
    await Path.templateDir()
    await Path.tempDir()
    await Path.videoDir()

    // Every accessor uses the same upstream entrypoint (resolve_directory)
    // distinguished by a `directory` arg. We assert the count, not the
    // specific name — the count keeps a regression net if the upstream
    // skips one.
    expect(cmds.length).toBe(21)
    cmds.forEach((cmd) => expect(cmd).toContain("path"))
  })
})

describe("Path operations", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("join concatenates path segments", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return "/a/b/c"
    })
    const out = await Path.join(["/a", "b", "c"])
    expect(out).toBe("/a/b/c")
    expect(captured.cmd).toContain("join")
    expect(captured.args.paths).toEqual(["/a", "b", "c"])
  })

  it("normalize collapses redundant segments", async () => {
    Mocks.mockIPC(async () => "/a/b")
    expect(await Path.normalize("/a/./b/../b")).toBe("/a/b")
  })

  it("dirname returns the parent path", async () => {
    Mocks.mockIPC(async () => "/a")
    expect(await Path.dirname("/a/b")).toBe("/a")
  })

  it("basename returns the file portion", async () => {
    Mocks.mockIPC(async () => "b.txt")
    expect(await Path.basename("/a/b.txt", undefined)).toBe("b.txt")
  })

  it("basename strips ~ext when provided", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return "b"
    })
    const out = await Path.basename("/a/b.txt", ".txt")
    expect(out).toBe("b")
    expect(captured.args.ext).toBe(".txt")
  })

  it("extname returns the file extension", async () => {
    Mocks.mockIPC(async () => ".txt")
    expect(await Path.extname("/a/b.txt")).toBe(".txt")
  })

  it("isAbsolute reports the rust-side decision", async () => {
    Mocks.mockIPC(async () => true)
    expect(await Path.isAbsolute("/abs")).toBe(true)
    Mocks.clearMocks()
    Mocks.mockIPC(async () => false)
    expect(await Path.isAbsolute("rel")).toBe(false)
  })

  it("resolve concatenates and normalizes segments", async () => {
    Mocks.mockIPC(async () => "/a/b")
    expect(await Path.resolve(["/a", "b"])).toBe("/a/b")
  })

  it("resolveResource resolves a bundled resource path", async () => {
    Mocks.mockIPC(async () => "/app/resources/icon.png")
    expect(await Path.resolveResource("icon.png")).toBe("/app/resources/icon.png")
  })

  it("sep returns the platform-specific separator from injected globals", () => {
    installPathPluginGlobals("/", ":")
    expect(Path.sep()).toBe("/")
  })

  it("delimiter returns the platform-specific delimiter from injected globals", () => {
    installPathPluginGlobals("/", ":")
    expect(Path.delimiter()).toBe(":")
  })
})
