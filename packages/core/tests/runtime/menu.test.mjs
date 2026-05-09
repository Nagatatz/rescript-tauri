// Menu / Submenu / MenuItem / CheckMenuItem / IconMenuItem /
// PredefinedMenuItem all wrap upstream class instances. The upstream
// `MenuItem.new(opts)` chain calls invoke('plugin:menu|new', ...) and
// expects the rust side to return `[rid, id]` (and similar for the
// other kinds). Mocks.mockIPC lets us stub each call.
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as Menu from "../../src/Menu.res.mjs"
import * as Mocks from "../../src/Mocks.res.mjs"

describe("Menu.MenuItem", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("make + id + setText + setEnabled + setAccelerator round-trip through IPC", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd, args) => {
      calls.push({ cmd, args })
      if (cmd.includes("new")) return [1, "open"]
      if (cmd.includes("is_enabled")) return true
      if (cmd.includes("text")) return "Open"
      return null
    })

    const item = await Menu.MenuItem.make({ id: "open", text: "Open" })
    expect(Menu.MenuItem.id(item)).toBe("open")
    expect(await Menu.MenuItem.text(item)).toBe("Open")
    expect(await Menu.MenuItem.isEnabled(item)).toBe(true)
    await Menu.MenuItem.setText(item, "Open File")
    await Menu.MenuItem.setEnabled(item, false)
    await Menu.MenuItem.setAccelerator(item, "Cmd+O")

    expect(calls.map((c) => c.cmd).filter((c) => c.includes("menu"))).toEqual(
      expect.arrayContaining([
        expect.stringContaining("new"),
        expect.stringContaining("text"),
        expect.stringContaining("set_text"),
        expect.stringContaining("set_enabled"),
        expect.stringContaining("set_accelerator"),
      ]),
    )
  })
})

describe("Menu.CheckMenuItem", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("make + isChecked + setChecked", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [2, "auto"]
      if (cmd.includes("is_checked")) return true
      return null
    })
    const item = await Menu.CheckMenuItem.make({
      id: "auto",
      text: "Auto-save",
      checked: true,
    })
    expect(Menu.CheckMenuItem.id(item)).toBe("auto")
    expect(await Menu.CheckMenuItem.isChecked(item)).toBe(true)
    await Menu.CheckMenuItem.setChecked(item, false)

    expect(calls).toEqual(
      expect.arrayContaining([
        expect.stringContaining("new"),
        expect.stringContaining("is_checked"),
        expect.stringContaining("set_checked"),
      ]),
    )
  })
})

describe("Menu.IconMenuItem", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("make + setIcon", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [3, "save"]
      return null
    })
    const item = await Menu.IconMenuItem.make({
      id: "save",
      text: "Save",
      icon: "/icons/save.png",
    })
    await Menu.IconMenuItem.setIcon(item, "/icons/save-active.png")

    expect(calls).toEqual(
      expect.arrayContaining([
        expect.stringContaining("new"),
        expect.stringContaining("set_icon"),
      ]),
    )
  })
})

describe("Menu.PredefinedMenuItem", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("make encodes the Separator variant as a string", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      if (cmd.includes("new")) {
        captured = { cmd, args }
        return [4, "sep"]
      }
      return null
    })
    const sep = await Menu.PredefinedMenuItem.make({ item: "Separator" })
    expect(Menu.PredefinedMenuItem.id(sep)).toBe("sep")
    expect(captured.args.options.item).toBe("Separator")
  })

  it("make encodes the About(meta) variant as { About: meta }", async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      if (cmd.includes("new")) {
        captured = { cmd, args }
        return [5, "about"]
      }
      return null
    })
    // About(aboutMetadata) compiles to { TAG: "About", _0: <meta> } in
    // ReScript v12, and _predefinedToJs unwraps it to { About: meta }.
    await Menu.PredefinedMenuItem.make({
      text: "About...",
      item: { TAG: "About", _0: { name: "demo", version: "0.1.0" } },
    })
    expect(captured.args.options.item.About).toEqual({ name: "demo", version: "0.1.0" })
  })
})

