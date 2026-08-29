# タスクリスト: Core.Command

- [x] **commit 1 (main)**: ステアリング 3 ファイル配置
- [x] EnterWorktree
- [x] **commit 2**: Core.res + Core.resi に invokeError + module Command 追加（ReScript 12 で `Exn.raiseError` / `Exn.Error` deprecated → `JsError.throwWithMessage` + `exn` ワイルドカードに切り替え、warning ゼロ）
- [x] **commit 3**: tests/core_command_signature.res（`Core.invokeError` フル path 参照）+ tests/runtime/core_command.test.mjs 5 ケース 新規
- [x] 検証: `pnpm --filter @rescript-tauri/core test` → 3 files, 9 tests passed
- [x] **commit 4**: tasklist 全 [x] 化
- [ ] マージ → クリーンアップ → push
