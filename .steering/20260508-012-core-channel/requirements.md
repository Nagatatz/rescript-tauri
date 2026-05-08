# 要求定義: Core.Channel

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-012 |
| タイトル | core-channel |
| 起票日 | 2026-05-08 |
| 影響範囲 | `packages/core/src/Core.{res,resi}` に Channel モジュール追加 + テスト |

## 動機

PRD Story 2-3 + RFC §3.4 + functional-design §2.1.2 で確定した `Channel<'message>` を実装する。Channel は Tauri 2.0+ の Rust → フロント単方向ストリーミング機構で、Command で渡して Rust 側から複数メッセージを受け取る用途に使う。

## スコープ

### 対象

- `Core.res` / `Core.resi`: `module Channel: { type t<'message>; let make; let onMessage; let id }`
- `tests/core_channel_signature.res`
- `tests/runtime/core_channel.test.mjs` (3 ケース: make / onMessage callback / id)

### 対象外

- `Channel` を `Command.invoke` の引数として渡す統合シナリオ（examples/streaming-ipc に回す）

## 派生決定

| 論点 | 採用 |
|---|---|
| Channel クラスのバインド方法 | opaque `internal` 型 + `@new` constructor + `@set` onmessage / `@get` id。レコード `t<'message> = {instance, decode}` で decoder を保持 |
| 設計上の `decode` failure 時挙動 | silently drop（Rust 側からの malformed msg は infrastructure の問題、ユーザーコールバックは呼ばない）|
| Tauri docs URL | `https://v2.tauri.app/develop/calling-rust/#channels` |
| worktree 名 | `core-channel` |

## 受け入れ条件

- [ ] `Core.Channel.{make, onMessage, id}` 実装、build warning ゼロ
- [ ] 型レベルテストで全公開シンボル参照
- [ ] vitest 3 ケース pass
- [ ] doc comment に Tauri 公式 URL を含む
