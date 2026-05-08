# 要求定義: Core.Command (typed Command Layer 2)

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-011 |
| タイトル | core-command |
| 起票日 | 2026-05-08 |
| 影響範囲 | `packages/core/src/Core.{res,resi}` に Layer 2 (typed Command) を追加 + 対応テスト |

## 動機

PRD Story 1-2 + RFC §2.3 + functional-design §2.1.2 で確定した typed `Command` 抽象を実装する。Layer 2 はユーザーが「コマンド名・引数エンコーダ・結果デコーダを 1 か所にまとめた `Command.t<'args, 'result>`」を扱う中核 API。

## スコープ

### 対象

- `Core.res` / `Core.resi`:
  - `type invokeError = DecodeError(string) | RustError(JSON.t)`
  - `module Command: { type t<'args, 'result>; let make; let invoke; let invokeExn }`
- `tests/core_command_signature.res`: 公開シンボル参照
- `tests/runtime/core_command.test.mjs`: 3 ケース (success round-trip / decode failure / rust failure)

### 対象外

- `Core.Channel` (steering 012)
- `Mocks` モジュール本体 (steering 015)
- `@rescript-tauri/schema` (Phase 2)

## 派生決定

| 論点 | 採用 |
|---|---|
| `t<'args, 'result>` の内部表現 | レコード `{name, encodeArgs, decodeResult}` (RFC §2.3 と整合、abstract type で隠蔽) |
| Rust 側 reject の捕捉 | `try/catch` で `Exn.Error(_)` を捕まえ、内部値を `Obj.magic` で `JSON.t` キャスト (Tauri は string/object/array を reject するので JSON.t 表現で十分) |
| `invokeExn` の失敗時挙動 | `JsExn.raise` 相当か `Failure` raise。RFC §6.3 / functional-design §2.1.3 で「Tauri 側の reject を忠実に raise」とあるので元の `exn` を再 raise する |
| `~options=?` の forwarding | `~options?` (ReScript 12 の named-arg passing) |
| Tauri docs URL | `https://v2.tauri.app/develop/calling-rust/` (invoke と共通) |
| worktree 名 | `core-command` |

## 受け入れ条件

- [ ] `Core.Command.make / invoke / invokeExn` がドキュメント付きで実装される
- [ ] `invokeError` variant が公開され、消費側で switch 分岐可能
- [ ] 型レベルテストで全公開シンボル参照
- [ ] vitest 3 ケース (success / DecodeError / RustError) pass
- [ ] doc comment に Tauri 公式 URL を含む
