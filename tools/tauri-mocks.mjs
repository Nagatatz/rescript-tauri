/**
 * Shared install/cleanup helpers for the Tauri global stubs that
 * `@rescript-tauri/plugin-*` runtime tests need when their upstream
 * implementation bypasses `Mocks.mockIPC` and reads from a global
 * `window.__TAURI_*` slot directly.
 *
 * Each helper installs the stub on `globalThis.window` and returns a
 * cleanup function. The intended call shape:
 *
 *     let cleanup
 *     beforeEach(() => { cleanup = installTauriInternals({...}) })
 *     afterEach(() => cleanup())
 *
 * For tests that only use `Mocks.mockIPC` (e.g. plugin-{fs,dialog,shell,
 * clipboard-manager}) no helper is needed.
 */

/**
 * Stub `window.__TAURI_INTERNALS__`, the low-level IPC bridge that
 * upstream `@tauri-apps/plugin-http` and the event-listener path in
 * `@tauri-apps/plugin-log` invoke directly.
 *
 * @param {object} [options]
 * @param {(cmd: string, args?: any) => Promise<any>} [options.invoke]
 *   Replacement for the bridged `invoke`. Defaults to `async () => null`.
 * @param {(cb: Function) => number} [options.transformCallback]
 *   Replacement for `transformCallback`. Defaults to a Map-backed factory
 *   that hands out monotonically increasing ids starting at 1000.
 * @returns {() => void} Removes the stub from `window`.
 */
export function installTauriInternals({ invoke, transformCallback } = {}) {
  globalThis.window = globalThis.window ?? {}
  const callbacks = new Map()
  let nextId = 1000
  globalThis.window.__TAURI_INTERNALS__ = {
    invoke: invoke ?? (async () => null),
    transformCallback:
      transformCallback ??
      ((cb) => {
        const id = nextId++
        callbacks.set(id, cb)
        return id
      }),
  }
  return () => {
    if (globalThis.window) {
      delete globalThis.window.__TAURI_INTERNALS__
    }
  }
}

/**
 * Stub `window.__TAURI_EVENT_PLUGIN_INTERNALS__`, used by upstream when
 * a listener is unregistered. The default `unregisterListener` is a no-op.
 *
 * @returns {() => void} Removes the stub from `window`.
 */
export function installEventPluginInternals() {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_EVENT_PLUGIN_INTERNALS__ = {
    unregisterListener: () => {},
  }
  return () => {
    if (globalThis.window) {
      delete globalThis.window.__TAURI_EVENT_PLUGIN_INTERNALS__
    }
  }
}

/**
 * Stub `window.__TAURI_OS_PLUGIN_INTERNALS__`, the compile-time globals
 * consumed by `@tauri-apps/plugin-os` synchronous getters (eol / platform
 * / family / version / osType / arch / exeExtension).
 *
 * @param {object} [overrides] Per-field overrides merged onto the macOS
 *   defaults. Useful for Windows / Linux scenarios.
 * @returns {() => void} Removes the stub from `window`.
 */
export function installOsPluginInternals(overrides = {}) {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_OS_PLUGIN_INTERNALS__ = {
    eol: "\n",
    os_type: "macos",
    platform: "macos",
    family: "unix",
    version: "14.0",
    arch: "aarch64",
    exe_extension: "",
    ...overrides,
  }
  return () => {
    if (globalThis.window) {
      delete globalThis.window.__TAURI_OS_PLUGIN_INTERNALS__
    }
  }
}

/**
 * Replace `window.Notification` with the given implementation. Used by
 * `@rescript-tauri/plugin-notification` tests where upstream short-circuits
 * to the Web Notification API instead of dispatching through Tauri IPC.
 *
 * @param {Function | object} impl Constructor function or plain object
 *   exposing the fields the test under measure reads (e.g. `permission`,
 *   `requestPermission`).
 * @returns {() => void} Removes the stub from `window`.
 */
export function installNotificationStub(impl) {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.Notification = impl
  return () => {
    if (globalThis.window) {
      delete globalThis.window.Notification
    }
  }
}