describe("Menu.Submenu", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("make + append + remove + items + popup", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [6, "edit"]
      if (cmd.includes("items")) return []
      return null
    })
    const submenu = await Menu.Submenu.make({ text: "Edit" })
    const child = await Menu.MenuItem.make({ text: "Cut" })
    await Menu.Submenu.append(submenu, [{ TAG: "Item", _0: child }])
    await Menu.Submenu.remove(submenu, { TAG: "Item", _0: child })
    const items = await Menu.Submenu.items(submenu)
    expect(items).toEqual([])
    await Menu.Submenu.popup(submenu, undefined, undefined)

    expect(calls).toEqual(
      expect.arrayContaining([
        expect.stringContaining("append"),
        expect.stringContaining("remove"),
        expect.stringContaining("items"),
        expect.stringContaining("popup"),
      ]),
    )
  })

  it("prepend + insert + removeAt + get + text + setText + isEnabled + setEnabled", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [60, "edit"]
      if (cmd.includes("text") && !cmd.includes("set_text")) return "Edit"
      if (cmd.includes("is_enabled")) return true
      // upstream's removeAt unconditionally calls itemFromKind on the
      // result, so returning null would throw. Return a valid triple.
      if (cmd.includes("remove_at")) return [99, "removed", "MenuItem"]
      if (cmd.includes("get")) return null // upstream `get` guards null
      return null
    })
    const submenu = await Menu.Submenu.make({ text: "Edit" })
    const child = await Menu.MenuItem.make({ text: "Cut" })
    await Menu.Submenu.prepend(submenu, [{ TAG: "Item", _0: child }])
    await Menu.Submenu.insert(submenu, [{ TAG: "Item", _0: child }], 0)
    await Menu.Submenu.removeAt(submenu, 0)
    await Menu.Submenu.get(submenu, "missing")
    expect(await Menu.Submenu.text(submenu)).toBe("Edit")
    await Menu.Submenu.setText(submenu, "Editing")
    expect(await Menu.Submenu.isEnabled(submenu)).toBe(true)
    await Menu.Submenu.setEnabled(submenu, false)
  })

  it("setAsWindowsMenuForNSApp / setAsHelpMenuForNSApp dispatch through IPC", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [61, "win"]
      return null
    })
    const submenu = await Menu.Submenu.make({ text: "Window" })
    await Menu.Submenu.setAsWindowsMenuForNSApp(submenu)
    await Menu.Submenu.setAsHelpMenuForNSApp(submenu)
    expect(calls.length).toBeGreaterThan(2)
  })
})

describe("Menu.Menu", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("make + default + setAsAppMenu round-trips through IPC", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new") || cmd.includes("default")) return [9, "main"]
      // setAsAppMenu returns the previous menu rid pair or null.
      return null
    })

    const menu = await Menu.Menu.make()
    expect(Menu.Menu.id(menu)).toBe("main")
    // ReScript's `default` clashes with JS reserved word, compiled as $$default.
    const def = await Menu.Menu.$$default()
    expect(def).toBeDefined()
    await Menu.Menu.setAsAppMenu(menu)

    expect(calls).toEqual(
      expect.arrayContaining([
        expect.stringContaining("new"),
        expect.stringContaining("default"),
        expect.stringContaining("set_as_app_menu"),
      ]),
    )
  })

  it("append / prepend / insert / remove / removeAt / items / get / popup / setAsWindowMenu", async () => {
    let calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [90, "main"]
      if (cmd.includes("items")) return []
      // upstream's removeAt unconditionally calls itemFromKind on the
      // result, so returning null would throw. Return a valid triple.
      if (cmd.includes("remove_at")) return [91, "removed", "MenuItem"]
      return null
    })
    const menu = await Menu.Menu.make()
    const child = await Menu.MenuItem.make({ text: "Item" })
    const wrapped = { TAG: "Item", _0: child }

    await Menu.Menu.append(menu, [wrapped])
    await Menu.Menu.prepend(menu, [wrapped])
    await Menu.Menu.insert(menu, [wrapped], 0)
    await Menu.Menu.remove(menu, wrapped)
    await Menu.Menu.removeAt(menu, 0)
    expect(await Menu.Menu.items(menu)).toEqual([])
    await Menu.Menu.get(menu, "missing")
    await Menu.Menu.popup(menu, undefined, undefined)
    await Menu.Menu.setAsWindowMenu(menu, undefined)

    expect(calls.length).toBeGreaterThan(8)
  })
})
