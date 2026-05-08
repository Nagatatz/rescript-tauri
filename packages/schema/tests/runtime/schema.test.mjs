import * as Core from "@rescript-tauri/core/src/Core.res.mjs"

// Imports the compiled JS from the workspace-resolved dependency so
// the tests exercise the same artifacts that `npm publish` would
// ship.
import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
import * as S from "rescript-schema/src/S.res.mjs"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as Schema from "../../src/Schema.res.mjs"

// ReScript's `result` runtime representation:
//   Ok(v)    →  { TAG: "Ok", _0: v }
//   Error(v) →  { TAG: "Error", _0: v }
//   DecodeError(s) → { TAG: "DecodeError", _0: s }
//   RustError(j)   → { TAG: "RustError", _0: j }
const Ok = (v) => ({ TAG: "Ok", _0: v })

describe("Schema", () => {
  beforeEach(() => {
    // mockIPC must be reset per-test so cross-test handlers don't bleed
    Mocks.clearMocks()
  })

  afterEach(() => {
    Mocks.clearMocks()
  })

  describe("fromSchemas", () => {
    it("succeeds with a string round-trip", async () => {
      Mocks.mockIPC(async (cmd, args) => {
        expect(cmd).toBe("greet")
        expect(args).toEqual({ name: "ReScript" })
        return "hello, ReScript"
      })

      const greet = Schema.fromSchemas(
        "greet",
        S.object((s) => ({ name: s.field("name", S.string) })),
        S.string,
      )

      const result = await Core.Command.invoke(greet, { name: "ReScript" })
      expect(result).toEqual(Ok("hello, ReScript"))
    })

    it("surfaces a schema mismatch as Error(DecodeError(msg))", async () => {
      Mocks.mockIPC(async () => 42) // returns int but schema expects string

      const greet = Schema.fromSchemas(
        "greet",
        S.object((s) => ({ name: s.field("name", S.string) })),
        S.string,
      )

      const result = await Core.Command.invoke(greet, { name: "ReScript" })
      expect(result.TAG).toBe("Error")
      expect(result._0.TAG).toBe("DecodeError")
      expect(typeof result._0._0).toBe("string")
    })
  })

  describe("toDecoder", () => {
    it("returns Ok on a successful parse", () => {
      const decode = Schema.toDecoder(S.string)
      expect(decode("hello")).toEqual(Ok("hello"))
    })

    it("returns Error(message) when the value does not match", () => {
      const decode = Schema.toDecoder(S.string)
      const result = decode(42)
      expect(result.TAG).toBe("Error")
      expect(typeof result._0).toBe("string")
      expect(result._0.length).toBeGreaterThan(0)
    })
  })

  describe("channelFromSchema", () => {
    it("constructs a Channel that decodes via the schema", () => {
      // Channel construction depends on the underlying tauri JS class
      // installed via __TAURI_INTERNALS__.transformCallback. Stub the
      // minimum surface so the decoder path can be exercised.
      globalThis.window = globalThis.window ?? {}
      let nextId = 200
      const callbacks = new Map()
      globalThis.window.__TAURI_INTERNALS__ = {
        transformCallback: (cb) => {
          const id = nextId++
          callbacks.set(id, cb)
          return id
        },
      }

      const ch = Schema.channelFromSchema(S.float)
      const received = []
      Core.Channel.onMessage(ch, (result) => received.push(result))

      const id = Core.Channel.id(ch)
      const cb = callbacks.get(id)
      cb({ index: 0, message: 7 })
      cb({ index: 1, message: "not a number" })

      expect(received).toHaveLength(2)
      expect(received[0]).toEqual(Ok(7))
      expect(received[1].TAG).toBe("Error")

      delete globalThis.window.__TAURI_INTERNALS__
    })
  })
})
