import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import * as PluginHttp from "../../src/PluginHttp.res.mjs"

// plugin-http's `fetch` calls the upstream Tauri-bridged fetch which
// internally uses Tauri's IPC, but the JS shim re-exports a regular
// async function. For unit tests we spy on the upstream module's
// fetch via a vi.mock-style stub on the imported module's prototype
// chain. happy-dom's `globalThis.fetch` doesn't help here because
// PluginHttp imports the named export directly. The cleanest test
// is to replace `globalThis.fetch` and have the upstream re-implement
// fetch on top of it; but the actual upstream impl wires through
// Tauri internals. Stub `__TAURI_INTERNALS__.invoke` so the upstream
// fetch can dispatch through it without errors.

const installInternals = () => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = {
    invoke: vi.fn(async (_cmd, _args) => {
      // Return a fake `rid` for fetch_send / fetch_read paths.
      return 0
    }),
    transformCallback: () => 0,
  }
}

const clearInternals = () => {
  if (globalThis.window) {
    delete globalThis.window.__TAURI_INTERNALS__
  }
}

describe("PluginHttp", () => {
  beforeEach(installInternals)
  afterEach(clearInternals)

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
