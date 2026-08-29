# Design: Menu モジュール

## 配置

`packages/core/src/Menu.res` / `Menu.resi` の 1 ファイルに 6 サブモジュール (`MenuItem`, `CheckMenuItem`, `IconMenuItem`, `PredefinedMenuItem`, `Submenu`, `Menu`) と共通型 (`predefinedItem`, `aboutMetadata`) を集約。upstream は 6 ファイルだが、JS の `import { ... } from '@tauri-apps/api/menu'` で全部取れるためファイル分割は不要。

## 主要設計判断

### 1. `itemKind` variant

`Menu` / `Submenu` の `append` / `prepend` / `insert` / `remove` / `removeAt` / `items` / `get` は upstream で union 型を受ける。型安全のため variant `Submenu.itemKind` を導入：

```rescript
type itemKind =
  | Item(MenuItem.t)
  | Check(CheckMenuItem.t)
  | Icon(IconMenuItem.t)
  | Predefined(PredefinedMenuItem.t)
  | Submenu(t)  // recursive
```

JS への変換は `_itemToJs` で `Obj.magic` 経由（同一の opaque type を異なる variant タグで包んでいるだけ）。逆方向 (`_itemFromJs`) は upstream の `kind` プロパティを見て分岐。

### 2. `predefinedItem` variant

upstream は文字列 union (`'Separator' | 'Copy' | ... | { About: AboutMetadata | null }`)。`About` だけ payload を持つので variant にすると一番自然：

```rescript
type predefinedItem =
  | Separator | Copy | Cut | Paste | SelectAll | Undo | Redo
  | Minimize | Maximize | Fullscreen | Hide | HideOthers | ShowAll
  | CloseWindow | Quit | Services | BringAllToFront
  | About(aboutMetadata)
```

`_predefinedToJs` で文字列 / `{About: ...}` に変換。

### 3. polymorphic `'icon`

`IconMenuItem.options` / `Submenu.options` は icon に `Image.t | string | bytes | NativeIcon` を取る。型パラメータ化して `options<'icon>` として公開。`'icon` を `Image.t` に固定するのは Phase 2 で再評価。

### 4. オプショナルフィールド

ReScript 12 の record literal における `field: ?optionalValue` 構文（`{a: ?someOption}` で「Some なら設定、None なら省略」）を使用。

## 実装上の注意

- `static new` は ReScript 予約語と衝突するため上流名が `new` でも `external make` で再公開する。
- `Menu.make` の `~options=?` は型推論が `_jsOptions` 側に流れるため、`option<options>=?` で明示的に注釈する。

## CI 影響

- 公開シンボル 276 / 284 でカバレッジ達成。
- doc-link-lint: `Menu.resi` に Tauri URL 多数。
