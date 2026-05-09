import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

const installInternals = (invokeImpl) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = {
    invoke: invokeImpl ?? vi.fn(async () => undefined),
    transformCallback: () => 1,
    metadata: { currentWindow: { label: "main" } },
  }
}
const clear = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}

describe("Window", () => {
  beforeEach(() => installInternals())
  afterEach(clear)

  it("make + label returns the label provided to the constructor", async () => {
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("settings")
    expect(Window.label(w)).toBe("settings")
  })

  it("setTitle invokes the Rust side", async () => {
    const invoke = vi.fn(async () => undefined)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    await Window.setTitle(w, "Hello")
    expect(invoke).toHaveBeenCalled()
  })

  it("isMaximized returns whatever the underlying invoke resolves to", async () => {
    installInternals(vi.fn(async () => true))
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    const v = await Window.isMaximized(w)
    expect(v).toBe(true)
  })

  it("center invokes the Rust side", async () => {
    const invoke = vi.fn(async () => undefined)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("main")
    await Window.center(w)
    expect(invoke).toHaveBeenCalled()
  })

  it("getByLabel resolves without throwing when the rust side returns no windows", async () => {
    // Tauri's getByLabel internally calls getAllWindows which expects
    // an array; an empty array means "no match" → null result.
    installInternals(vi.fn(async () => []))
    const Window = await import("../../src/Window.res.mjs")
    const result = await Window.getByLabel("does-not-exist")
    expect(result === null || typeof result === "undefined").toBe(true)
  })

  // The block below exercises the @send method body of Window.res.mjs
  // that the existing 5 tests left at 7.31% line coverage. We don't
  // assert exact rust-side command names — Tauri's plugin:window|*
  // taxonomy is upstream churn we shouldn't ratchet against. We only
  // assert that the call dispatches to invoke and the return value
  // flows back.

  it("setBackgroundColor accepts both Nullable.null and a color value", async () => {
    const invoke = vi.fn(async () => undefined)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("bg")
    await Window.setBackgroundColor(w, null)
    await Window.setBackgroundColor(w, { r: 200, g: 100, b: 50, a: 255 })
    expect(invoke).toHaveBeenCalled()
  })

  it("setTheme accepts Nullable.null and a polymorphic-variant theme", async () => {
    const invoke = vi.fn(async () => undefined)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("theme")
    await Window.setTheme(w, null)
    await Window.setTheme(w, "dark")
    await Window.setTheme(w, "light")
    expect(invoke).toHaveBeenCalled()
  })

  it("monitorFromPoint dispatches with the (~x, ~y) labels", async () => {
    const invoke = vi.fn(async () => null)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const r = await Window.monitorFromPoint(150, 250)
    // Mock returns null so result should be null/undefined.
    expect(r === null || typeof r === "undefined").toBe(true)
    expect(invoke).toHaveBeenCalled()
  })

  it("currentMonitor / primaryMonitor / availableMonitors / cursorPosition / getFocusedWindow all dispatch through invoke", async () => {
    // currentMonitor / primaryMonitor wrap their result through
    // mapMonitor() which already null-guards, so returning null is
    // safe. cursorPosition wraps the result in `new PhysicalPosition(v)`
    // which is *not* null-guarded, so that mock has to return a
    // valid {x, y}.
    const invoke = vi.fn(async (cmd) => {
      if (cmd.includes("available_monitors")) return []
      if (cmd.includes("get_all_windows")) return [] // getFocusedWindow scans this
      if (cmd.includes("cursor_position")) return { x: 0, y: 0 }
      return null
    })
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    await Window.currentMonitor()
    await Window.primaryMonitor()
    await Window.availableMonitors()
    await Window.cursorPosition()
    await Window.getFocusedWindow()
    // getFocusedWindow internally calls get_all_windows then iterates,
    // so the total number of invoke calls is 5 + (additional internal
    // call from getFocusedWindow). Just assert it was called.
    expect(invoke).toHaveBeenCalled()
  })

  it("size and position queries resolve to the rust-side payload", async () => {
    // Window's inner/outer size + position upstream wrap the result
    // through `new PhysicalSize(v)` / `new PhysicalPosition(v)` which
    // require a {width,height} or {x,y} shape.
    const invoke = vi.fn(async (cmd) => {
      if (cmd.includes("scale_factor")) return 2.0
      if (cmd.includes("inner_size") || cmd.includes("outer_size"))
        return { width: 1280, height: 720 }
      if (cmd.includes("inner_position") || cmd.includes("outer_position")) return { x: 0, y: 0 }
      if (cmd.includes("title")) return "demo"
      if (cmd.includes("theme") && !cmd.includes("set_")) return "dark"
      return null
    })
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("size")
    expect(await Window.scaleFactor(w)).toBe(2.0)
    // PhysicalSize wraps with a class instance — width/height are getters.
    const ins = await Window.innerSize(w)
    expect(ins.width).toBe(1280)
    expect(ins.height).toBe(720)
    const outs = await Window.outerSize(w)
    expect(outs.width).toBe(1280)
    expect(outs.height).toBe(720)
    const inp = await Window.innerPosition(w)
    expect(inp.x).toBe(0)
    expect(inp.y).toBe(0)
    const outp = await Window.outerPosition(w)
    expect(outp.x).toBe(0)
    expect(outp.y).toBe(0)
    expect(await Window.title(w)).toBe("demo")
    expect(await Window.theme(w)).toBe("dark")
  })

  it("the boolean is* getters all dispatch through invoke", async () => {
    const invoke = vi.fn(async () => true)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("flags")
    expect(await Window.isVisible(w)).toBe(true)
    expect(await Window.isMaximized(w)).toBe(true)
    expect(await Window.isMinimized(w)).toBe(true)
    expect(await Window.isFullscreen(w)).toBe(true)
    expect(await Window.isDecorated(w)).toBe(true)
    expect(await Window.isResizable(w)).toBe(true)
    expect(await Window.isMaximizable(w)).toBe(true)
    expect(await Window.isMinimizable(w)).toBe(true)
    expect(await Window.isClosable(w)).toBe(true)
    expect(await Window.isAlwaysOnTop(w)).toBe(true)
    expect(await Window.isEnabled(w)).toBe(true)
    expect(await Window.isFocused(w)).toBe(true)
  })

  it("the void-returning setters all dispatch through invoke", async () => {
    const invoke = vi.fn(async () => undefined)
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const Dpi = await import("../../src/Dpi.res.mjs")
    const w = Window.make("setters")

    const sz = Dpi.Size.fromLogical(Dpi.LogicalSize.make(800, 600))
    const pos = Dpi.Position.fromLogical(Dpi.LogicalPosition.make(10, 20))

    await Window.setSize(w, sz)
    await Window.setMinSize(w, null)
    await Window.setMinSize(w, sz)
    await Window.setMaxSize(w, null)
    await Window.setMaxSize(w, sz)
    await Window.setSizeConstraints(w, null)
    await Window.setSizeConstraints(w, {
      minWidth: 400,
      minHeight: 300,
      maxWidth: 1600,
      maxHeight: 1200,
    })
    await Window.setPosition(w, pos)
    await Window.setFullscreen(w, true)
    await Window.setResizable(w, true)
    await Window.setEnabled(w, true)
    await Window.setMaximizable(w, true)
    await Window.setMinimizable(w, true)
    await Window.setClosable(w, true)
    await Window.setAlwaysOnTop(w, false)
    await Window.setAlwaysOnBottom(w, false)
    await Window.setContentProtected(w, false)
    await Window.setDecorations(w, true)
    await Window.setShadow(w, true)
    await Window.setSkipTaskbar(w, false)
    await Window.setIgnoreCursorEvents(w, false)
    await Window.setCursorIcon(w, "default")
    await Window.setCursorVisible(w, true)
    await Window.setCursorGrab(w, false)
    await Window.setCursorPosition(w, pos)
    await Window.setFocus(w)
    await Window.setTitleBarStyle(w, "visible")
    await Window.setProgressBar(w, { status: "normal", progress: 50 })
    await Window.setVisibleOnAllWorkspaces(w, false)
    await Window.setBadgeCount(w, 5)
    await Window.setBadgeCount(w, undefined)
    await Window.setBadgeLabel(w, "new")
    await Window.setBadgeLabel(w, undefined)
    await Window.setOverlayIcon(w, undefined)
    await Window.setIcon(w, "/icons/app.png")
    await Window.startDragging(w)
    await Window.startResizeDragging(w, "East")
    await Window.requestUserAttention(w, null)
    await Window.requestUserAttention(w, "critical")
    await Window.show(w)
    await Window.hide(w)
    await Window.minimize(w)
    await Window.maximize(w)
    await Window.unmaximize(w)
    await Window.close(w)
    await Window.destroy(w)

    // Effects API
    await Window.setEffects(w, {
      effects: ["blur"],
      state: "active",
      radius: 10,
    })
    await Window.clearEffects(w)

    expect(invoke).toHaveBeenCalled()
  })

  it("the on* event registrations resolve to unlisten thunks", async () => {
    // Subscribing to a window event opens a listener via Tauri's
    // event system, which calls invoke and returns an unlisten fn.
    const invoke = vi.fn(async () => () => {})
    installInternals(invoke)
    const Window = await import("../../src/Window.res.mjs")
    const w = Window.make("events")

    const onResized = await Window.onResized(w, () => {})
    const onMoved = await Window.onMoved(w, () => {})
    const onCloseReq = await Window.onCloseRequested(w, () => {})
    const onFocus = await Window.onFocusChanged(w, () => {})
    const onScale = await Window.onScaleChanged(w, () => {})
    const onTheme = await Window.onThemeChanged(w, () => {})

    // Each handler should resolve to a callable (the unlisten fn).
    for (const u of [onResized, onMoved, onCloseReq, onFocus, onScale, onTheme]) {
      expect(typeof u).toBe("function")
    }
  })
})
