# 要件定義: @rescript-tauri/core リファクタリング (steering 027)

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-027 |
| タイトル | core-refactoring (Phase 1 完了前のクリーンアップ) |
| 対象パッケージ | `@rescript-tauri/core` |
| 関連 | [docs/functional-design.md](../../docs/functional-design.md), [docs/architecture.md](../../docs/architecture.md) |
| 前提 | pre-1.0 のため API 破壊変更を許容（互換 shim 不要） |

## 1. 背景

Phase 1 の `@rescript-tauri/core` は production-ready だが、Phase 2 で plugin パッケージ群（plugin-fs / plugin-dialog / schema 等）を追加する前に解消したい設計負債が 4 点ある。これらは個別には小さいが、同じ層に何度も plugin を被せる前段で統一しておくとスケールする。

## 2. 解決したい課題

### 2.1 エラーハンドリングの不統一 (P0)

| API | デコード失敗時の挙動 |
|---|---|
| `Core.Command.invoke` | `Error(DecodeError(msg))` を返す |
| `Core.Channel.onMessage` | サイレントドロップ |
| `Event.listen` / `Event.once` | サイレントドロップ |

silent-drop は `.resi` で「意図的」と書かれているが、Command の `result` パターンと不整合。Phase 2 で plugin がこの層を再利用すると、エラー方針の差が plugin 全体に伝播する。

### 2.2 Type wrapper の重複 (P1)

`Command.t<'args, 'result>`, `Event.t<'payload>`, `Channel.t<'message>` がすべて `JSON.t => result<_, string>` 型のデコーダを持つが、共通エイリアスがない。Phase 2 の `Schema.Command.fromSchemas` ヘルパが target にする型としても基盤が必要。

### 2.3 `Obj.magic` 2 箇所 (P2)

| 箇所 | 内容 | リスク |
|---|---|---|
| `packages/core/src/Event.res:56-64` `_targetToJs` | polymorphic variant → JS object literal | Tauri JS 側の API 変更で silent break |
| `packages/core/src/Core.res:34` `Command.invoke` の RustError | JS exn → JSON.t の型キャスト | 例外の中身が unstructured |

### 2.4 ドキュメント drift (P3)

- `docs/functional-design.md` line 216 周辺・523 周辺: 「Decode 失敗は console.error で報告」と記述 → 実装はサイレントドロップ
- `docs/repository-structure.md` §3: `examples/window-management`, `examples/ipc-typed`, `examples/streaming-ipc` を未来形と現在形の中間で記述（Phase 2+ 計画分、未作成）
- `Event.res` / `Core.res` の private helper (`_wrap`, `_targetToJs`) に doc コメントなし

## 3. 要件

### 必須 (Must)

- **R1**: `Event.listen` / `Event.once` / `Channel.onMessage` の callback シグネチャを `result<_, string> => unit` に変更し、デコード失敗時はサイレントドロップせず `Error(msg)` を callback に渡す。
- **R2**: `Core.res` トップレベルに `type decoder<'value> = JSON.t => result<'value, string>` を追加し、`.resi` で公開する。`Command.t.decodeResult`, `Channel.t.decode`, `Event.t.decode` の型をこのエイリアスに統一する。
- **R3**: `Event._targetToJs` の `Obj.magic` を typed record `targetJs = {kind, label?}` に置換する。生成 JS が等価であること。
- **R4**: `Core.Command.invoke` の RustError キャストを `_exnToJson` ヘルパで型安全化する。`Exn.asJsExn` ベースで `{name, message}` を JSON 化。
- **R5**: 既存テストを新シグネチャに更新し、`Error` propagation を assertion する形へ書き換える。silent-drop assertion は「callback receives Error on decode failure」に変更。
- **R6**: `docs/functional-design.md` の console.error 記述を新ポリシーに合わせて更新。`docs/repository-structure.md` の Phase 2+ examples を「(planned, 未作成)」と明示。`docs/architecture.md` に Decode failure policy セクションを追加。
- **R7**: 既存の `examples/hello-world` で `Event.listen` / `Channel.onMessage` の call site があれば新シグネチャに追従する。

### 推奨 (Should)

- **S1**: `Core.res` に private helper `_applyDecoder` を追加し、`Channel.onMessage` と `Event._wrap` から共通利用する。
- **S2**: private helper (`_wrap`, `_targetToJs`, `_applyDecoder`, `_exnToJson`) に doc コメントを付与する。
- **S3**: `Event.once` でデコード失敗時の auto-unsubscribe 挙動を確認するテストを追加する。

### 想定外 (Out of scope)

- `Window` / `Mocks` モジュールの変更（今回スコープ外）
- 新規 `Decoder.res` モジュールの作成（不採用 — Core 内に置く）
- `~onDecodeError` 形のオプショナル callback パラメータ（不採用 — pre-1.0 で破壊変更を選択）

## 4. 受け入れ基準

- [ ] `pnpm --filter @rescript-tauri/core build` 成功
- [ ] `pnpm --filter @rescript-tauri/core test` 全件 pass
- [ ] `pnpm --filter hello-world build` 成功（既存 examples が壊れていない）
- [ ] `Obj.magic` が `Event.res` / `Core.res` から消えている（`grep -r Obj.magic packages/core/src/` で 0 件）
- [ ] `docs/functional-design.md` の console.error 記述が新ポリシーに更新されている
- [ ] `Core.decoder<_>` が `.resi` で公開されている
- [ ] CI ワークフロー（build-core / tests-core-runtime / tests-core-types / examples-build）が緑

## 5. 影響範囲・リスク

| 区分 | 影響 |
|---|---|
| 公開 API | **破壊変更あり** — `Event.listen` / `Event.once` / `Channel.onMessage` の callback シグネチャ変更、`RustError` ペイロード形変化 |
| ビルド | 新エイリアス導入だが alias の structural equality で signature テストは通る見込み |
| Phase 2 plugin | 統一方針が確立される（plugin が同じ pattern で書ける） |
| サードパーティ利用 | pre-1.0 のため許容 |

## 6. 参照

- `docs/functional-design.md` §1.2 (IPC 階層)
- `.claude/rules/code-comments.md`
- `.claude/rules/testing.md`
- `.claude/rules/git-conventions.md`
