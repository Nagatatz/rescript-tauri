# Steering 019: ユーティリティモジュール群 (Dpi / Path / App / Image)

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | PRD §3, functional-design §2.5, §2.6 |
| ブランチ | `worktree-phase1-utility-modules` |

## 背景

Phase 1 リリースには `Dpi` / `Path` / `App` / `Image` の 4 モジュールが必須 (PRD §8 Phase 1)。いずれもクラスを持たないユーティリティ系か、薄い opaque クラスのバインディングに過ぎず、個別 steering に分割するメリットが小さい。`Dpi` が `Window` から polymorphic で参照されているため、`Dpi` 完成後に `Window` の型を厳格化する後続作業 (steering 026 で扱う) も意識する。

## 要求

### 4.1 Dpi モジュール

upstream `dpi.d.ts` のクラス `LogicalSize` / `PhysicalSize` / `LogicalPosition` / `PhysicalPosition` / `Size` / `Position` をバインドする。Tauri の IPC では `LogicalSize` などの class-like なシリアライザを必要とするので **opaque type + クラスコンストラクタ** で表現する。`width / height / x / y / type` などの読み出し用 getter も提供。

### 4.2 Path モジュール

upstream `path.d.ts` の **31 関数** + `BaseDirectory` enum をバインド。`BaseDirectory` は polymorphic variant ではなく abstract type + 値定数に近い形で提供（数値 enum を ReScript 側で見せたいとき有用）。シンプルさ優先で `int` の `module BaseDirectory: { type t = private int; let audio: t; ... }` 形式とする。

### 4.3 App モジュール

upstream `app.d.ts` のうち、安定した API (`getName`, `getVersion`, `getTauriVersion`, `getIdentifier`, `show`, `hide`, `defaultWindowIcon`, `setTheme`, `setDockVisibility`, `supportsMultipleWindows`) をバインド。`fetchDataStoreIdentifiers` / `removeDataStore` / `getBundleType` / `onBackButtonPress` は upstream で実験的扱い (Webview-only / mobile-only 等) なので Phase 1 では見送り、Phase 2 で再評価する旨を Doc コメントに残す。

### 4.4 Image モジュール

`Image` クラスを opaque + `@send` で薄くバインド。`new` (RGBA + width + height)、`fromBytes`, `fromPath`, `rgba`, `size` を提供。`ImageSize` は record 型として exposed。

### 4.5 横断的要件

- 各モジュールに `.resi` 必須、各公開シンボルに Tauri 公式 URL を含む doc コメント
- `tests/<module>_signature.res` で型レベル網羅
- 既存の Phase 1 シグネチャ (Window 等) への破壊的変更なし
- ビルド & テスト緑

## Non-goals

- `Window.setSize` / `setPosition` / `cursorPosition` の polymorphic 引数→`Dpi.Size.t` 等への置換は本 steering では行わない（後続 steering 026 で `Tauri.res` 統合と同タイミング、または別途）。
- `setIcon` の `Image.t` 受け取り厳格化も同様（後続）。
- App の各種 plugin 系 (DataStore, BackButton 等) は Phase 2 へ。

## 受け入れ条件

- [x] 4 モジュールの `.res` / `.resi` を実装
- [x] 各 `_signature.res` を作成
- [x] `pnpm --filter @rescript-tauri/core build` 緑
- [x] `pnpm --filter @rescript-tauri/core test` 緑
- [x] CI 公開シンボルカバレッジ緑
- [x] 既存テストは引き続き緑
