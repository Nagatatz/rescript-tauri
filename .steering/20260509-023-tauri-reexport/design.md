# Design: Tauri.res 上位 re-export

## 配置

`packages/core/src/Tauri.res` / `Tauri.resi` のみを追加。

## ファイル内容

```rescript
// Tauri.resi (doc-comment 略)
module Core = Core
module Event = Event
module Window = Window
module Webview = Webview
module WebviewWindow = WebviewWindow
```

`.res` も同じ内容。ReScript の module alias は型レベルのみ生成され、ランタイムコストはゼロ。

## ユーザー体験

```rescript
// パターン A: open Tauri （Phase 1 標準）
open Tauri
let win = Window.getCurrent()
let invoke = Core.Raw.invoke
let unlisten = await Event.listen(myEvent, _ => ())

// パターン B: 明示参照
let dir = await Path.appConfigDir()  // open しなくても直接アクセス
let img = await Image.fromPath("/tmp/icon.png")

// パターン C: 混在
open Tauri
let menu = await Menu.Menu.make()  // Tauri に Menu はないため fully qualified
```

## 含めない判断

- **Path / App / Dpi**：utility namespace。`open Tauri` 後に `appConfigDir / appDataDir` などが大量に exposed されると名前空間衝突が起きやすい。明示インポート推奨。
- **Menu / Tray**：複雑なサブモジュール構造（`Menu.MenuItem`, `Menu.Submenu`, ...）。`Tauri.Menu.Menu.t` のようなパスを避けるため re-export しない。
- **Image**：opaque リソース。明示的なインポートでライフサイクルを意識させる。
- **Mocks**：テスト専用なので production code で `open Tauri` 経由に出さない方が安全。

## テスト

`tests/tauri_signature.res` で `Tauri.Core.Raw.invoke` 等が型上問題なく参照できることを確認。`open Tauri` を使うと `WebviewWindow` シャドーイング警告が出るため、明示パスでのテストとした。

## CI 影響

- 公開シンボル 290 / 310（`tests/tauri_signature.res` で 11 個追加 → 310 維持済）。
- doc-link-lint: `Tauri.resi` に Tauri 公式 URL 含む。
- PRD §10 #1 を「確定済み」状態に更新。
