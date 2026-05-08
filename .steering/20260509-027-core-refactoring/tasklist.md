# タスクリスト: @rescript-tauri/core リファクタリング (steering 027)

> 各タスクは着手時に `[x]` に更新。実装中に新しいタスクが判明したら追記する。

## Phase 0: ステアリング作成 (main で作業)

- [x] `.steering/20260509-027-core-refactoring/` ディレクトリ作成
- [x] `requirements.md` 作成
- [x] `design.md` 作成
- [x] `tasklist.md` 作成（本ファイル）
- [x] ステアリング 3 ファイルを 1 コミットでコミット (`📝 Add steering for 20260509-027 (core-refactoring)`)
- [x] `EnterWorktree` で `core-refactoring` という名前の worktree を作成し、以降の作業を隔離

## Phase 1: P2 — Obj.magic 除去 (worktree 内)

### 1a. Event._targetToJs

- [x] `Event.res` に `type targetJs = {kind: string, label?: string}` を追加
- [x] `_targetToJs` を typed record 版に書き換え
- [x] `external _emitTo` のシグネチャを `(targetJs, string, 'payload) => promise<unit>` に変更
- [x] `pnpm --filter @rescript-tauri/core build` 成功確認
- [x] `pnpm --filter @rescript-tauri/core test` 全件 pass 確認
- [x] `Event.res.mjs` の生成 JS が emitTo の引数構造として等価であることを `git diff` で確認（差分なし）

### 1b. Core.Command.invoke の Obj.magic

- [x] `Core.res` に private helper `_exnToJson: exn => JSON.t` を追加
- [x] `Command.invoke` の `Error(RustError(exn->Obj.magic))` を `Error(RustError(_exnToJson(exn)))` に置換
- [x] `core_command.test.mjs` の RustError 関連テストを確認（既存テストは TAG のみ assertion のため新フォーマットでも pass、変更不要）
- [x] ビルド・テスト全件 pass 確認

### 1 完了

- [x] `grep -r Obj.magic packages/core/src/Core.res packages/core/src/Event.res` が 0 件であることを確認（Webview.res の Obj.magic はステアリング 020 のスコープで本作業の対象外）
- [x] コミット: `♻️ Replace Obj.magic with typed records in Event/Core`

## Phase 2: P1 — Decoder エイリアスと _applyDecoder ヘルパ

- [x] `Core.res` トップレベルに `type decoder<'value> = JSON.t => result<'value, string>` を追加
- [x] `Core.res` に `_applyDecoder` ヘルパを追加（callback 引数は `result<'a, string> => unit` 形）
- [x] `Core.resi` で `decoder<_>` を公開（doc コメント付き）
- [x] `Core.resi` で `_applyDecoder` を internal API として公開（パッケージ内 Event から参照するため）
- [x] `Command.t.decodeResult` の型を `decoder<'result>` に変更
- [x] `Channel.t.decode` の型を `decoder<'message>` に変更
- [x] `Channel.onMessage` を `_applyDecoder` 経由に書き換え（silent drop は維持）
- [x] `Event.res` で `Event.t.decode` の型を `Core.decoder<'payload>` に変更
- [x] `Event._wrap` を `Core._applyDecoder` 経由に書き換え（silent drop は維持）
- [x] `Event.resi` の `make` シグネチャも `Core.decoder<_>` に統一
- [x] signature テスト（structural alias で通る、変更不要）
- [x] ビルド・テスト全件 pass 確認
- [x] コミット: `♻️ Extract decoder type alias and applyDecoder helper`

## Phase 3: P0 — callback で result を渡す（破壊変更）

- [x] `Channel.onMessage` 実装を `_applyDecoder` への直接 forward に簡素化（silent drop 削除）
- [x] `Channel.onMessage` の `.resi` callback 型を `result<'message, string> => unit` に変更
- [x] `Event._wrap` を `Ok(event)` / `Error(msg)` を渡す形に書き換え
- [x] `Event.listen` / `Event.once` の `.resi` callback 型を `result<event<'payload>, string> => unit` に変更
- [x] `.resi` の docstring を新ポリシーに合わせて更新（migration guide の例コード付き）
- [x] signature テスト (`event_signature.res`, `core_channel_signature.res`) を新シグネチャに更新
- [x] ビルド成功確認
- [x] コミット: `✨ Surface decode errors as result in listen/once/onMessage` (BREAKING CHANGE)

