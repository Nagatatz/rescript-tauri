# Design: 共有 Tauri モック ヘルパ

## 配置

`tools/tauri-mocks.mjs` （`tools/vitest.shared.mjs` と同じ階層）。pnpm workspace 内部の素の Node スクリプトで、`packages/plugin-*/tests/runtime/*.test.mjs` から相対 import で利用する。

```
plugin-X/tests/runtime/plugin_X.test.mjs
  ↓ import
../../../../tools/tauri-mocks.mjs
```

`tools/vitest.shared.mjs` は `../../tools/vitest.shared.mjs`（`vitest.config.mjs` から）だが、テストファイルは `tests/runtime/` 配下にあるため `../../../tools/tauri-mocks.mjs` ではなく `../../../../tools/tauri-mocks.mjs`。実際には plugin 階層が `packages/plugin-X/tests/runtime/*.test.mjs` なので 4 階層上に戻る必要がある。

→ 検証コマンド: `node -e "console.log(require.resolve('../../../../tools/tauri-mocks.mjs'))"` を plugin 内で実行。

## API 設計

### 1. `installTauriInternals(options?)`

`window.__TAURI_INTERNALS__` を設定。

```js
/**
 * @param {object} [options]
 * @param {(cmd: string, args?: any) => Promise<any>} [options.invoke]
 * @param {(cb: Function) => number} [options.transformCallback]
 * @returns {() => void} cleanup
 */
export function installTauriInternals(options = {})
```

デフォルト動作:
- `invoke`: `async () => null`（呼ばれても無害）
- `transformCallback`: 内部の `Map<id, cb>` に登録し連番 id を返す

http と log の現状 stub はほぼ同じ形なので両方で再利用可能。

### 2. `installEventPluginInternals()`

`window.__TAURI_EVENT_PLUGIN_INTERNALS__` を設定。`unregisterListener: () => {}` のみ。引数なし。

```js
/** @returns {() => void} cleanup */
export function installEventPluginInternals()
```

### 3. `installOsPluginInternals(overrides?)`

`window.__TAURI_OS_PLUGIN_INTERNALS__` を設定。デフォルト値は plugin-os の現状テストに合わせる:

```js
{
  eol: "\n",
  os_type: "macos",
  platform: "macos",
  family: "unix",
  version: "14.0",
  arch: "aarch64",
  exe_extension: "",
}
```

`overrides` で個別フィールドを上書き可能（将来 Windows のテストを足す等）。

### 4. `installNotificationStub(impl)`

`window.Notification` を `impl` で置き換える。引数は必須（class / object / vi.fn の wrap）。

```js
/**
 * @param {Function | object} impl
 * @returns {() => void} cleanup
 */
export function installNotificationStub(impl)
```

## 使用例

### Before (plugin-http)

```js
const installInternals = () => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = {
    invoke: vi.fn(async () => 0),
    transformCallback: () => 0,
  }
}
const clearInternals = () => {
  if (globalThis.window) delete globalThis.window.__TAURI_INTERNALS__
}
describe("PluginHttp", () => {
  beforeEach(installInternals)
  afterEach(clearInternals)
  // ...
})
```

### After

```js
import { installTauriInternals } from "../../../../tools/tauri-mocks.mjs"

describe("PluginHttp", () => {
  let cleanup
  beforeEach(() => {
    cleanup = installTauriInternals({ invoke: vi.fn(async () => 0) })
  })
  afterEach(() => cleanup())
  // ...
})
```

## cleanup 関数を返す理由

`afterEach` で stub を確実に削除するため、`install` と対称な `cleanup` をクロージャで返す。グローバル削除を helper 側で完結させることで、テスト側で `delete globalThis.window.X` を書く必要が無くなる。

複数 helper を同時に install するケース（plugin-log: `installTauriInternals` + `installEventPluginInternals`）は cleanup 関数を配列で保持して `afterEach` でまとめて呼ぶ。

## 既存 helper との関係

`tools/vitest.shared.mjs` は vitest config の factory のみで、テスト時に import するものではない。`tools/tauri-mocks.mjs` はテストファイルが直接 import する。役割が直交するので独立ファイルとする。

## リスク

- **import path の相対深さ** — `packages/plugin-X/tests/runtime/` から `tools/` まで 4 階層上。タイポ時にビルド前に発覚するため許容。
- **vi.fn のサイクル** — `installTauriInternals` のデフォルト invoke は `vi.fn` を使わないので副作用なし。テスト側で `vi.fn` をオプションで渡すパターンは現状通り。

## 非破壊性

- ReScript 側のコード変更なし
- 公開 API 表面に影響なし
- npm publish 内容に影響なし（tools/ は publish 対象外）
- CI workflow 変更なし
