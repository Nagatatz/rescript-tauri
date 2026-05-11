import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import { installTauriInternals } from "../../../../tools/tauri-mocks.mjs"
import * as PluginHttp from "../../src/PluginHttp.res.mjs"

// plugin-http's `fetch` calls the upstream Tauri-bridged fetch which
// internally uses Tauri's IPC. Stub __TAURI_INTERNALS__ so the upstream
// fetch can dispatch through it without throwing.

describe("PluginHttp", () => {
  let cleanup
  beforeEach(() => {
    cleanup = installTauriInternals({ invoke: vi.fn(async () => 0) })
  })
  afterEach(() => cleanup())

  it("fetch is a function exported from the package", () => {
    expect(typeof PluginHttp.fetch).toBe("function")
  })

  it("fetch returns a promise when called with a URL string", () => {
    // The upstream impl issues several IPC calls; we don't assert on
    // their exact shape here (it's an upstream implementation detail).
    // We only verify the call shape: a string in, a Promise out.
    let raised = null
    let promise
    try {
      promise = PluginHttp.fetch("https://example.com")
    } catch (err) {
      raised = err
    }
    expect(raised).toBeNull()
    expect(promise).toBeInstanceOf(Promise)
    // Swallow the eventual resolution / rejection — we only care that
    // the wrapper invoked the upstream fn without a synchronous
    // throw. The full HTTP flow needs Tauri runtime support and is
    // out of scope for unit tests.
    promise.catch(() => {})
  })

  it("fetch accepts ~init with proxy / clientOptions fields without throwing", () => {
    const init = {
      method: "GET",
      maxRedirections: 5,
      connectTimeout: 30000,
      proxy: { all: "http://corp-proxy:8080" },
      danger: { acceptInvalidCerts: false },
    }
    const promise = PluginHttp.fetch("https://example.com", init)
    expect(promise).toBeInstanceOf(Promise)
    promise.catch(() => {})
  })
})
