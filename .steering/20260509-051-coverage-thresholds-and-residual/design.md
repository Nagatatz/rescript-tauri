# Coverage しきい値ゲートと残カバレッジ補強 — 設計 (design.md)

## 1. 進行戦略

| 項目 | 内容 |
|---|---|
| 作業形態 | 単一 worktree (`worktree-coverage-thresholds-and-residual`) で順次実装 |
| コミット粒度 | テーマ別 (Tray channel / Webview drag-drop / Menu predefined / steering 049 API / thresholds / docs) で分割 |
| 検証ループ | 各コミット前に `pnpm --filter @rescript-tauri/core test:coverage` を実行し数値を確認、しきい値導入前に Scope A 完了の実測を取る |

## 2. Scope A 詳細設計

### 2.1 Tray action callback 配信

`Tray.make({action: handler})` の動線:

1. ReScript 側で `action: trayIconEvent => unit` を渡す
2. `Tray.res` の `make` ラッパが `action: raw => handler(_eventFromJs(raw))` に変換
3. 上流 `TrayIcon.new(opts)` が opts.action を `Channel` の `onmessage` に登録
4. Tauri ランタイムがイベント発火時に Channel.send を呼び、callback が起動

happy-dom 環境では Tauri ランタイムが存在しないので、**Channel callback を直接呼ぶ**ことで配信をシミュレートする。`packages/schema/tests/runtime/schema.test.mjs` のパターンを参考に:

```js
const callbacks = new Map()
let nextId = 1
globalThis.window = globalThis.window ?? {}
globalThis.window.__TAURI_INTERNALS__ = {
  invoke: async (cmd) => {
    if (cmd.includes("new")) return [42, "tray-1"]
    return null
  },
  transformCallback: (cb) => {
    const id = nextId++
    callbacks.set(id, cb)
    return id
  },
}

let received
const tray = await Tray.make({
  action: (event) => { received = event },
})

// transformCallback は最後に登録された ID を割り当てる。
// Channel.send 相当: callbacks.get(id)({index, message: rawTrayPayload})
const id = nextId - 1
const cb = callbacks.get(id)
cb({ index: 0, message: {
  type: "Click",
  id: "tray-1",
  position: { x: 100, y: 200 },
  rect: { position: { x: 0, y: 0 }, size: { width: 16, height: 16 } },
  button: "Left",
  buttonState: "Down",
}})

expect(received).toMatchObject({ TAG: "Click", id: "tray-1", button: "Left" })
```

各バリアント (`Click` / `DoubleClick` / `Enter` / `Move` / `Leave`) を別々の it で検証、unknown kind のフォールバックも 1 ケース追加。

### 2.2 Webview onDragDropEvent variant 解釈

`Webview.res:53` の `onDragDropEvent` は Tauri Event API 経由で `tauri://drag-*` イベントを listen するので、Channel ではなく Event listener として実装される。

実装手段: `Mocks.mockIPC` で `plugin:webview|create_webview_window` 等の constructor 呼び出しを stub したあと、上流 `getCurrentWebview` 呼び出しで取得した webview に `onDragDropEvent` を登録。Tauri の event bridge は `listen(name, handler)` の handler を `__TAURI_INTERNALS__.transformCallback(handler)` 経由で受け取る。callback ID を経由して各 variant を発火する。

ただし `_onDragDropEvent` は `@send` で webview インスタンスメソッドを直接呼ぶため、上流 JS が `invoke('plugin:event|listen')` を内部で発行する流れになる。テストでは:

1. `Mocks.mockIPC` で `listen` 系コマンドを拦截し、callback ID を割り出す
2. `transformCallback` の Map から callback を取得
3. `enter` / `over` / `drop` / `leave` 各 type のペイロードを直接呼ぶ
4. handler に届いた variant を assertion

unknown kind の場合: `console.warn` の spy で 1 回呼ばれることを確認。

### 2.3 Menu PredefinedItem 全バリアント

`_predefinedToJs` は Menu.res の **internal** （`.resi` 非公開）。直接テストするには:

- 公開 `PredefinedMenuItem.make({item: <variant>})` 経由で呼び、`Mocks.mockIPC` の `args.options.item` をスナップショット的に検証
- 17 variant それぞれを 1 it に詰める（パラメータ化）

```js
const variants = [
  "Separator", "Copy", "Cut", "Paste", "SelectAll",
  "Undo", "Redo", "Minimize", "Maximize", "Fullscreen",
  "Hide", "HideOthers", "ShowAll", "CloseWindow", "Quit",
  "Services", "BringAllToFront",
]

for (const v of variants) {
  it(`PredefinedItem.${v} encodes as the upstream string`, async () => {
    let captured
    Mocks.mockIPC(async (cmd, args) => {
      if (cmd.includes("new")) {
        captured = args
        return [50, v.toLowerCase()]
      }
      return null
    })
    await Menu.PredefinedMenuItem.make({ item: v })
    expect(captured.options.item).toBe(v)
  })
}
```

`About(meta)` は別 it（既存）。

`NativeIcon` enum: 同様に Menu の IconMenuItem `make({icon: <NativeIcon variant>})` を呼び、`args.options.icon` が文字列値として乗ることを検証する。

### 2.4 steering 049 新 API

#### 2.4.1 `Core.isTauri`

