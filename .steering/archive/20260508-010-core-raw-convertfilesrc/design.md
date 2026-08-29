# 設計: Core.Raw.convertFileSrc 追加

## ファイル変更

### `packages/core/src/Core.res`

`module Raw` 内に追加:

```rescript
@module("@tauri-apps/api/core")
external convertFileSrc: (string, ~protocol: string=?) => string = "convertFileSrc"
```

### `packages/core/src/Core.resi`

`module Raw: { ... }` 内に追加:

```rescript
/** Converts a file path into a URL accessible by the webview.

    Tauri's protocol scheme (`asset://`, `https://asset.localhost/...`)
    differs across OSes; `convertFileSrc` returns the right URL for
    the current platform.

    See: https://v2.tauri.app/reference/javascript/api/namespacecore/#convertfilesrc

    ## Example

    ```rescript
    let url = Tauri.Core.Raw.convertFileSrc("/Users/me/photo.png")
    ```
*/
let convertFileSrc: (string, ~protocol: string=?) => string
```

### `packages/core/tests/core_raw_signature.res`

追加:

```rescript
let _check_convert_signature: (string, ~protocol: string=?) => string =
  Core.Raw.convertFileSrc
```

### `packages/core/tests/runtime/core_raw_convert.test.mjs` (新規)

```javascript
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

const installMock = (handler) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = globalThis.window.__TAURI_INTERNALS__ ?? {}
  globalThis.window.__TAURI_INTERNALS__.convertFileSrc = handler
}

const clearMock = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}

describe("Core.Raw.convertFileSrc", () => {
  beforeEach(clearMock)
  afterEach(clearMock)

  it("returns a string URL for the given file path (with default protocol)", async () => {
    const handler = vi.fn((path, protocol) => {
      expect(path).toBe("/Users/me/photo.png")
      return `asset://${protocol ?? "asset"}/${path}`
    })
    installMock(handler)

    const { Raw } = await import("../../src/Core.res.mjs")
    const url = Raw.convertFileSrc("/Users/me/photo.png")

    expect(handler).toHaveBeenCalledTimes(1)
    expect(typeof url).toBe("string")
  })

  it("forwards an explicit protocol argument", async () => {
    const handler = vi.fn((path, protocol) => `${protocol}://${path}`)
    installMock(handler)

    const { Raw } = await import("../../src/Core.res.mjs")
    const url = Raw.convertFileSrc("/tmp/x", "stream")

    expect(handler).toHaveBeenCalledWith("/tmp/x", "stream")
    expect(url).toBe("stream:///tmp/x")
  })
})
```

> **注**: `@tauri-apps/api/core` の `convertFileSrc` 実装が `window.__TAURI_INTERNALS__.convertFileSrc` を呼ぶ前提。実装で異なる場合（純関数で URL を組み立てるなど）はテストを最小化（戻り値が string であることだけ確認）に切り替える。

## コミット粒度

| # | コミット |
|---|---|
| 1 | 📝 Add steering for 20260508-010 (core-raw-convertfilesrc) |
| 2 | ✨ Add Core.Raw.convertFileSrc binding |
| 3 | ✅ Extend Core.Raw signature test + runtime test |
| 4 | 📝 Mark steering 20260508-010 complete |

## worktree

`EnterWorktree(name="core-raw-convertfilesrc")`、main 直接 commit 1 + worktree 内 commits 2-4 + マージ。
