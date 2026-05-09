import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import * as PluginNotification from "../../src/PluginNotification.res.mjs"

describe("PluginNotification", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => {
    Mocks.clearMocks()
    if (globalThis.window) {
      delete globalThis.window.Notification
    }
  })

  describe("IPC-backed functions", () => {
    it("isPermissionGranted dispatches plugin:notification|is_permission_granted when permission is 'default'", async () => {
      // Upstream short-circuits to window.Notification.permission unless
      // it is 'default'; stub that so the call falls through to IPC.
      globalThis.window.Notification = { permission: "default" }
      let captured = null
      Mocks.mockIPC(async (cmd) => {
        captured = cmd
        return true
      })
      const result = await PluginNotification.isPermissionGranted()
      expect(captured).toBe("plugin:notification|is_permission_granted")
      expect(result).toBe(true)
    })

    it("registerActionTypes dispatches plugin:notification|register_action_types", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })
      await PluginNotification.registerActionTypes([
        { id: "tauri", actions: [{ id: "a", title: "Open" }] },
      ])
      expect(captured.cmd).toBe("plugin:notification|register_action_types")
      expect(captured.args.types).toHaveLength(1)
    })

    it("pending dispatches plugin:notification|get_pending", async () => {
      Mocks.mockIPC(async (cmd) => {
        expect(cmd).toBe("plugin:notification|get_pending")
        return []
      })
      const result = await PluginNotification.pending()
      expect(result).toEqual([])
    })

    it("cancel dispatches plugin:notification|cancel with notifications array", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })
      await PluginNotification.cancel([1, 2, 3])
      expect(captured.cmd).toBe("plugin:notification|cancel")
      expect(captured.args.notifications).toEqual([1, 2, 3])
    })

    it("cancelAll dispatches plugin:notification|cancel (no args)", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })
      await PluginNotification.cancelAll()
      expect(captured.cmd).toBe("plugin:notification|cancel")
      expect(captured.args).toEqual({})
    })

    it("active dispatches plugin:notification|get_active", async () => {
      Mocks.mockIPC(async (cmd) => {
        expect(cmd).toBe("plugin:notification|get_active")
        return []
      })
      const result = await PluginNotification.active()
      expect(result).toEqual([])
    })

    it("removeActive dispatches plugin:notification|remove_active", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })
      await PluginNotification.removeActive([{ id: 42 }])
      expect(captured.cmd).toBe("plugin:notification|remove_active")
      expect(captured.args.notifications).toEqual([{ id: 42 }])
    })

    it("removeAllActive dispatches plugin:notification|remove_active (no args)", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd) => {
        captured = cmd
        return null
      })
      await PluginNotification.removeAllActive()
      expect(captured).toBe("plugin:notification|remove_active")
    })

    it("createChannel dispatches plugin:notification|create_channel", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })
      await PluginNotification.createChannel({ id: "c", name: "Default" })
      expect(captured.cmd).toBe("plugin:notification|create_channel")
      expect(captured.args.id).toBe("c")
      expect(captured.args.name).toBe("Default")
    })

    it("removeChannel dispatches plugin:notification|delete_channel", async () => {
      let captured = null
      Mocks.mockIPC(async (cmd, args) => {
        captured = { cmd, args }
        return null
      })
      await PluginNotification.removeChannel("c")
      expect(captured.cmd).toBe("plugin:notification|delete_channel")
      expect(captured.args.id).toBe("c")
    })

    it("channels dispatches plugin:notification|listChannels", async () => {
      Mocks.mockIPC(async (cmd) => {
        expect(cmd).toBe("plugin:notification|listChannels")
        return []
      })
      const result = await PluginNotification.channels()
      expect(result).toEqual([])
    })

    it("onNotificationReceived registers a plugin listener", async () => {
      const seen = []
      Mocks.mockIPC(async (cmd) => {
        seen.push(cmd)
        return 0
      })
      const listener = await PluginNotification.onNotificationReceived(() => {})
      expect(seen).toEqual(["plugin:notification|register_listener"])
      expect(typeof listener).toBe("object")
    })

    it("onAction registers a plugin listener", async () => {
      const seen = []
      Mocks.mockIPC(async (cmd) => {
        seen.push(cmd)
        return 0
      })
      const listener = await PluginNotification.onAction(() => {})
      expect(seen).toEqual(["plugin:notification|register_listener"])
      expect(typeof listener).toBe("object")
    })
  })

  describe("Web-API-backed functions", () => {
    it("requestPermission delegates to window.Notification.requestPermission", async () => {
      const stub = vi.fn().mockResolvedValue("granted")
      globalThis.window.Notification = { requestPermission: stub }

      const result = await PluginNotification.requestPermission()

      expect(stub).toHaveBeenCalledTimes(1)
      expect(result).toBe("granted")
    })

    it("sendNotificationText constructs new window.Notification(text)", () => {
      const constructed = []
      class FakeNotification {
        constructor(title, options) {
          constructed.push({ title, options })
        }
      }
      globalThis.window.Notification = FakeNotification

      PluginNotification.sendNotificationText("hello")

      expect(constructed).toHaveLength(1)
      expect(constructed[0].title).toBe("hello")
      expect(constructed[0].options).toBeUndefined()
    })

    it("sendNotification constructs new window.Notification(title, options)", () => {
      const constructed = []
      class FakeNotification {
        constructor(title, options) {
          constructed.push({ title, options })
        }
      }
      globalThis.window.Notification = FakeNotification

      PluginNotification.sendNotification({ title: "TAURI", body: "Hi" })

      expect(constructed).toHaveLength(1)
      expect(constructed[0].title).toBe("TAURI")
      expect(constructed[0].options.body).toBe("Hi")
    })
  })

  describe("Importance / Visibility constants", () => {
    it("Importance values match upstream numeric enum", () => {
      expect(PluginNotification.Importance.none).toBe(0)
      expect(PluginNotification.Importance.min).toBe(1)
      expect(PluginNotification.Importance.low).toBe(2)
      expect(PluginNotification.Importance.default_).toBe(3)
      expect(PluginNotification.Importance.high).toBe(4)
    })

    it("Visibility values match upstream numeric enum", () => {
      expect(PluginNotification.Visibility.secret).toBe(-1)
      expect(PluginNotification.Visibility.private_).toBe(0)
      expect(PluginNotification.Visibility.public_).toBe(1)
    })
  })

  describe("Schedule factories", () => {
    it("Schedule.at returns a Schedule instance with at populated", () => {
      const schedule = PluginNotification.Schedule.at(new Date("2030-01-01"))
      expect(schedule).toBeDefined()
      expect(schedule.at).toBeDefined()
    })

    it("Schedule.interval returns a Schedule instance with interval populated", () => {
      const schedule = PluginNotification.Schedule.interval({ hour: 9 })
      expect(schedule).toBeDefined()
      expect(schedule.interval).toBeDefined()
    })

    it("Schedule.every returns a Schedule instance with every populated", () => {
      const schedule = PluginNotification.Schedule.every("day", 1)
      expect(schedule).toBeDefined()
      expect(schedule.every).toBeDefined()
    })
  })
})
