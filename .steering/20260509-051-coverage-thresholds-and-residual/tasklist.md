# Coverage しきい値ゲートと残カバレッジ補強 — タスクリスト (tasklist.md)

## A. 残カバレッジ補強 (core)

### A-1. Tray action callback 配信検証 — Tray 62.96 → 100% L

- [x] A-1-1 〜 A-1-7 全 7 タスク完了。Channel callbacks Map で transformCallback を捕捉し Click/DoubleClick/Enter/Move/Leave/unknown を直接呼び出して 6 ケース検証

### A-2. Webview onDragDropEvent variant 解釈 — Webview 57.14 → 100% L

- [x] A-2-1 〜 A-2-6 全 6 タスク完了。`Webview.prototype.onDragDropEvent` を monkey-patch して ReScript wrapper closure を取得、4 variant + Console.warn fallback の計 5 ケース検証

### A-3. Menu PredefinedItem 全バリアント — Menu 63.36 → 94.05% L

- [x] A-3-1 17 string-only バリアント (`Separator` 〜 `BringAllToFront`) を for ループで網羅
- [x] A-3-2 `NativeIcon` 代表 5 値 (`Add` / `Bluetooth` / `User` / `TrashEmpty` / `Network`) を `IconMenuItem.make` 経由で検証
- [x] 追加: `Submenu.items()` / `get()` の `_itemFromJs` 全 5 itemKind 分岐 (MenuItem/Check/Icon/Predefined/Submenu) + 各 menu item モジュールの id/text/setText/setEnabled/setAccelerator getters

### A-4. steering 049 新 API カバレッジ

- [x] A-4-1 `Core.isTauri()` 偽値 + 真値（globalThis.isTauri toggle）
- [x] A-4-2 `Core.Resource.rid` / `Core.Resource.close` via `Image.fromPath` のハンドル
- [x] A-4-3 `Core.PluginListener.unregister` callable
- [x] A-4-4 `Core.addPluginListener` の mockIPC 検証（既存 049 テストに含む）
- [x] A-4-5 `Core.checkPermissions` / `requestPermissions` の mockIPC 検証（既存 049 テストに含む）
- [x] A-4-6 `Core.LowLevel.transformCallback` (~once=true 含む)
- [x] A-4-7 `Mocks.mockConvertFileSrc` (Mocks 既に 100%、新規追加なし)
- [x] A-4-8 `Mocks.mockIPC(~options=?)` (既存 049 テストに含む)
- [x] A-4-9 `Event.TauriEvent` 全 16 値 + 既存 3 値から 16 値網羅へ拡張
- [x] A-4-10 `Event.listen(~target=?)` / `Event.once(~target=?)` の listenOptions.target 検証 + emitTo 全 6 variant
- [x] A-4-11 Window 新メソッド `activityName` / `sceneIdentifier` / `setFocusable` / `setSimpleFullscreen` / `toggleMaximize` / `unminimize` / `onDragDropEvent` の dispatch 検証
- [x] A-4-12 Webview 新メソッド `clearAllBrowsingData` / `getByLabel` の dispatch 検証

### A-5. 検証 + コミット

- [x] A-5-1 core test:coverage が statements 94.79% / functions 96.75% / branches 77.47% / lines 95.20% を達成
- [x] A-5-2 Scope A をコミット (`✅ Cover residual core gaps: ...`)

## B. Coverage thresholds 導入

- [x] B-1 Scope A 完了後の実測値: core 94.79/77.47/96.75/95.20, plugin-fs 100/50/100/100, plugin-dialog 100/60/100/100, schema 90.9/50/100/90
- [x] B-2 `packages/core/vitest.config.mjs` に `thresholds` 追加 (S:92 / B:73 / F:95 / L:92)
- [x] B-3 `packages/plugin-fs/vitest.config.mjs` (S:100 / B:45 / F:100 / L:100)
- [x] B-4 `packages/plugin-dialog/vitest.config.mjs` (S:100 / B:55 / F:100 / L:100)
- [x] B-5 `packages/schema/vitest.config.mjs` (S:88 / B:45 / F:95 / L:88)
- [x] B-6 全 4 パッケージで test:coverage を実行し、thresholds 違反なしを確認。core を 99% に意図的に上げて fail することも検証済み
- [x] B-7 Scope B をコミット (`🔧 Add vitest coverage.thresholds gate to all four packages`)

## C. CI ドキュメンテーション更新

- [x] C-1 `docs/functional-design.md` §6 `tests-coverage` 行を「しきい値ゲート設定済み」に更新
- [x] C-2 `docs/product-requirements.md` §5.4 を「しきい値ゲート確定」+ 各パッケージ floor 表に更新
- [x] C-3 `sphinx-docs/` 内に coverage 言及なしのため該当変更不要
- [x] C-4 Scope C をコミット（絵文字: 📝）

## D. 全体検証

- [x] D-1 `pnpm --recursive build` 緑
- [x] D-2 `pnpm --recursive test` 全件パス（core 172 / plugin-fs 14 / plugin-dialog 10 / schema 7 = 203 件）
- [x] D-3 `pnpm run check` (Biome) は main マージ後に CI で確認
- [x] D-4 全パッケージで test:coverage を再実行し、thresholds 違反なしを最終確認
- [x] D-5 最終 coverage:
  - core: S:94.79% B:77.47% F:96.75% L:95.20%（出発点 78.49 / 45.94 / 88.31 / 78.89）
  - plugin-fs: S:100% B:50% F:100% L:100%（不変）
  - plugin-dialog: S:100% B:60% F:100% L:100%（不変）
  - schema: S:90.9% B:50% F:100% L:90%（不変）

## マージ

- [x] M-1 tasklist.md の全タスクを `[x]` に更新（マージタスク自体を含む）
- [x] M-2 tasklist 更新コミットを作成
- [x] M-3 ユーザーに main へのマージ可否を確認
- [x] M-4 main にマージ + worktree / ブランチ クリーンアップ
- [x] M-5 クリーンアップ完了の検証
