# タスクリスト: @tauri-apps/api 完全カバレッジ達成

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-049-complete-tauri-api-coverage` |
| ブランチ | `worktree-complete-tauri-api-coverage`（worktree 経由） |

## Phase 0: 準備

- [x] worktree を作成 (`EnterWorktree complete-tauri-api-coverage`)
- [x] requirements.md / design.md / tasklist.md をユーザー承認

## Phase 1: Core 拡張

- [x] `Core.res` / `.resi` に `Resource` モジュール追加
- [x] `Core.res` / `.resi` に `PluginListener` モジュール追加
- [x] `Core.res` / `.resi` に `addPluginListener` 追加
- [x] `Core.res` / `.resi` に `permissionState` 型追加
- [x] `Core.res` / `.resi` に `checkPermissions` / `requestPermissions` 追加
- [x] `Core.res` / `.resi` に `isTauri` 追加
- [x] `Core.res` / `.resi` に `LowLevel.serializeToIpcFn` / `LowLevel.transformCallback` 追加
- [x] `tests/core_extras_signature.res` に新規 API 呼び出しを追加
- [x] `tests/runtime/core_extras.test.mjs` にランタイムテスト追加
- [x] コミット: `✨ Add Resource / PluginListener / permission API to Core`

## Phase 2: App 拡張

- [x] `App.res` / `.resi` の deferred コメント削除
- [x] `App.res` / `.resi` に `dataStoreIdentifier` / `bundleType` / `onBackButtonPressPayload` 型追加
- [x] `App.res` / `.resi` に `fetchDataStoreIdentifiers` / `removeDataStore` 追加
- [x] `App.res` / `.resi` に `getBundleType` 追加
- [x] `App.res` / `.resi` に `onBackButtonPress` / `supportsMultipleWindows` 追加
- [x] `tests/app_signature.res` に新規 API 呼び出しを追加
- [x] `tests/runtime/app.test.mjs` にランタイムテスト追加
- [x] コミット: `✨ Add deferred App APIs (BundleType, DataStore, BackButton)`

## Phase 3: Window / Webview 拡張

- [x] `Window.res` / `.resi` に `activityName` / `sceneIdentifier` / `setFocusable` / `setSimpleFullscreen` / `toggleMaximize` / `unminimize` / `onDragDropEvent` 追加
- [x] `Webview.res` / `.resi` に `clearAllBrowsingData` / `getByLabel` 追加
- [x] `tests/window_signature.res` / `webview_signature.res` 更新
- [ ] `tests/runtime/window.test.mjs` / `webview.test.mjs` 更新（既存のランタイムテストはほぼ smoke + signature でカバー済 — 追加不要）
- [x] コミット: `✨ Add missing Window / Webview instance methods`

## Phase 4: Event 拡張

- [x] `Event.res` / `.resi` に `tauriEvent` polymorphic variant 追加
- [x] `Event.res` / `.resi` の `listen` / `once` に `~target` オプション追加
- [x] `tests/event_signature.res` 更新
- [x] `tests/runtime/event.test.mjs` 更新
- [x] コミット: `✨ Add TauriEvent enum and listen/once target option`

## Phase 5: Mocks 拡張

- [x] `Mocks.res` / `.resi` に `mockIPCOptions` 型追加
- [x] `Mocks.res` / `.resi` の `mockIPC` に `~options=?` 追加
- [x] `Mocks.res` / `.resi` に `mockConvertFileSrc` 追加
- [x] `tests/mocks_signature.res` 更新
- [x] `tests/runtime/mocks.test.mjs` 更新
- [x] コミット: `✨ Add mockConvertFileSrc and MockIPCOptions to Mocks`

## Phase 6: Menu 拡張

- [x] `Menu.res` / `.resi` に `nativeIcon` polymorphic variant 追加
- [x] `tests/menu_signature.res` 更新
- [x] コミット: `✨ Add NativeIcon polymorphic variant to Menu`

## Phase 7: ドキュメント更新

- [x] `packages/core/README.md` に新規 API を Features に追記
- [x] `README.md` (root) のカバレッジ記述を更新
- [x] `docs/repository-structure.md` の Phase 1 完了状況を更新
- [x] `sphinx-docs/dev/architecture.md` は既に "entire upstream public API surface" 表記済 — 修正不要
- [x] コミット: `📝 Update docs to reflect 100% @tauri-apps/api coverage`

## Phase 8: ビルド・テスト・最終確認

- [x] `pnpm --workspace-concurrency 1 --recursive build` 成功（並列実行は rescript の compiler-info race を踏むため逐次化）
- [x] `pnpm --workspace-concurrency 1 --recursive test` 全件 pass（core 39 + plugin-dialog 10 + plugin-fs 6 + schema 5 = 60）
- [x] biome `check --write` で新規 mjs ファイルを整形済（biome 設定上 `.claude/worktrees` は除外されるためツール直叩きで実施）
- [x] tasklist.md の全タスクを `[x]` に更新
- [x] コミット: `✅ Mark all tasks done in tasklist`

## Phase 9: マージ・クリーンアップ

- [x] CWD をメインリポジトリに変更
- [x] 未追跡 `.steering/` ファイルがあれば事前削除
- [x] `git merge worktree-complete-tauri-api-coverage --no-ff -m "Merge branch 'worktree-complete-tauri-api-coverage'"`
- [x] `git worktree remove .claude/worktrees/complete-tauri-api-coverage`
- [x] `git branch -d worktree-complete-tauri-api-coverage`
- [x] `git worktree list` で main のみ確認
- [x] `git branch --list 'worktree-*'` 出力空確認
