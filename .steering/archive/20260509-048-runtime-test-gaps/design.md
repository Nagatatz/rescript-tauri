# Runtime テストギャップ補強 — 設計 (design.md)

## 1. 進行戦略

| 項目 | 内容 |
|---|---|
| 作業形態 | 単一 worktree (`worktree-runtime-test-gaps`) で順次実装 |
| コミット粒度 | パッケージ単位 (core 新規 8 / core Window 補強 / plugin-fs / schema) で分割 |
| 検証ループ | 各コミット前に `test:coverage` 実行、0% モジュールが上昇していることを確認 |

## 2. テスト記述スタイル

### 2.1 共通パターン

`packages/core/tests/runtime/window.test.mjs` の `installInternals` パターンと、
`packages/plugin-fs/tests/runtime/plugin_fs.test.mjs` の `Mocks.mockIPC` パターンを
**Mocks.mockIPC ベースに統一**して新規テストに採用する。

理由:
- 公式テスト推奨パターン
- `clearMocks` でリセットが効く
- 上流が runtime を変更しても `__TAURI_INTERNALS__` 直接 set より追従しやすい

雛形:

```js
import * as Mocks from "../../src/Mocks.res.mjs"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import * as App from "../../src/App.res.mjs"

describe("App", () => {
  beforeEach(() => Mocks.clearMocks())
  afterEach(() => Mocks.clearMocks())

  it("getName returns the value the rust side resolves with", async () => {
    Mocks.mockIPC(async (cmd) => {
      // 上流 @tauri-apps/api/app は plugin:app|name コマンドを発火する想定。
      // コマンド名は将来変更され得るので exact match よりは substring を使う。
      if (cmd.includes("name")) return "rescript-tauri-demo"
      return null
    })
    const v = await App.getName()
    expect(v).toBe("rescript-tauri-demo")
  })
})
```

**ポイント:**
- コマンド名 (`plugin:app|name` 等) は `cmd.includes("name")` のような緩い一致で検証する。Tauri の上流が minor で `plugin:app|get_name` 等にリネームしても誤検知しないため。
- 戻り値は `Mocks.mockIPC` の handler で構築し、`expect` で受け取り側に届くことを確認する。
- 例外的に Dpi は IPC を発生させないので Mocks 不要、純 JS 構築テストでよい。

### 2.2 class-based API テスト

Tray / Menu / Image / Webview / WebviewWindow など `@new` でクラスをインスタンス化する API は、上流クラスが内部で `invoke()` を呼ぶ。`Mocks.mockIPC` の handler を「呼ばれたコマンドに応じた値を返す `if` チェイン」にして、複数の class メソッドを 1 ファイルでまとめてカバーする。

例:

```js
it("Tray.make + setTitle + close end-to-end", async () => {
  let calls = []
  Mocks.mockIPC(async (cmd, args) => {
    calls.push({ cmd, args })
    if (cmd.includes("new")) return 42 // tray rid
    return null
  })
  const tray = await Tray.make()
  await Tray.setTitle(tray, Nullable.make("Hi"))
  await Tray.close(tray)
  expect(calls.map(c => c.cmd)).toEqual(
    expect.arrayContaining([
      expect.stringContaining("new"),
      expect.stringContaining("set_title"),
      expect.stringContaining("close"),
    ]),
  )
})
```

ただし Tauri 上流の class 内部実装でモック handler の戻り値を**特定の型に強制**しているケース (例: `Image.new_` は内部の rid 番号を期待) があるので、各テスト書き起こし時に上流 `node_modules/@tauri-apps/api/*` のソースを確認しながら適切なダミー値を返すこと。

### 2.3 Dpi の特殊扱い

`Dpi` モジュールは `@module("@tauri-apps/api/dpi") @new` で純粋に JS class をインスタンス化するだけ。IPC は発生しない。テストは:

```js
it("LogicalSize.make stores width / height", async () => {
  const Dpi = await import("../../src/Dpi.res.mjs")
  const s = Dpi.LogicalSize.make(800, 600)
  expect(Dpi.LogicalSize.width(s)).toBe(800)
  expect(Dpi.LogicalSize.height(s)).toBe(600)
})
```

の形でよい。`Mocks.mockIPC` 不要。

ただし `LogicalSize.make` のシグネチャが `(~width, ~height) => t` で labelled — JS から見ると `{width, height}` オブジェクトを 1 引数で渡す形になるので、`@rescript/runtime` がどう uncurry するかを確認しながら呼ぶ。実際のコンパイル後の `Dpi.res.mjs` を覗いて素直に呼ぶのが確実。

## 3. ファイル別詳細設計

### 3.1 `app.test.mjs`

- 9 関数 (`getName`, `getVersion`, `getTauriVersion`, `getIdentifier`, `show`, `hide`, `defaultWindowIcon`, `setTheme`, `setDockVisibility`)
- describe を 1 つ、it を 6〜9 個
- `setTheme` は `Nullable.null` と `Nullable.make(#dark)` の両ケース
- `defaultWindowIcon` は `null` / 非 null 戻り両方

### 3.2 `dpi.test.mjs`

- IPC モック不要
- describe 4 つ (LogicalSize / PhysicalSize / LogicalPosition / PhysicalPosition / Size / Position)
- 各 `make` + getter + 変換 (`toLogical` / `toPhysical`) を確認
- `Size.fromLogical` / `Size.fromPhysical` のラッパも 1 ケースずつ

