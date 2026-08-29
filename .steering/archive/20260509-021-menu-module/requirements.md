# Steering 021: Menu モジュール

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | PRD §3, functional-design §2.6 |
| ブランチ | `worktree-phase1-menu-module` |

## 背景

Phase 1 の 12 モジュールに `Menu` が含まれる (PRD §8)。upstream `@tauri-apps/api/menu` は 6 ファイル (base / menu / menuItem / submenu / checkMenuItem / iconMenuItem / predefinedMenuItem) に分かれているが、本バインディングではユーザーが `import { ... } from '@tauri-apps/api/menu'` で全部取れる JS インターフェイスに合わせ、**1 ファイル `Menu.res / Menu.resi` に内部モジュールとして集約**する。

## 要求

### 提供するサブモジュール

- `MenuItem`: text のみのメニュー項目
- `CheckMenuItem`: チェックボックス付き
- `IconMenuItem`: アイコン付き (`Image.t` または NativeIcon variant)
- `PredefinedMenuItem`: OS/Tauri 提供の組み込み項目（Separator, Copy, Cut, Paste, ... の variant）
- `Submenu`: ネスト可能なサブメニュー
- `Menu`: トップレベルメニュー

### 共通要件

- 各サブモジュールに opaque type `t` を提供
- `make` (= upstream `static new`) は `promise<t>` を返す async コンストラクタ
- `text` / `setText` / `id` / `isEnabled` / `setEnabled` / `setAccelerator` などインスタンスメソッドを提供
- `Menu` / `Submenu` の `append` / `prepend` / `insert` / `remove` / `removeAt` / `items` / `get` / `popup` / `setAsAppMenu` / `setAsWindowMenu` を提供
- `append` 系は polymorphic に「すでに作成された各種 menu item を受け付ける」シグネチャ。型安全のため variant `menuItemKind` を導入：
  ```rescript
  type menuItemKind =
    | Item(MenuItem.t)
    | Check(CheckMenuItem.t)
    | Icon(IconMenuItem.t)
    | Predefined(PredefinedMenuItem.t)
    | Submenu(Submenu.t)
  ```
- `predefinedMenuItem` の `item` フィールド variant を ReScript 化:
  ```rescript
  type predefinedItem =
    | Separator | Copy | Cut | Paste | SelectAll | Undo | Redo
    | Minimize | Maximize | Fullscreen | Hide | HideOthers | ShowAll
    | CloseWindow | Quit | Services | BringAllToFront
    | About(aboutMetadata)
  ```

### Non-goals

- `NativeIcon` の **全 100+ 値** の polymorphic variant 化は本 steering では一部だけ提供し、文字列 escape hatch で残りをカバー（`@as` で escape）。
- `popup` の `at` に `PhysicalPosition | LogicalPosition | Position` を受けるので polymorphic 引数で受ける（Dpi 統合は steering 023 で）。
- `Image` 依存の `IconMenuItem` は `Image.t | string | bytes` のいずれか。Phase 1 では polymorphic で受ける。

### 横断

- 各 `.resi` シンボルに Tauri 公式 URL を含む doc コメント
- `tests/menu_signature.res` 必須
- ビルド & テスト緑

## 受け入れ条件

- [x] `Menu.res` / `Menu.resi` 実装
- [x] `tests/menu_signature.res` 作成
- [x] `pnpm --filter @rescript-tauri/core build` 緑
- [x] `pnpm --filter @rescript-tauri/core test` 緑
- [x] 公開シンボルカバレッジ緑
