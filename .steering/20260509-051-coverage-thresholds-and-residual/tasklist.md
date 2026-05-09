# Coverage しきい値ゲートと残カバレッジ補強 — タスクリスト (tasklist.md)

## A. 残カバレッジ補強 (core)

### A-1. Tray action callback 配信検証

- [ ] A-1-1 `tray.test.mjs` に Channel callback Map パターンの setup を追加
- [ ] A-1-2 `Click` バリアント発火 + assertion
- [ ] A-1-3 `DoubleClick` バリアント発火 + assertion
- [ ] A-1-4 `Enter` バリアント発火 + assertion
- [ ] A-1-5 `Move` バリアント発火 + assertion
- [ ] A-1-6 `Leave` バリアント発火 + assertion
- [ ] A-1-7 unknown kind での fall-through 検証

### A-2. Webview onDragDropEvent variant 解釈

- [ ] A-2-1 `webview.test.mjs` に Event listener callback 取得パターンを追加
- [ ] A-2-2 `Enter({paths, position})` 配信 + assertion
- [ ] A-2-3 `Over({position})` 配信 + assertion
- [ ] A-2-4 `Drop({paths, position})` 配信 + assertion
- [ ] A-2-5 `Leave` 配信 + assertion
- [ ] A-2-6 unknown kind 配信時の `console.warn` spy 検証

### A-3. Menu PredefinedItem 全バリアント

- [ ] A-3-1 17 個の string-only バリアント（Separator〜BringAllToFront）を `for` ループで網羅検証
- [ ] A-3-2 `NativeIcon` 代表 5 値 (`Add` / `BluetoothTemplate` / `User` / `Trash` / `Network`) を `IconMenuItem.make` 経由で検証

### A-4. steering 049 新 API カバレッジ

- [ ] A-4-1 `Core.isTauri()` の偽値 / 真値テスト
- [ ] A-4-2 `Core.Resource.rid` / `Core.Resource.close` を `Image.fromPath` のハンドル経由で検証
- [ ] A-4-3 `Core.PluginListener` の `unregister` callable check
- [ ] A-4-4 `Core.addPluginListener` の mockIPC 検証
- [ ] A-4-5 `Core.checkPermissions` / `requestPermissions` の mockIPC 検証
- [ ] A-4-6 `Core.transformCallback` の数値 ID 取得検証
- [ ] A-4-7 `Mocks.mockConvertFileSrc` の関数差し替え動作検証
- [ ] A-4-8 `Mocks.mockIPC(~options=?)` の `shouldMockEvents` オプション動作検証
- [ ] A-4-9 `Event.TauriEvent` 17 値の string コンパイル後値検証
- [ ] A-4-10 `Event.listen(~target=?)` / `Event.once(~target=?)` の listenOptions 検証
- [ ] A-4-11 Window 新メソッド (`activityName` / `sceneIdentifier` / `setFocusable` / `setSimpleFullscreen` / `toggleMaximize` / `unminimize` / `onDragDropEvent`) の dispatch 検証
- [ ] A-4-12 Webview 新メソッド (`clearAllBrowsingData` / `getByLabel`) の dispatch 検証

### A-5. 検証 + コミット

- [ ] A-5-1 `pnpm --filter @rescript-tauri/core test:coverage` で statements ≥ 90% / functions ≥ 95% / branches ≥ 60% を確認
- [ ] A-5-2 各テーマ別にコミット（絵文字: ✅、テーマ別 5-6 コミット程度）

## B. Coverage thresholds 導入

- [ ] B-1 Scope A 完了後の実測値を全 4 パッケージで取得
- [ ] B-2 `packages/core/vitest.config.mjs` に `thresholds` 追加（実測値 -2-3 pt）
- [ ] B-3 `packages/plugin-fs/vitest.config.mjs` に `thresholds` 追加（100/50/100/100）
- [ ] B-4 `packages/plugin-dialog/vitest.config.mjs` に `thresholds` 追加（100/60/100/100）
- [ ] B-5 `packages/schema/vitest.config.mjs` に `thresholds` 追加（90/50/100/90）
- [ ] B-6 各パッケージで `test:coverage` を実行し、thresholds 違反でないことを確認
- [ ] B-7 Scope B をコミット（絵文字: 🔧）

## C. CI ドキュメンテーション更新

- [ ] C-1 `docs/functional-design.md` §6 `tests-coverage` 行の「観測フェーズ」記述を更新
- [ ] C-2 `docs/product-requirements.md` §5.4 の coverage 関連記述を thresholds ゲート確定で更新
- [ ] C-3 `sphinx-docs/dev/architecture.md` で coverage に触れていれば同期
- [ ] C-4 Scope C をコミット（絵文字: 📝）

## D. 全体検証

- [ ] D-1 `pnpm --recursive build` 緑
- [ ] D-2 `pnpm --recursive test` 全件パス
- [ ] D-3 `pnpm run check` (Biome) 緑
- [ ] D-4 全パッケージで test:coverage を再実行し、thresholds 違反なしを最終確認
- [ ] D-5 最終 coverage 値を steering 内に記録

## マージ

- [ ] M-1 tasklist.md の全タスクを `[x]` に更新（マージタスク自体を含む）
- [ ] M-2 tasklist 更新コミットを作成
- [ ] M-3 ユーザーに main へのマージ可否を確認
- [ ] M-4 main にマージ + worktree / ブランチ クリーンアップ
- [ ] M-5 クリーンアップ完了の検証
