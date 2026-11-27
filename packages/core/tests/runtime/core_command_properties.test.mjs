import fc from "fast-check"
import { expect, it } from "vitest"
import * as Mocks from "../../src/Mocks.res.mjs"

const name = process.env.RESCRIPT_TAURI_IPC_TEST_MODULE
const { Command } = name
  ? await import(/* @vite-ignore */ new URL(name, import.meta.url).href)
  : await import("../../src/Core.res.mjs")

it("routes generated IPC outcomes without confusing decode and backend failures", async () => {
  await fc.assert(
    fc.asyncProperty(fc.jsonValue(), fc.string(), async (payload, message) => {
      for (const outcome of ["success", "decode-error", "backend-error"]) {
        const dispatches = []
        let decodes = 0
        Mocks.mockIPC(async (cmd, args) => {
          dispatches.push({ cmd, args })
          if (outcome === "backend-error") throw new Error(message)
          return { payload }
        })
        try {
          const command = Command.make(
            "property_test",
            (value) => ({ payload: value }),
            (raw) => {
              decodes++
              expect(raw).toEqual({ payload })
              return outcome === "decode-error"
                ? { TAG: "Error", _0: message }
                : { TAG: "Ok", _0: raw.payload }
            },
          )
          const result = await Command.invoke(command, payload)
          if (outcome === "backend-error") {
            expect(result).toMatchObject({ TAG: "Error", _0: { TAG: "RustError" } })
            expect(decodes).toBe(0)
          } else if (outcome === "decode-error") {
            expect(result).toEqual({ TAG: "Error", _0: { TAG: "DecodeError", _0: message } })
            expect(decodes).toBe(1)
          } else {
            expect(result).toEqual({ TAG: "Ok", _0: payload })
            expect(decodes).toBe(1)
          }
          expect(dispatches).toEqual([{ cmd: "property_test", args: { payload } }])
        } finally {
          Mocks.clearMocks()
        }
      }
    }),
    { seed: 1127, numRuns: 100 },
  )
})
