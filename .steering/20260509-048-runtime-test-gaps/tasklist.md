# Runtime テストギャップ補強 — タスクリスト (tasklist.md)

## A. core 新規 runtime テスト (8 モジュール)

- [x] A-1 `tests/runtime/dpi.test.mjs` 追加（IPC 不要 / 純 JS 構築）→ Dpi 100%
- [x] A-2 `tests/runtime/path.test.mjs` 追加（23 関数 + sep/delimiter は plugins.path グローバル経由）→ Path 100%
- [x] A-3 `tests/runtime/app.test.mjs` 追加（9 関数）→ App 100%
- [x] A-4 `tests/runtime/image.test.mjs` 追加（5 関数）→ Image 100%
- [x] A-5 `tests/runtime/menu.test.mjs` 追加（6 module の make + Submenu/Menu 全メソッド）→ Menu 63.36%
- [x] A-6 `tests/runtime/tray.test.mjs` 追加（11 send メソッド + action handler）→ Tray 62.96%
- [x] A-7 `tests/runtime/webview.test.mjs` 追加（14 メソッド + onDragDropEvent unlisten）→ Webview 61.53%
- [x] A-8 `tests/runtime/webview_window.test.mjs` 追加（make/getCurrent/getAll/getByLabel/label/setTitle/close/setBackgroundColor。`asWindow`/`asWebview` は `%identity` キャストで実体関数なし、型レベルテストで担保）→ WebviewWindow 100%
- [x] A-9 core test:coverage で 8 モジュールが 50% 超まで上昇することを確認。Total 14.85% → 62.86%
- [x] A-10 Scope A をコミット（絵文字: ✅）

## B. core Window 補強

- [x] B-1 `window.test.mjs` に `setBackgroundColor` Nullable 両ケース追加
- [x] B-2 `window.test.mjs` に `setTheme` Nullable 両ケース追加
- [x] B-3 `window.test.mjs` に `monitorFromPoint(~x, ~y)` ラベル呼び出し追加
- [x] B-4 `window.test.mjs` に `setSize` + `Dpi.Size.fromLogical` 連携追加
- [x] B-5 `window.test.mjs` に `onResized` 登録 + unlisten 呼び出し追加（onMoved/onCloseRequested/onFocusChanged/onScaleChanged/onThemeChanged も含む）
- [x] B-6 core test:coverage で Window 7.31% → 97.56% に到達
- [x] B-7 Scope B をコミット（絵文字: ✅）。**bonus**: 既存バインディング `Window.getFocusedWindow` が `@scope("Window")` 漏れで undefined を呼んでいた bug を発見・修正（🐛）

## C. plugin-fs 補強

- [ ] C-1 `plugin_fs.test.mjs` に未カバー 8 関数を追加 (readFile / writeFile / remove / rename / lstat / copyFile / truncate / size)
- [ ] C-2 plugin-fs test:coverage で statements ≥ 95% を確認
- [ ] C-3 Scope C をコミット（絵文字: ✅）

## D. schema 補強

- [ ] D-1 未カバー関数を coverage-summary.json で特定
- [ ] D-2 該当関数を `schema.test.mjs` に追加
- [ ] D-3 schema test:coverage で functions ≥ 95% を確認
- [ ] D-4 Scope D をコミット（絵文字: ✅）

## E. 全体検証

- [ ] E-1 `pnpm --recursive build` 緑
- [ ] E-2 `pnpm --recursive test` 全件パス
- [ ] E-3 `pnpm run check` (Biome) 緑
- [ ] E-4 全パッケージで test:coverage 再実行し最終値を steering 内ノートに記録

## マージ

- [ ] M-1 tasklist.md の全タスクを `[x]` に更新（マージタスク自体を含む）
- [ ] M-2 tasklist 更新コミットを作成
- [ ] M-3 ユーザーに main へのマージ可否を確認
- [ ] M-4 main にマージ + worktree / ブランチ クリーンアップ
- [ ] M-5 クリーンアップ完了の検証
