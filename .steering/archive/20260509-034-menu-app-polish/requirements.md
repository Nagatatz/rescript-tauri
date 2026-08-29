# Menu/App 仕上げポリッシュ — 要件

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-034-menu-app-polish |
| 開始日 | 2026-05-09 |
| 状態 | 進行中 |
| 関連 | `.steering/20260509-032-pre-phase2-api-cleanup/` |

## 背景

steering 032 のフォローアップ。当初トリアージ調査（2026-05-09）で抽出した残候補のうち、実装を再確認した上で **本当にリファクタする価値がある** ものだけを実施する。

## 対象範囲

### 含む

1. **Menu.popup / Submenu.popup の Dpi 化**: steering 032 で見落とされた `~at: 'pos=?` placeholder を `~at: Dpi.Position.t=?` に置換。
2. **App.setTheme パラメータ名の改善**: `~theme: Nullable.t<theme>=?` の `~theme` が型名 `theme` をシャドウしているため、`~preferred` に rename。

### 含まない（スコープ判断の根拠）

| 当初候補 | 判断 | 理由 |
|---|---|---|
| #4 Menu の variant codec 重複削減（`_predefinedToJs` / `_itemToJs` / `_itemFromJs`） | **見送り** | 17 ケースの `Obj.magic("Tag")` テーブルは upstream JS enum へのマッピングとして自然形。polymorphic variant + 内部マッピングへの書き換えは API 表面（`Builtin(#Tag)` のような 2 段ネスト）を悪化させる |
| #5 Webview / Tray の event codec 共通化 | **見送り** | 各 codec は 10〜20 行程度。共通化すると discriminator 抽出ロジックは抜けるが variant 構築は依然個別であり、抽象化のコスト > 削減効果 |
| #6 Image.new_ ラッパーの簡略化 | **見送り** | `external new_: (Uint8Array.t, float, float)` を `let new_ = (~rgba, ~width, ~height)` でラップする実装は **positional → labeled 引数変換** を意図した正当なパターン。冗長ではない |
| #7 Path.BaseDirectory の polymorphic variant 化 | **見送り** | `private int` で upstream JS enum 値（1〜23）を直接表現する現行が最簡潔。polymorphic variant 化は `@as(N)` 等で動的に整数値を持たせる必要があり可読性が下がる。plugin-fs から既に `BaseDirectory.t` が消費されており、API 変更の波及範囲も大きい |

## 受け入れ基準

- [ ] `pnpm --recursive build` が成功する
- [ ] `pnpm --recursive test` が成功する
- [ ] `Menu.resi` / `Submenu` 内の `popup` シグネチャに `'pos` placeholder が残らず、`Dpi.Position.t` を使用している
- [ ] `App.setTheme` の引数名が `~preferred` に変更され、対応するテストが追従している
- [ ] examples / docs が新シグネチャでビルドできる

## 制約

- 後方互換性無視（pre-1.0）
- doc コメントの Tauri 公式 URL は維持
