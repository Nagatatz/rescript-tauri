# Steering 022: Tray モジュール

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | PRD §3, functional-design §2.6 |
| ブランチ | `worktree-phase1-tray-module` |

## 背景

Phase 1 の 12 モジュールに `Tray` が含まれる (PRD §8)。upstream `@tauri-apps/api/tray` は `TrayIcon` クラスと `TrayIconEvent` discriminated union からなる。`Menu` / `Image` / `Dpi` の各モジュールに依存。

## 要求

- `TrayIcon.t` を opaque で公開
- `make` (= upstream `static new`)：`promise<t>` を返す async コンストラクタ
- 静的メソッド: `getById`, `removeById`
- インスタンスメソッド: `id`, `setIcon`, `setMenu`, `setTooltip`, `setTitle`, `setVisible`, `setTempDirPath`, `setIconAsTemplate`, `setIconWithAsTemplate`, `setShowMenuOnLeftClick`, `close`（≒ Resource.close）
- options 型 (`TrayIcon.options`)：id / menu / icon / tooltip / title / tempDirPath / iconAsTemplate / showMenuOnLeftClick / action
- `trayIconEvent` variant（クリック・ダブルクリック・enter / move / leave）
- `mouseButton` / `mouseButtonState` polymorphic variant
- `setIcon` / `setMenu` / `setTooltip` / `setTitle` / `setTempDirPath` は `Nullable.t<...>` を受ける（null でクリア）
- 各 `.resi` シンボルに Tauri 公式 URL
- `tests/tray_signature.res` 必須

## Non-goals

- runtime テストは省略（happy-dom で tray は再現困難）
- deprecated `setMenuOnLeftClick` は提供しない（`setShowMenuOnLeftClick` のみ）
- `action` ハンドラの runtime ラッパは Phase 2 に持ち越し（型安全な variant 受け取りは複雑）

## 受け入れ条件

- [x] `Tray.res` / `Tray.resi` 実装
- [x] `tests/tray_signature.res` 作成
- [x] `pnpm --filter @rescript-tauri/core build` 緑
- [x] `pnpm --filter @rescript-tauri/core test` 緑
- [x] 公開シンボルカバレッジ緑
