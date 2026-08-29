# 要求定義: Window モジュール (必須 + 主要メソッド)

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-014 |
| タイトル | window-module |
| 起票日 | 2026-05-08 |
| 影響範囲 | `packages/core/src/Window.{res,resi}` 新規 + テスト |

## 動機

PRD Story 3-1 + RFC §4.1 + functional-design §2.3 で確定した `Window` クラスバインディング。Tauri 2.x の `@tauri-apps/api/window` から exposed されている `Window` クラスを ReScript の opaque type + `@send`/`@scope`/`@new` で表現する。

## スコープ

PRD Story 3-1 の必須メソッド 11 個 + Phase 1 で実用上必須となる主要メソッド (合計約 20 個) を実装。残り（追加 30+ メソッド）は別ステアリングで段階追加。

### 対象 (in-scope)

新規ファイル `packages/core/src/Window.{res,resi}`:

- `type t` (opaque)
- `type options` (Record): `{url?, title?, width?, height?, x?, y?, resizable?, fullscreen?, focus?, transparent?, decorations?, alwaysOnTop?, skipTaskbar?, ...}` — 必須 subset
- 静的メソッド: `getCurrent`, `getAll`, `getByLabel`
- `@new` constructor: `make(label, ~options=?)`
- インスタンスメソッド (PRD 必須 11): `label`, `setTitle`, `title`, `close`, `destroy`, `show`, `hide`, `minimize`, `maximize`, `unmaximize`, `isMaximized`
- 主要追加 (~10): `isMinimized`, `isVisible`, `isFocused`, `setFocus`, `setSize`, `setPosition`, `setFullscreen`, `setResizable`, `setAlwaysOnTop`, `center`

### 対象外 (別ステアリング)

- 残りのメソッド: `setIcon`, `setSkipTaskbar`, `setCursorGrab`, `setCursorVisible`, `setCursorIcon`, `setCursorPosition`, `setIgnoreCursorEvents`, `startDragging`, `setProgressBar`, モニター関連 (`currentMonitor`, `availableMonitors` 等), カーソル位置, スケールファクタ, テーマ, ドラッグ系, ウィンドウステートイベントの emit 等
- `Webview` / `WebviewWindow` モジュール (PRD Story 3-2、別ステアリング)
- `setSize` / `setPosition` の引数で必要となる `Dpi.LogicalSize` 等の構造体型 — Dpi モジュールが未実装のため、本ステアリングでは引数を `'size` / `'position` (polymorphic) で受ける

## 派生決定

| 論点 | 採用 |
|---|---|
| 段階的実装 | 必須 + 主要 (~20 個) を本ステアリングで、残りは別ステアリング |
| `setSize` / `setPosition` の型 | Dpi 未実装のため `'size` / `'position` polymorphic。Dpi 実装時に `Dpi.size` / `Dpi.position` に置換 |
| `@module` ターゲット | `@tauri-apps/api/window` |
| `getByLabel` の戻り値 | `promise<Nullable.t<t>>` (PRD 受け入れ条件) |
| `make(label, ~options=?)` | `@module @new external make: (string, ~options: options=?) => t = "Window"` |
| Tauri docs URL | `https://v2.tauri.app/reference/javascript/api/namespacewindow/` |
| worktree 名 | `window-module` |

## 受け入れ条件

- [ ] PRD Story 3-1 必須 11 メソッド + 主要 ~10 メソッドが実装され、build warning ゼロ
- [ ] 静的 3 メソッド (`getCurrent`, `getAll`, `getByLabel`) 実装
- [ ] 型レベルテストで全公開シンボル参照
- [ ] vitest 4-5 ケース pass（Window class の mock を install して static + instance method の動作確認）
- [ ] doc comment に Tauri 公式 URL を含む
- [ ] doc comment にリソース解放（`close` / `destroy`）がユーザー責務である旨を明示（PRD Story 3-2 受け入れ条件）
