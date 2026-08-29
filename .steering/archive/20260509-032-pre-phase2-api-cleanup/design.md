# Pre-Phase 2 API 表面クリーンアップ — 設計

## 設計方針

### 1. Dpi 型のポリモーフィック解消

#### Tauri JS SDK のシグネチャ

[公式リファレンス](https://v2.tauri.app/reference/javascript/api/namespacewindow/) に基づき、以下のマッピングで具体型化する。

| API | 引数 / 戻り値 | Tauri JS 型 | ReScript 型 |
|---|---|---|---|
| `setSize` | 引数 | `LogicalSize \| PhysicalSize \| Size` | `Dpi.Size.t` |
| `setMinSize` / `setMaxSize` | 引数 | 同上 \| null | `Nullable.t<Dpi.Size.t>` |
| `setPosition` / `setCursorPosition` | 引数 | `LogicalPosition \| PhysicalPosition \| Position` | `Dpi.Position.t` |
| `innerSize` / `outerSize` | 戻り値 | `Promise<PhysicalSize>` | `promise<Dpi.PhysicalSize.t>` |
| `innerPosition` / `outerPosition` | 戻り値 | `Promise<PhysicalPosition>` | `promise<Dpi.PhysicalPosition.t>` |
| `cursorPosition` | 戻り値 | `Promise<PhysicalPosition>` | `promise<Dpi.PhysicalPosition.t>` |
| `monitor.size` / `monitor.position` | フィールド | `PhysicalSize` / `PhysicalPosition` | `Dpi.PhysicalSize.t` / `Dpi.PhysicalPosition.t` |
| `onResized` callback | 引数 | `PhysicalSize` | `Dpi.PhysicalSize.t` |
| `onMoved` callback | 引数 | `PhysicalPosition` | `Dpi.PhysicalPosition.t` |
| `scaleFactorChanged.size` | フィールド | `PhysicalSize` | `Dpi.PhysicalSize.t` |
| `Webview.setSize` / `setPosition` | 引数 | 同 Window | `Dpi.Size.t` / `Dpi.Position.t` |
| `Webview.size` / `position` | 戻り値 | 同 Window | `Dpi.PhysicalSize.t` / `Dpi.PhysicalPosition.t` |
| `Webview.dragDropEvent` 内 `position` | フィールド | `PhysicalPosition` | `Dpi.PhysicalPosition.t` |
| `Tray.trayIconEvent` 内 `position` / `rect.position` | フィールド | `PhysicalPosition` | `Dpi.PhysicalPosition.t` |
| `Tray.trayIconEvent` 内 `rect.size` | フィールド | `PhysicalSize` | `Dpi.PhysicalSize.t` |

#### 影響範囲

- `packages/core/src/Window.res` / `.resi` - `monitor`, `scaleFactorChanged`, `setSize`, `setMinSize`, `setMaxSize`, `setPosition`, `setCursorPosition`, `cursorPosition`, `innerSize`, `outerSize`, `innerPosition`, `outerPosition`, `onResized`, `onMoved`, `onScaleChanged`
- `packages/core/src/Webview.res` / `.resi` - `dragDropEvent`, `setSize`, `setPosition`, `position`, `size`, `onDragDropEvent`
- `packages/core/src/Tray.res` / `.resi` - `rect`, `trayIconEvent`, `options.action`
- `packages/core/tests/window_signature.res` / `webview_signature.res` / `tray_signature.res` - 型注釈の更新
- `examples/window-management/`, `examples/streaming-ipc/` 等 - サイズ/位置を扱う箇所の API 利用更新

### 2. App.theme と Window.theme の統合

`App.theme` を削除し、`Window.theme` を再エクスポートする方式：

```rescript
// App.resi / App.res
type theme = Window.theme
```

これにより `App.theme` 利用箇所はコード変更不要（型エイリアスのため）。

#### 影響範囲

- `packages/core/src/App.res` / `.resi`
- `packages/core/tests/app_signature.res`（`#light` リテラルが両方の型で受け入れられるため変更不要の見込み）

### 3. Core._applyDecoder / _exnToJson の隠蔽

`Core.Internal` サブモジュールを新設し、内部用ヘルパを集約する：

```rescript
// Core.res
module Internal = {
  let applyDecoder = (decoder, raw, callback) => ...
  let exnToJson = exn => ...
}
```

```rescript
// Core.resi
/** Internal helpers for intra-package use only. **NOT** part of the
    stable public API; do not depend on its shape outside `@rescript-tauri/core`. */
module Internal: {
  let applyDecoder: (decoder<'a>, JSON.t, result<'a, string> => unit) => unit
  let exnToJson: exn => JSON.t
}
```

#### 利点

- アンダースコアプレフィックスの「公開だが内部」な曖昧さを解消
- 「`Core.Internal` 経由のものは将来変更される」という明示的な契約

#### 影響範囲

- `packages/core/src/Core.res` / `.resi` - 関数を `Internal` モジュールへ移動、`_applyDecoder` / `_exnToJson` のシンボルを削除
- `packages/core/src/Event.res` - `Core._applyDecoder` → `Core.Internal.applyDecoder` 呼び出し更新
- `packages/core/tests/core_command_signature.res` 等 - シグネチャテスト更新（必要なら）
- `Core.Command.invoke` 内の `_exnToJson` 参照を `Core.Internal.exnToJson` に更新

## トレードオフ

- **Dpi 型化の影響範囲**: `setIcon` の `'icon` のように `Image` 実装後にも残る placeholder があるが、本作業は「サイズ/位置」のみに絞る（`'icon` は別タスクで対応）
- **Internal モジュール vs. private**: ReScript の signature ファイルでは true private は実現困難。`Internal` モジュール命名で「触るな」シグナルを送るのが現実解
- **後方互換性**: `App.theme` を `type theme = Window.theme` で置換するため、`App.theme` の値は現状コードと互換（polymorphic variant 構造的同型）

## テスト戦略

- 既存の signature テスト（`tests/*_signature.res`）を新シグネチャに追従して更新
- 既存の runtime テスト（`tests/runtime/*.test.mjs`）はランタイム挙動を変えないため、原則として変更不要
- `examples/*` のビルドが成功すること
