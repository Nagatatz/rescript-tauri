// Tray wraps the upstream TrayIcon class. Static `new` chains through
// `[rid, id]`. Instance methods invoke('plugin:tray|set_*'). Tests run
// against Mocks.mockIPC; the action callback is configured via Channel
// upstream and re-broadcast by Tauri, which we don't simulate here —
// callback delivery is covered by the Webview drag-drop test.
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as Mocks from "../../src/Mocks.res.mjs"
import * as Tray from "../../src/Tray.res.mjs"

describe("Tray", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("make() with no options resolves to a TrayIcon handle", async () => {
    Mocks.mockIPC(async () => [1, "tray-1"])
    const tray = await Tray.make(undefined)
    expect(Tray.id(tray)).toBe("tray-1")
  })

  it("make({...}) forwards id / tooltip / title / iconAsTemplate", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return [2, "main-tray"]
    })
    await Tray.make({
      id: "main-tray",
      tooltip: "Demo",
      title: "Demo App",
      iconAsTemplate: true,
      showMenuOnLeftClick: false,
    })
    expect(captured.cmd).toContain("tray")
    expect(captured.args.options.id).toBe("main-tray")
    expect(captured.args.options.tooltip).toBe("Demo")
    expect(captured.args.options.iconAsTemplate).toBe(true)
  })

  it("getById returns null when the rust side returns null rid", async () => {
    Mocks.mockIPC(async () => null)
    const found = await Tray.getById("missing")
    expect(found === null || typeof found === "undefined").toBe(true)
  })

  it("getById returns a handle when the rust side returns a rid", async () => {
    Mocks.mockIPC(async () => 7)
    const found = await Tray.getById("present")
    expect(found).not.toBeNull()
  })

  it("removeById delegates to plugin:tray|remove_by_id", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      captured = { cmd, args }
      return null
    })
    await Tray.removeById("foo")
    expect(captured.cmd).toContain("remove_by_id")
    expect(captured.args.id).toBe("foo")
  })

  it("setIcon / setTooltip / setTitle accept Nullable.null", async () => {
    const calls = []
    Mocks.mockIPC(async (cmd) => {
      if (cmd.includes("new")) return [3, "t"]
      calls.push(cmd)
      return null
    })
    const tray = await Tray.make(undefined)
    await Tray.setIcon(tray, null)
    await Tray.setTooltip(tray, null)
    await Tray.setTitle(tray, null)

    expect(calls).toEqual(
      expect.arrayContaining([
        expect.stringContaining("set_icon"),
        expect.stringContaining("set_tooltip"),
        expect.stringContaining("set_title"),
      ]),
    )
  })

  it("setVisible / setIconAsTemplate / setShowMenuOnLeftClick accept booleans", async () => {
    const calls = []
    Mocks.mockIPC(async (cmd) => {
      if (cmd.includes("new")) return [4, "t"]
      calls.push(cmd)
      return null
    })
    const tray = await Tray.make(undefined)
    await Tray.setVisible(tray, true)
    await Tray.setIconAsTemplate(tray, false)
    await Tray.setShowMenuOnLeftClick(tray, true)

    expect(calls).toEqual(
      expect.arrayContaining([
        expect.stringContaining("set_visible"),
        expect.stringContaining("set_icon_as_template"),
        expect.stringContaining("set_show_menu_on_left_click"),
      ]),
    )
  })

  it("close releases the resource via plugin:resources|close", async () => {
    const calls = []
    Mocks.mockIPC(async (cmd) => {
      if (cmd.includes("tray|new")) return [5, "t"]
      calls.push(cmd)
      return null
    })
    const tray = await Tray.make(undefined)
    await Tray.close(tray)
    // Resource.close uses plugin:resources|close in upstream Tauri.
    expect(calls.some((c) => c.includes("close"))).toBe(true)
  })

  it("setMenu / setTempDirPath / setIconWithAsTemplate dispatch through IPC", async () => {
    const calls = []
    Mocks.mockIPC(async (cmd) => {
      if (cmd.includes("tray|new") || cmd.includes("menu|new")) return [6, "t"]
      calls.push(cmd)
      return null
    })
    const tray = await Tray.make(undefined)
    await Tray.setMenu(tray, null)
    await Tray.setTempDirPath(tray, null)
    await Tray.setTempDirPath(tray, "/tmp/icons")
    await Tray.setIconWithAsTemplate(tray, null, true)

    expect(calls).toEqual(
      expect.arrayContaining([
        expect.stringContaining("set_menu"),
        expect.stringContaining("set_temp_dir_path"),
        expect.stringContaining("set_icon_with_as_template"),
      ]),
    )
  })

  it("make({action: handler}) wires an action callback through Channel", async () => {
    Mocks.mockIPC(async () => [7, "t"])
    let received
    const tray = await Tray.make({
      action: (event) => {
        received = event
      },
    })
    expect(Tray.id(tray)).toBe("t")
    // The Channel-based action dispatch is internal to Tauri; we
    // can't easily simulate the callback firing without re-installing
    // its message hook. The point of this test is that registering
    // the handler doesn't throw.
    expect(received).toBeUndefined()
  })
})

