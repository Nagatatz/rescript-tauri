# タスクリスト: @rescript-tauri/core リファクタリング (steering 027)

> 各タスクは着手時に `[x]` に更新。実装中に新しいタスクが判明したら追記する。

## Phase 0: ステアリング作成 (main で作業)

- [x] `.steering/20260509-027-core-refactoring/` ディレクトリ作成
- [x] `requirements.md` 作成
- [x] `design.md` 作成
- [x] `tasklist.md` 作成（本ファイル）
- [ ] ステアリング 3 ファイルを 1 コミットでコミット (`📝 Add steering for 20260509-027 (core-refactoring)`)
- [ ] `EnterWorktree` で `core-refactoring` という名前の worktree を作成し、以降の作業を隔離

## Phase 1: P2 — Obj.magic 除去 (worktree 内)

### 1a. Event._targetToJs

- [ ] `Event.res` に `type targetJs = {kind: string, label?: string}` を追加
- [ ] `_targetToJs` を typed record 版に書き換え
- [ ] `external _emitTo` のシグネチャを `(targetJs, string, 'payload) => promise<unit>` に変更
- [ ] `pnpm --filter @rescript-tauri/core build` 成功確認
- [ ] `pnpm --filter @rescript-tauri/core test` 全件 pass 確認
- [ ] `Event.res.mjs` の生成 JS が emitTo の引数構造として等価であることを目視確認

### 1b. Core.Command.invoke の Obj.magic

- [ ] `Core.res` に private helper `_exnToJson: exn => JSON.t` を追加
- [ ] `Command.invoke` の `Error(RustError(exn->Obj.magic))` を `Error(RustError(_exnToJson(exn)))` に置換
- [ ] `core_command.test.mjs` で RustError ペイロードの assertion を新フォーマット（`{name, message}` JSON）に更新
- [ ] ビルド・テスト全件 pass 確認

### 1 完了

- [ ] `grep -r Obj.magic packages/core/src/` が 0 件であること確認
- [ ] コミット: `♻️ Replace Obj.magic with typed records in Event/Core`

## Phase 2: P1 — Decoder エイリアスと _applyDecoder ヘルパ

- [ ] `Core.res` トップレベルに `type decoder<'value> = JSON.t => result<'value, string>` を追加
- [ ] `Core.res` に private helper `_applyDecoder` を追加（callback 引数は `'a => unit` 形のまま、Step 3 で result 化）
- [ ] `Core.resi` で `decoder<_>` を公開（doc コメント付き）
- [ ] `Command.t.decodeResult` の型を `decoder<'result>` に変更
- [ ] `Channel.t.decode` の型を `decoder<'message>` に変更
- [ ] `Channel.onMessage` を `_applyDecoder` 経由に書き換え（silent drop は維持）
- [ ] `Event.res` で `Event.t.decode` の型を `Core.decoder<'payload>` に変更
- [ ] `Event._wrap` を `Core._applyDecoder` 経由に書き換え（silent drop は維持）
- [ ] signature テスト (`core_command_signature.res`, `core_channel_signature.res`, `event_signature.res`) が alias で通ることを確認
- [ ] ビルド・テスト全件 pass 確認
- [ ] コミット: `♻️ Extract decoder type alias and applyDecoder helper`

## Phase 3: P0 — callback で result を渡す（破壊変更）

- [ ] `_applyDecoder` の callback 型を `result<'a, string> => unit` に変更
- [ ] `Channel.onMessage` の callback 型を `result<'message, string> => unit` に変更（`.resi` も更新）
- [ ] `Event._wrap` を `Ok(event)` / `Error(msg)` を渡す形に書き換え
- [ ] `Event.listen` / `Event.once` の callback 型を `result<event<'payload>, string> => unit` に変更（`.resi` も更新）
- [ ] `.resi` の docstring を新ポリシーに合わせて更新
- [ ] ビルド成功確認（テストはまだ古いまま）
- [ ] コミット: `✨ Surface decode errors as result in listen/once/onMessage` （※破壊変更）

