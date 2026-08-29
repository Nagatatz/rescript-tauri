# Design: Tray モジュール

## 配置

`packages/core/src/Tray.res` / `Tray.resi` 単一ファイル。

## 主要設計判断

### 1. `trayIconEvent` variant

upstream の `TrayIconEvent` は discriminated union (`{type: 'Click', button, buttonState, ...} | {type: 'DoubleClick', button, ...} | {type: 'Enter', ...} | ...`)。これを variant に変換するラッパを `make` の `action` 受け取り時に挟む。`_eventFromJs` で `event.type` を見て分岐し、`Click` / `DoubleClick` / `Enter` / `Move` / `Leave` のいずれかを構築。

### 2. polymorphic 'icon / 'menu

upstream の icon は `Image.t | string | bytes`、menu は `Menu | Submenu`。Phase 1 では polymorphic で受け、ユーザーは `Image.t`, `string`, `Menu.Menu.t`, `Menu.Submenu.t` のいずれも自然に渡せる。

### 3. polymorphic 'pos / 'size

`trayIconEvent` 内の `position` / `rect.position` / `rect.size` は `Dpi.PhysicalPosition.t` / `Dpi.PhysicalSize.t` の wire 形（{x, y} / {width, height}）。Phase 2 で完全 Dpi 統合する際に厳格化。

### 4. Nullable.t<...> での null 受け

`setIcon` / `setMenu` / `setTooltip` / `setTitle` / `setTempDirPath` は upstream で `null` 渡しがクリア動作。`Nullable.t<...>` で公開し、`Nullable.null` を渡すとクリア、`Nullable.make(value)` で設定。

## 実装上の注意

- `static new` は ReScript 予約語と衝突するため上流名 `new` でも `external _make` を経由してラッパ `make` を提供。
- `action` の値変換だけは ReScript 側ロジックが必要 (event variant 化)。それ以外は薄いバインディング。

## CI 影響

- 公開シンボル 290 / 300。doc-link-lint OK。