## Phase 4: テスト更新

### event.test.mjs

- [x] "listen captures a callback" → "listen forwards a successfully decoded event as Ok" に書き換え
- [x] "listen drops messages whose decode fails" → "listen surfaces decode failures as Error(msg)" に書き換え
- [x] 新規テスト: `Event.once` でデコード失敗時に Error が delivered されること、auto-unsubscribe 経路で例外を throw しないこと（`__TAURI_EVENT_PLUGIN_INTERNALS__` を mock）

### core_channel.test.mjs

- [x] "onMessage forwards decoded messages" → "onMessage forwards decoded messages as Ok(msg)" に書き換え
- [x] "decode failures are silently dropped" → "onMessage surfaces decode failures as Error(msg)" に書き換え

### Phase 4 完了

- [x] `pnpm --filter @rescript-tauri/core test` 全件 pass（26 tests）
- [x] コミット: `✅ Update tests for result-based decode error propagation`

## Phase 5: P3 — ドキュメント整備

- [x] `docs/functional-design.md` line 216 周辺の console.error 記述を新ポリシーに更新
- [x] `docs/functional-design.md` line 523 周辺のエラー設計表を新ポリシーに更新
- [x] `docs/repository-structure.md` §3 の Phase 2+ examples を「(Phase 2+ 計画、未作成)」と明示
- [x] `docs/architecture.md` 5.1 節の `RustError` 説明を `_exnToJson` の正規化形式（`{name, message}`）で更新
- [x] `docs/architecture.md` に「5.1.1 デコード失敗ポリシー（統一）」セクションを追加
- [x] `Core.res` / `Event.res` の private helper (`_wrap`, `_targetToJs`, `_applyDecoder`, `_exnToJson`) に doc コメント追加
- [x] `examples/hello-world/` に `Event.listen` / `Channel.onMessage` の call site なし（追従不要）
- [x] `pnpm --filter hello-world build` 成功確認
- [x] コミット: `📝 Update docs to reflect unified decode failure policy`

## Phase 6: 検証 + マージ

- [x] `pnpm --filter @rescript-tauri/core build` 成功
- [x] `pnpm --filter @rescript-tauri/core test` 全件 pass（26 tests）
- [x] `pnpm --filter hello-world build` 成功
- [x] `grep -r Obj.magic packages/core/src/Core.res packages/core/src/Event.res` が 0 件
- [x] 自己検証: 型チェック・ビルドで警告 0 件
- [x] tasklist.md の全タスクを `[x]` に更新（マージタスク自体含む）
- [x] tasklist 更新を最終コミットとして含める
- [x] AskUserQuestion で main へのマージ可否を確認
- [x] 承認後、worktree マージ・クリーンアップ手順を実行
  - [x] CWD をメインリポジトリに変更
  - [x] `git merge worktree-core-refactoring --no-ff -m "Merge branch 'worktree-core-refactoring' (steering 027: core refactoring)"`
  - [x] `git worktree remove .claude/worktrees/core-refactoring`
  - [x] `git branch -d worktree-core-refactoring`
- [x] クリーンアップ検証
  - [x] `git worktree list` で main / phase1-webview-modules（並行作業）のみ表示
  - [x] `git branch --list 'worktree-*'` から `worktree-core-refactoring` が消えている
  - [x] `.claude/worktrees/core-refactoring` が存在しない

## 実装中に判明した追加事項

- `_exnToJson` のフォールバック: `Exn.toString` は `@rescript/core` v1.6 に存在しなかったため、非 `Error` 例外には固定文字列 `"(non-Error exception)"` を使用
- Step 2 で `_applyDecoder` を Event から呼び出すため、Core.resi に internal API として露出する必要があった
- `Event.once` のテストでは Tauri 内部の `__TAURI_EVENT_PLUGIN_INTERNALS__.unregisterListener` が呼ばれるため、auto-unsubscribe 経路の mock を追加した