## Phase 4: テスト更新

### event.test.mjs

- [ ] "listen captures a callback" を新シグネチャ対応に書き換え（callback が `{TAG: "Ok", _0: event}` を受ける）
- [ ] "listen drops messages whose decode fails" → "listen surfaces decode errors as Error" に変更（`Error("...")` を assertion）
- [ ] 新規テスト: 連続デリバー（成功 → 失敗 → 成功）で Ok/Error/Ok を受けること
- [ ] 新規テスト: 成功時に Error が呼ばれない、失敗時に Ok が呼ばれない（negative assertion）
- [ ] 新規テスト: `Event.once` でデコード失敗時の auto-unsubscribe 挙動を確認

### core_channel.test.mjs

- [ ] "onMessage forwards decoded messages" を新シグネチャ対応に書き換え（callback が `Ok(...)` を受ける）
- [ ] "decode failures are silently dropped" → "decode failures surface as Error" に変更
- [ ] 新規テスト: 連続デリバー統合テスト

### signature テスト

- [ ] `event_signature.res` の callback 型を `result<event<'_>, string> => unit` に書き換え
- [ ] `core_channel_signature.res` の callback 型を `result<'_, string> => unit` に書き換え

### Phase 4 完了

- [ ] `pnpm --filter @rescript-tauri/core test` 全件 pass
- [ ] コミット: `✅ Update tests for result-based decode error propagation`

## Phase 5: P3 — ドキュメント整備

- [ ] `docs/functional-design.md` line 216 周辺の console.error 記述を新ポリシーに更新
- [ ] `docs/functional-design.md` line 523 周辺の `Event.eventError` 記述を新ポリシーに更新
- [ ] `docs/repository-structure.md` §3 の Phase 2+ examples を「(Phase 2+ planned, 未作成)」と明示
- [ ] `docs/architecture.md` に「Decode failure policy」セクションを追加
- [ ] `Core.res` / `Event.res` の private helper (`_wrap`, `_targetToJs`, `_applyDecoder`, `_exnToJson`) に doc コメント追加
- [ ] `examples/hello-world/` 内に `Event.listen` / `Channel.onMessage` の call site があるか確認、あれば新シグネチャに追従
- [ ] `pnpm --filter hello-world build` 成功確認
- [ ] コミット: `📝 Update docs to reflect unified decode failure policy`

## Phase 6: 検証 + マージ

- [ ] `pnpm --filter @rescript-tauri/core build` 成功
- [ ] `pnpm --filter @rescript-tauri/core test` 全件 pass
- [ ] `pnpm --filter hello-world build` 成功
- [ ] `grep -r Obj.magic packages/core/src/` が 0 件
- [ ] 自己検証: 型チェック・ビルドで警告 0 件
- [ ] tasklist.md の全タスクを `[x]` に更新（マージタスク自体含む）
- [ ] tasklist 更新を最終コミットとして含める
- [ ] AskUserQuestion で main へのマージ可否を確認
- [ ] 承認後、worktree マージ・クリーンアップ手順を実行
  - [ ] CWD をメインリポジトリに変更
  - [ ] `git merge worktree-core-refactoring --no-ff -m "Merge branch 'worktree-core-refactoring' (steering 027: core refactoring)"`
  - [ ] `git worktree remove .claude/worktrees/core-refactoring`
  - [ ] `git branch -d worktree-core-refactoring`
- [ ] クリーンアップ検証
  - [ ] `git worktree list` で main のみ表示
  - [ ] `git branch --list 'worktree-*'` の出力が空（他作業がある場合は除外して確認）
  - [ ] `.claude/worktrees/core-refactoring` が存在しない

## 想定される追加タスク（実装中に判明したら追記）

- 該当なし（着手前）