Tauri.isTauri は `globalThis.isTauri` 真偽値を読む。テストは:

```js
delete globalThis.isTauri
expect(Core.isTauri()).toBe(false)
globalThis.isTauri = true
expect(Core.isTauri()).toBe(true)
```

#### 2.4.2 `Core.Resource`

`Resource` は abstract base class で `rid` getter と `close()` を持つ。直接 instantiate してテストすることはできない（プライベートフィールドつき）。代わりに既存の `Image.fromPath` 等の Resource subclass を作って `Core.Resource.rid` / `Core.Resource.close` を呼ぶ。

```js
const img = await Image.fromPath("/x")
expect(Core.Resource.rid(img)).toBe(<expected rid>)
await Core.Resource.close(img) // plugin:resources|close
```

#### 2.4.3 `Core.PluginListener` / `addPluginListener`

`addPluginListener` は upstream で:
```ts
async function addPluginListener<T>(plugin, event, cb): Promise<PluginListener>
```

mockIPC で `plugin:<plugin>|register_listener` を拦截、戻り値の listener オブジェクトに対して `unregister()` を呼ぶ。

#### 2.4.4 `Core.checkPermissions` / `requestPermissions`

mockIPC で `plugin:<plugin>|check_permissions` / `plugin:<plugin>|request_permissions` を拦截し戻り値を assertion する。

#### 2.4.5 `Core.transformCallback`

`__TAURI_INTERNALS__.transformCallback` を installInternals で stub 済みの状態で `Core.transformCallback(handler)` を呼び、返ってきた数値が Tauri 内部 ID であることを確認する。

#### 2.4.6 `Mocks.mockConvertFileSrc`

```js
Mocks.mockConvertFileSrc(async (path, protocol) => `mocked://${protocol}/${path}`)
const url = Core.Raw.convertFileSrc("/x", "asset")
expect(url).toBe("mocked://asset//x")
```

#### 2.4.7 Event TauriEvent enum + ~target

```js
expect(Event.TauriEvent.windowResized).toBe("tauri://resize")
expect(Event.TauriEvent.dragDrop).toBe("tauri://drag-drop")

// listen(~target)
let captured
Mocks.mockIPC(async (cmd, args) => {
  captured = { cmd, args }
  return 1
})
const evt = Event.make("custom", json => Ok(...))
await Event.listen(evt, () => {}, ~target=Event.Window("main"))
// the JS-side listenOptions.target should appear in captured args
```

#### 2.4.8 Window 新メソッド

`activityName` / `sceneIdentifier` / `setFocusable` / `setSimpleFullscreen` / `toggleMaximize` / `unminimize` / `onDragDropEvent` を window.test.mjs の "void-returning setters" ブロックに追加。

#### 2.4.9 Webview 新メソッド

`clearAllBrowsingData` / `getByLabel` を webview.test.mjs に追加。

## 3. Scope B 詳細設計

各 `vitest.config.mjs` に `thresholds` を追加:

```js
coverage: {
  provider: "v8",
  include: ["src/**/*.res.mjs"],
  exclude: ["src/**/*.test.mjs", "tests/**", "node_modules/**", "lib/**"],
  reporter: ["text-summary", "json-summary", "lcov", "html"],
  reportsDirectory: "./coverage",
  reportOnFailure: false,
  thresholds: {
    statements: 90,
    branches: 60,
    functions: 95,
    lines: 90,
  },
},
```

実測値が決まってから具体的な数値を確定する（最終的には Scope A 完了後の実測値マイナス 2-3 ポイント）。

vitest は thresholds 違反で exit 非 0 を返すので、CI ジョブ `tests-coverage.yml` は追加変更不要 — `pnpm --filter ... test:coverage` の戻り値で fail する。

ただし、coverage summary を生成するステップ (`packages/${pkg}/coverage/coverage-summary.json` を読む jq ステップ) がスキップされないように `if: always()` を確認しておく（既存の通り）。

## 4. Scope C 詳細設計

更新ファイル:

1. `docs/functional-design.md` §6 — `tests-coverage` 行の「観測フェーズ：しきい値による fail ゲートは設定しない」記述を更新
2. `docs/product-requirements.md` §5.4 — coverage thresholds 確定の旨を追記
3. `sphinx-docs/dev/architecture.md` §テスト — 触れていれば同期

## 5. リスク

| リスク | 緩和策 |
|---|---|
| Tray callback / Webview drag-drop の Channel/Event 配信が happy-dom で再現困難 | callback Map + 直接呼び出しパターンで簡略化。失敗したら "registration が起こる" レベルに退避 |
| しきい値が厳しすぎて誤計測ジッタで CI が割れる | 実測値マイナス 2-3 ポイントの安全マージン |
| steering 049 の新 API 実装が想定と違う | 着手時に各 .res / .resi を grep して実体を確認 |
| 並行で他のステアリングが API を追加 | merge コンフリクトで対処、想定の 1 つ |

## 6. テスト方針

スコープごとに:

```bash
pnpm --filter @rescript-tauri/core test:coverage
```

を実行し、対象モジュールのカバレッジ上昇を確認してからコミット。最後にルートで全パッケージ:

```bash
pnpm --recursive build
pnpm --recursive test
pnpm run check
for pkg in core plugin-fs plugin-dialog schema; do
  pnpm --filter @rescript-tauri/$pkg test:coverage
done
```
