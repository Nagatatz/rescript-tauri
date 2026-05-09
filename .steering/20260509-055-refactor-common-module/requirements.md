# Steering 055: Common モジュール抽出によるリファクタリング

## 1. 背景

`packages/core/src/` の Window / Webview / Event / WebviewWindow にまたがって以下の重複・依存の歪みが残っている。

### 1.1 `dragDropEvent` 型と decoder の完全重複

`Window.res(i)` と `Webview.res(i)` に同じ 4 variant 型 (`Enter` / `Over` / `Drop` / `Leave`) と、`Obj.magic` を使った同一の payload decoder ロジックが存在する。

`Window.res:283-284` と `Window.resi:805-808` には以下のコメントが残っている:

```
// Same payload shape as Webview.dragDropEvent. Defined locally to avoid
// circular module dependency (Webview already imports Window.color).
```

### 1.2 `unlisten` 型の三重定義

`Event.unlisten` / `Window.unlisten` / `Webview.unlisten` がいずれも `unit => unit` として独立に定義されている。`Window.resi:13-17` には:

```
type unlisten = unit => unit
```

の docstring に「Identical in shape to `Event.unlisten`」と明記されている。

### 1.3 `color` の所属が `Window` に偏っている

`type color = {r, g, b, a}` は `Window.res(i)` のみに定義され、`Webview.options.backgroundColor` / `Webview.setBackgroundColor` / `WebviewWindow.options.backgroundColor` / `WebviewWindow.setBackgroundColor` がすべて `Window.color` を参照している。

これにより `Webview` → `Window` という片方向依存が生まれ、結果として 1.1 の workaround コメントの根拠 (循環依存回避) になっている。

## 2. 目的

横断的な型・ヘルパを集約した `Common` モジュールを新設し、上記の重複と依存の歪みを解消する。コードベース全体の整合性を高め、今後 Tauri 上流で類似の概念が追加された際の置き場所を明確化する。

## 3. 要求事項

### 3.1 機能要求

| ID | 要求 |
|---|---|
| FR-1 | `packages/core/src/Common.res(i)` を新設する |
| FR-2 | `unlisten` / `color` / `dragDropEvent` の 3 型を `Common` に集約し、Window / Webview / Event から重複定義を削除する |
| FR-3 | drag-drop payload を decode する内部ヘルパも `Common` に統合し、`Window.onDragDropEvent` / `Webview.onDragDropEvent` から共通利用する |
| FR-4 | `Tauri.res(i)` に `module Common = Common` を追加して umbrella 経由で参照可能にする |
| FR-5 | 既存の signature テスト・runtime テストを破壊しない範囲で更新する (型名のリネームを伴う) |

### 3.2 非機能要求

| ID | 要求 |
|---|---|
| NFR-1 | runtime 動作 (生成 JS) は変更前後で等価であること (compile 出力の差分が型シグネチャ・モジュールエイリアスのみ) |
| NFR-2 | `pnpm --recursive build` および `pnpm --recursive test` がすべて成功すること |
| NFR-3 | core パッケージの coverage threshold を維持する |
| NFR-4 | `Common` モジュールの全 public シンボルにドキュメントコメント + 関連する Tauri 公式ドキュメント URL を付与する |

### 3.3 互換性

リリース前 (pre-1.0) のため後方互換性は不要。`Window.color` / `Webview.dragDropEvent` / `Window.unlisten` 等を直接参照していたコードは `Common.X` にリネームして対応する。

ただし以下は確認の上で対応する:
- `examples/` 配下: 直接参照していないため影響なし (確認済み)
- `packages/plugin-*`: いずれも `Window.color` / `dragDropEvent` を参照していない (確認済み)

## 4. 受け入れ基準

- [ ] `Common.res(i)` が作成され、`unlisten` / `color` / `dragDropEvent` の 3 型と drag-drop decoder が定義されている
- [ ] `Window` / `Webview` / `WebviewWindow` から重複する型定義が削除されている
- [ ] `Tauri.res(i)` で `Common` が re-export されている
- [ ] `pnpm --recursive build` が成功する
- [ ] `pnpm --recursive test` が成功する (core / plugin-* / schema 全パッケージ)
- [ ] core の coverage threshold が現状維持されている
- [ ] `git grep "Same payload shape as"` で workaround コメントが残っていない
- [ ] `Common` モジュールに doc comment + Tauri 公式 URL が付与されている

## 5. スコープ外

- `Path.BaseDirectory` の polymorphic variant 化 (得が少ないため見送り)
- `Dpi.Size` / `Dpi.Position` の functor 化 (overengineering のため見送り)
- `Tray._eventFromJs` の Common 統合 (event shape が異なるため統合せず Tray 内に留置)
- 新しい Tauri API のサポート追加
- ドキュメント側 (`sphinx-docs/`, `docs/`) の大規模書き換え (リネーム箇所のみ追従更新)