// Channel-based action delivery requires us to install
// __TAURI_INTERNALS__.transformCallback directly so we can retrieve
// the Channel's onmessage handler and dispatch synthetic events.
// This mirrors the pattern from
// packages/schema/tests/runtime/schema.test.mjs.
describe("Tray action callback delivery", () => {
  let callbacks, nextId, originalInternals

  beforeEach(() => {
    Mocks.clearMocks()
    callbacks = new Map()
    nextId = 1
    originalInternals = globalThis.window?.__TAURI_INTERNALS__
    globalThis.window = globalThis.window ?? {}
    globalThis.window.__TAURI_INTERNALS__ = {
      invoke: async (cmd) => {
        if (cmd.includes("new")) return [42, "tray-1"]
        return null
      },
      transformCallback: (cb) => {
        const id = nextId++
        callbacks.set(id, cb)
        return id
      },
    }
  })

  afterEach(() => {
    if (originalInternals === undefined) {
      delete globalThis.window.__TAURI_INTERNALS__
    } else {
      globalThis.window.__TAURI_INTERNALS__ = originalInternals
    }
  })

  // Build a fresh tray + capture the action handler. The Channel
  // registers its callback first (id 1) when `action` is provided,
  // so callbacks.get(1) is the upstream Channel hook.
  const installTrayWithAction = async () => {
    const state = { received: null }
    await Tray.make({
      action: (event) => {
        state.received = event
      },
    })
    return { state, cb: callbacks.get(1) }
  }

  // The rect / position fields arrive at the user handler as the
  // raw {x, y} / {width, height} JSON since upstream's mapEvent
  // wraps them in PhysicalPosition / PhysicalSize classes whose
  // shape is the same — `Obj.magic` keeps them assignable to
  // Dpi.PhysicalPosition.t / PhysicalSize.t.
  const samplePos = { x: 10, y: 20 }
  const sampleRect = {
    position: { x: 0, y: 0 },
    size: { width: 16, height: 16 },
  }

  it("delivers a Click event to the action handler", async () => {
    const t = await installTrayWithAction()
    t.cb({
      index: 0,
      message: {
        type: "Click",
        id: "tray-1",
        position: samplePos,
        rect: sampleRect,
        button: "Left",
        buttonState: "Down",
      },
    })
    expect(t.state.received.TAG).toBe("Click")
    expect(t.state.received.id).toBe("tray-1")
    expect(t.state.received.button).toBe("Left")
    expect(t.state.received.buttonState).toBe("Down")
  })

  it("delivers a DoubleClick event to the action handler", async () => {
    const t = await installTrayWithAction()
    t.cb({
      index: 0,
      message: {
        type: "DoubleClick",
        id: "tray-1",
        position: samplePos,
        rect: sampleRect,
        button: "Right",
      },
    })
    expect(t.state.received.TAG).toBe("DoubleClick")
    expect(t.state.received.button).toBe("Right")
  })

  it("delivers an Enter event to the action handler", async () => {
    const t = await installTrayWithAction()
    t.cb({
      index: 0,
      message: {
        type: "Enter",
        id: "tray-1",
        position: samplePos,
        rect: sampleRect,
      },
    })
    expect(t.state.received.TAG).toBe("Enter")
    expect(t.state.received.id).toBe("tray-1")
  })

  it("delivers a Move event to the action handler", async () => {
    const t = await installTrayWithAction()
    t.cb({
      index: 0,
      message: {
        type: "Move",
        id: "tray-1",
        position: samplePos,
        rect: sampleRect,
      },
    })
    expect(t.state.received.TAG).toBe("Move")
  })

  it("delivers a Leave event to the action handler", async () => {
    const t = await installTrayWithAction()
    t.cb({
      index: 0,
      message: {
        type: "Leave",
        id: "tray-1",
        position: samplePos,
        rect: sampleRect,
      },
    })
    expect(t.state.received.TAG).toBe("Leave")
  })

  it("falls through to Leave when an unknown type arrives", async () => {
    // Tray.res:79 default case: `_ => Leave({id, position, rect})`.
    // Unknown future variants are treated as Leave so resource
    // cleanup still happens.
    const t = await installTrayWithAction()
    t.cb({
      index: 0,
      message: {
        type: "FutureUnknownVariant",
        id: "tray-1",
        position: samplePos,
        rect: sampleRect,
      },
    })
    expect(t.state.received.TAG).toBe("Leave")
    expect(t.state.received.id).toBe("tray-1")
  })
})
