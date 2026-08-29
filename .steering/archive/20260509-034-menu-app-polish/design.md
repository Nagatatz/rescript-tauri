# Menu/App 仕上げポリッシュ — 設計

## A. Menu.popup / Submenu.popup の Dpi 化

### 現状

```rescript
// Menu.res
@send external popup: (t, ~at: 'pos=?, ~window: Window.t=?) => promise<unit> = "popup"
```

`'pos` は Phase 1 の placeholder。`Dpi` モジュール完成後に置き換える予定だったもの（steering 032 で対応済みと思っていたが、Menu の `popup` は対象外だった）。

### 変更後

```rescript
@send external popup: (t, ~at: Dpi.Position.t=?, ~window: Window.t=?) => promise<unit> = "popup"
```

### 影響範囲

- `packages/core/src/Menu.res` — `Submenu` 内 `popup`、`Menu` 内 `popup`
- `packages/core/src/Menu.resi` — 対応シグネチャ更新（doc コメントから "polymorphic until full Dpi integration" を削除）
- `packages/core/tests/menu_signature.res` — 該当箇所があれば追従（要確認）

## B. App.setTheme パラメータ名の改善

### 現状

```rescript
// App.res
external setTheme: (~theme: Nullable.t<theme>=?) => promise<unit> = "setTheme"
```

ラベル付き引数 `~theme` が型名 `theme` をシャドウしているため、ユーザコードが `App.setTheme(~theme=Nullable.Value(#light))` となり「`theme` はラベル名なのか型名なのか」が読みづらい。

### 変更後

```rescript
external setTheme: (~preferred: Nullable.t<theme>=?) => promise<unit> = "setTheme"
```

`@module` external の場合、ラベル付き引数の名前は JS 側に影響を与えない（位置で渡される）ため、リネームは安全。

### 比較対象

`Window.setTheme(t, Nullable.t<theme>)` は引数 2 つで非ラベル付きなので影響なし。

### 影響範囲

- `packages/core/src/App.res`
- `packages/core/src/App.resi`
- `packages/core/tests/app_signature.res` — ラベル名が変わるためテスト追従

## トレードオフ

- **A**: 影響軽微。`'pos` を使っていた呼び出しはそもそも例題に存在しない（grep で確認済み）
- **B**: pre-1.0 のため API 破壊変更を許容。利便性向上が目的

## テスト戦略

- 既存の signature テスト（`tests/menu_signature.res`、`tests/app_signature.res`）を新シグネチャに追従して更新
- Runtime テストはランタイム挙動を変えないため変更不要
- `examples/` の影響箇所を `grep "popup\|setTheme"` で確認
