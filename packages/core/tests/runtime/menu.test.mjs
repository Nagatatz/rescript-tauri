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
    const calls = []
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
    const calls = []
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
    const calls = []
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
      expect.arrayContaining([expect.stringContaining("new"), expect.stringContaining("set_icon")]),
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
    const calls = []
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
    const calls = []
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
    const calls = []
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
    const calls = []
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
    const calls = []
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

// PredefinedMenuItem encodes its `predefinedItem` variant into the
// upstream JS shape via the internal `_predefinedToJs` helper. The
// 17 string-only variants compile to plain strings; `About(meta)` is
// the only object-shaped one (already covered above). We exercise
// every string variant through `PredefinedMenuItem.make` and assert
// the JSON-encoded `options.item` lands with the expected string.
describe("Menu.Submenu items() decode (_itemFromJs branch coverage)", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("items() decodes each itemKind variant", async () => {
    // Upstream returns each item as a [rid, id, kind] triple that
    // upstream's `itemFromKind` destructures into a class instance.
    // ReScript's `_itemFromJs` then reads the `kind` getter on that
    // instance.
    Mocks.mockIPC(async (cmd) => {
      if (cmd.includes("new")) return [70, "edit"]
      if (cmd.includes("items")) {
        return [
          [1, "a", "MenuItem"],
          [2, "b", "Check"],
          [3, "c", "Icon"],
          [4, "d", "Predefined"],
          [5, "e", "Submenu"],
        ]
      }
      return null
    })
    const submenu = await Menu.Submenu.make({ text: "Edit" })
    const items = await Menu.Submenu.items(submenu)
    expect(items).toHaveLength(5)
    expect(items[0].TAG).toBe("Item")
    expect(items[1].TAG).toBe("Check")
    expect(items[2].TAG).toBe("Icon")
    expect(items[3].TAG).toBe("Predefined")
    expect(items[4].TAG).toBe("Submenu")
  })

  it("get() returns an itemKind when found", async () => {
    Mocks.mockIPC(async (cmd) => {
      if (cmd.includes("new")) return [71, "edit"]
      if (cmd.includes("get")) return [99, "found", "MenuItem"]
      return null
    })
    const submenu = await Menu.Submenu.make({ text: "Edit" })
    const item = await Menu.Submenu.get(submenu, "found")
    expect(item).not.toBeNull()
    expect(item.TAG).toBe("Item")
  })
})

describe("Menu MenuItem-class id/text getters and setters", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("CheckMenuItem.text / setText / setEnabled / setAccelerator dispatch through IPC", async () => {
    const calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [80, "check"]
      if (cmd.includes("text")) return "Auto-save"
      return null
    })
    const item = await Menu.CheckMenuItem.make({ text: "Auto-save" })
    expect(Menu.CheckMenuItem.id(item)).toBe("check")
    expect(await Menu.CheckMenuItem.text(item)).toBe("Auto-save")
    await Menu.CheckMenuItem.setText(item, "Auto save")
    await Menu.CheckMenuItem.setEnabled(item, true)
    await Menu.CheckMenuItem.setAccelerator(item, "Cmd+Shift+S")
  })

  it("IconMenuItem.text / setText / setEnabled / setAccelerator dispatch through IPC", async () => {
    const calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [81, "icon"]
      if (cmd.includes("text")) return "Save"
      return null
    })
    const item = await Menu.IconMenuItem.make({ text: "Save", icon: "/icons/save.png" })
    expect(Menu.IconMenuItem.id(item)).toBe("icon")
    expect(await Menu.IconMenuItem.text(item)).toBe("Save")
    await Menu.IconMenuItem.setText(item, "Save File")
    await Menu.IconMenuItem.setEnabled(item, false)
    await Menu.IconMenuItem.setAccelerator(item, "Cmd+S")
  })

  it("PredefinedMenuItem id / text / setText dispatch through IPC", async () => {
    const calls = []
    Mocks.mockIPC(async (cmd) => {
      calls.push(cmd)
      if (cmd.includes("new")) return [82, "sep"]
      if (cmd.includes("text")) return "Separator"
      return null
    })
    const item = await Menu.PredefinedMenuItem.make({ item: "Separator" })
    expect(Menu.PredefinedMenuItem.id(item)).toBe("sep")
    expect(await Menu.PredefinedMenuItem.text(item)).toBe("Separator")
    await Menu.PredefinedMenuItem.setText(item, "---")
  })
})

describe("Menu.PredefinedMenuItem variant encoding", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  const stringVariants = [
    "Separator",
    "Copy",
    "Cut",
    "Paste",
    "SelectAll",
    "Undo",
    "Redo",
    "Minimize",
    "Maximize",
    "Fullscreen",
    "Hide",
    "HideOthers",
    "ShowAll",
    "CloseWindow",
    "Quit",
    "Services",
    "BringAllToFront",
  ]

  for (const variant of stringVariants) {
    it(`encodes the ${variant} variant as the upstream string "${variant}"`, async () => {
      let captured
      Mocks.mockIPC(async (cmd, args) => {
        if (cmd.includes("new")) {
          captured = args
          return [100, variant.toLowerCase()]
        }
        return null
      })
      // ReScript's variant constructors without payloads compile to
      // plain strings, so { item: "Cut" } at the JS layer matches
      // ReScript's `Cut` variant.
      await Menu.PredefinedMenuItem.make({ item: variant })
      expect(captured.options.item).toBe(variant)
    })
  }
})

// IconMenuItem.options.icon is polymorphic — we cover the "uses a
// nativeIcon polymorphic variant" pathway here. The variant compiles
// to a plain string, so `{ icon: "Add" }` reaches upstream as-is.
describe("Menu.IconMenuItem with NativeIcon", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  // Representative selection from the 56-element nativeIcon enum.
  const nativeIconValues = ["Add", "Bluetooth", "User", "TrashEmpty", "Network"]

  for (const icon of nativeIconValues) {
    it(`accepts the ${icon} NativeIcon and forwards it to plugin:menu|new`, async () => {
      let captured
      Mocks.mockIPC(async (cmd, args) => {
        if (cmd.includes("new")) {
          captured = args
          return [200, icon.toLowerCase()]
        }
        return null
      })
      await Menu.IconMenuItem.make({
        id: `icon-${icon}`,
        text: icon,
        icon,
      })
      // ReScript polyvariants compile to bare strings, and upstream
      // forwards the `icon` field through transformImage. We assert
      // the round-trip lands with the expected string identifier.
      expect(captured.options.icon).toBe(icon)
    })
  }
})
