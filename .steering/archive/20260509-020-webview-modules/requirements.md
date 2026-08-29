# Steering 020: Webview / WebviewWindow モジュール

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | PRD §3 Story 3-2, functional-design §2.4 |
| ブランチ | `worktree-phase1-webview-modules` |

## 背景

PRD Phase 1 の 12 モジュールに `Webview` / `WebviewWindow` が含まれる (PRD §8)。upstream の TypeScript 上では `WebviewWindow` が `Webview` と `Window` をマージしたインターフェイス + クラスとして定義されており、ReScript では `%identity` キャストで「同一 JS インスタンスの別型ビュー」として表現する設計が functional-design §2.4 で確定している。

## 要求

### Webview

- `type t` を opaque で公開
- インスタンスメソッド: `label`, `position`, `size`, `setSize`, `setPosition`, `setFocus`, `setAutoResize`, `setBackgroundColor`, `setZoom`, `reparent`, `close`, `hide`, `show`, `listen`, `once`, `emit`, `emitTo`, `onDragDropEvent`
- 静的: `getCurrentWebview`, `getAllWebviews`
- 型定義: `dragDropEvent` (variant)、 `webviewOptions` (record)

### WebviewWindow

- `type t` を opaque で公開
- `external asWindow: t => Window.t = "%identity"` / `external asWebview: t => Webview.t = "%identity"`
- 静的: `getCurrent`, `getAll`, `getByLabel`
- コンストラクタ: `make: (string, ~options: webviewWindowOptions=?) => t`
- 頻用メソッドは `@send` で再エクスポート: `setTitle`, `listen`, `once`, `setBackgroundColor`, `close`

### 横断

- 各 `.resi` に Tauri 公式 URL を含む doc コメント
- `tests/<module>_signature.res` 必須
- ビルド & テスト緑

## Non-goals

- `Webview.setSize` / `setPosition` の `'size` / `'position` polymorphic 受け取りは Phase 1 では維持（Dpi 統合は steering 026 で）
- ドラッグ&ドロップイベントの runtime テストは見送り（happy-dom では再現困難）

## 受け入れ条件

- [x] Webview / WebviewWindow の `.res` / `.resi` 実装
- [x] `_signature.res` 作成
- [x] `pnpm --filter @rescript-tauri/core build` 緑
- [x] `pnpm --filter @rescript-tauri/core test` 緑
- [x] 公開シンボルカバレッジ緑