### 3.3 `image.test.mjs`

- `Image.new_(~rgba, ~width, ~height)` の構築
- `fromBytes` / `fromPath` の各 1 ケース
- 構築済み `Image.t` から `rgba` / `size` を取り出す

### 3.4 `menu.test.mjs`

- 各 module (`MenuItem` / `CheckMenuItem` / `IconMenuItem` / `PredefinedMenuItem` / `Submenu` / `Menu`) の `make` を 1 ケース
- 共通 6 メソッド (id / text / setText / isEnabled / setEnabled / setAccelerator) は MenuItem で代表的に確認、他は make のみで OK
- `Submenu.append` / `Submenu.remove` / `Submenu.popup` を 1 ケース
- `Menu.default` / `Menu.setAsAppMenu` を 1 ケース
- `predefinedItem` の `Separator` / `About(meta)` の 2 ケース確認

### 3.5 `path.test.mjs`

- 23 関数 (各 *Dir + join / resolve / dirname / basename / extname / isAbsolute / sep / delimiter / normalize / resolveResource)
- describe を 2 つ程度に分け (`directory accessors` / `path operations`)
- `BaseDirectory.t` の 1 値が `int` として参照可能であることを確認

### 3.6 `tray.test.mjs`

- `make` (no options) + `make` (with options including action handler)
- `_eventFromJs` 経由でハンドラに各 trayIconEvent variant が届くシナリオは複雑なので、`Click` / `Enter` / `Leave` の 3 種に絞る
- `setIcon` (`Nullable.null` / `Nullable.make("...")`) / `setMenu` / `setTooltip` / `setTitle` の Nullable 引数を確認
- `getById` (null 戻り / 非 null 戻り)
- `close` の呼び出し

### 3.7 `webview.test.mjs`

- `getCurrentWebview` / `getAllWebviews`
- `Webview.t` のインスタンスメソッド `setSize` / `setPosition` / `position` / `size` / `setFocus` / `setAutoResize` / `hide` / `show` / `setZoom` / `reparent` / `setBackgroundColor` / `close`
- `onDragDropEvent` は `Mocks.mockIPC` だけでは事象を発火できない。代わりに `_onDragDropEvent` の登録が呼ばれた後 `unlisten` 関数を実際に呼べることだけ確認 (handler 配信は別件)
- 上記 14 メソッドを 1 it につき 3〜5 メソッド束ねて 4〜5 ケースに収める

### 3.8 `webview_window.test.mjs`

- `make("label", ~options=?)` で構築
- `getCurrent` / `getAll` / `getByLabel`
- `asWindow` / `asWebview` キャストの結果に対して `Window.label` / `Webview.label` を呼び、ラベルが取れること
- `setTitle` / `close` / `setBackgroundColor`

### 3.9 `window.test.mjs` 補強

既存 5 ケースに以下を追加:

- `setBackgroundColor` Nullable 両ケース
- `setTheme` Nullable 両ケース
- `monitorFromPoint(~x=100.0, ~y=200.0)` ラベル呼び出し
- `setSize(Dpi.Size.fromLogical(Dpi.LogicalSize.make(800, 600)))`
- `onResized` 登録 + unlisten 呼び出し

ファイル末尾に追記する。

### 3.10 plugin-fs 補強

`plugin_fs.test.mjs` 末尾に `readFile` / `writeFile` / `remove` / `rename` / `lstat` / `copyFile` / `truncate` / `size` を追加。`exists` の既存パターンに倣って 1 関数 1 it。

### 3.11 schema 補強

未カバー 1 関数を coverage HTML 起点で特定する手順:

```bash
pnpm --filter @rescript-tauri/schema test:coverage
cat packages/schema/coverage/coverage-summary.json | jq '."src/Schema.res.mjs"'
# functions.skipped or check coverage-final.json で uncovered な関数を特定
```

Schema.res の export は 4 関数 (`toDecoder`, `fromSchemas`, `channelFromSchema`, `eventFromSchema`)。runtime test (`schema.test.mjs`) は既存 5 ケース。

確認 → 多分 `eventFromSchema` (D-6 でラベル変更したばかりで test 未追加の可能性あり)。該当しなくても coverage-summary で特定可能。

## 4. 検証

各パッケージのコミット前に:

```bash
pnpm --filter @rescript-tauri/<pkg> test:coverage
```

を実行し、目標値を満たすことを確認。最後にルートで:

```bash
pnpm --recursive build
pnpm --recursive test
pnpm run check
```

を実行して全体緑を確認する。

## 5. リスク

| リスク | 緩和策 |
|---|---|
| 上流 Tauri JS class が happy-dom 環境で `Mocks.mockIPC` だけでは初期化に失敗する | エラー発生時はテスト粒度を「呼び出しが発火する」レベルに落として `expect(invoke).toHaveBeenCalled()` でアサート |
| 一部メソッド (`onDragDropEvent` 等) が現実の event を必要とする | 登録時に `Mocks.mockIPC` が呼ばれることだけ確認し、event payload の variant 解釈は別ステアリング (`_onDragDropEvent` ハンドラの単体テスト) で扱う |
| Menu / Tray の `action` callback テストが happy-dom で再現困難 | callback 登録だけ確認 |
| ReScript 12 の uncurried-by-default で labelled 引数の JS 上の形が変わっている | `Dpi.LogicalSize.make` 等は実際のコンパイル後 `.res.mjs` を Read で確認してから呼ぶ |
