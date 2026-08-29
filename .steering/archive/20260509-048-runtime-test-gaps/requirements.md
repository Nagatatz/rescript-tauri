# Runtime テストギャップ補強 — 要件定義 (requirements.md)

| 項目 | 内容 |
|---|---|
| 開発タイトル | runtime-test-gaps |
| 起票日 | 2026-05-09 |
| ステータス | Approved（ユーザー承認済み 2026-05-09） |
| 関連 | 直前のセッション（steering 047）レビューで「Tray / Menu / Image / App / Path runtime テスト未整備」が Low 指摘 |

## 1. 目的

`@vitest/coverage-v8` で計測した core パッケージの runtime カバレッジが **statements 14.85%** と低い水準にあり、特に **App / Dpi / Image / Menu / Path / Tray / Webview / WebviewWindow の 8 モジュールが 0%**、`Window` が **7.31%** という状態。pre-1.0 のうちに薄い runtime テストを追加して、

- 公開バインディングが invoke / コンストラクタ呼び出しを実際にトリガする (= JS Tauri runtime と接続している) ことを最低 1 ケースで確認する
- 後続の上流追従 minor で生じる API drift を runtime レベルでも検知できる土台を整える

を達成する。あわせて `plugin-fs` 側の未カバー 8 関数と `schema` の未カバー 1 関数も拾う。

## 2. 背景

steering 047 のフォローアップでユーザーから「Tray / Menu / Image / App / Path runtime テスト追加 + 他のギャップ確認 + カバレッジ計測可否」の依頼。計測した結果、上記モジュール群が完全に未カバーであることが判明した。

タイプレベルテスト (`packages/core/tests/*_signature.res`) は 100% シンボル参照を強制しているため、API 表面の非互換破壊は検知できる。しかし「呼び出し時に実際に invoke が走るか」「class-based API が happy-dom + `Mocks.mockIPC` 経由で正しく動くか」は別の話で、runtime 層の検証が必要。

`tests-coverage.yml` ジョブは既に matrix で 4 パッケージ並列計測 → Job summary + LCOV/HTML artifact 生成まで整備済み（観測フェーズ、しきい値ゲートなし）。本ステアリングはその観測値を底上げする位置づけ。

## 3. スコープ

### 3.1 必須追加 — core パッケージ

以下 8 モジュールに `packages/core/tests/runtime/<name>.test.mjs` を新規追加する。各テストファイルは

- `Mocks.mockIPC` で `__TAURI_INTERNALS__.invoke` を差し替え
- 主要なエクスポート関数 / コンストラクタ / インスタンスメソッドを 1 ケース以上実行
- 戻り値が mock からの値と一致することをアサート

を最低限満たす。1 ファイル 3〜10 ケース程度を想定。

- [ ] `app.test.mjs` — `getName` / `getVersion` / `getTauriVersion` / `getIdentifier` / `show` / `hide` / `defaultWindowIcon` / `setTheme` / `setDockVisibility`
- [ ] `dpi.test.mjs` — `LogicalSize.make` / `PhysicalSize.make` / `LogicalPosition.make` / `PhysicalPosition.make` / `Size.fromLogical` + `Size.fromPhysical` / `Position.fromLogical` + `Position.fromPhysical` / 各 getter (`width`, `height`, `x`, `y`) / `toLogical` 変換
- [ ] `image.test.mjs` — `new_` / `fromBytes` / `fromPath` / `rgba` / `size`
- [ ] `menu.test.mjs` — `MenuItem.make` / `CheckMenuItem.make` / `IconMenuItem.make` / `PredefinedMenuItem.make` / `Submenu.make` / `Menu.make` / `Menu.default` / `setText` / `isEnabled` / `setEnabled` / `setChecked` 系の代表メソッド
- [ ] `path.test.mjs` — `appConfigDir` / `appDataDir` / `join` / `normalize` / `dirname` / `basename` / `extname` / `isAbsolute` / `resolve` / `sep` / `delimiter` / `BaseDirectory.t` の 1 値が呼べる
- [ ] `tray.test.mjs` — `make` / `getById` / `removeById` / `setIcon` / `setMenu` / `setTooltip` / `setTitle` / `setVisible` / `setIconAsTemplate` / `setShowMenuOnLeftClick` / `close` / `id`
- [ ] `webview.test.mjs` — `getCurrentWebview` / `getAllWebviews` / `setSize` / `setPosition` / `position` / `size` / `setFocus` / `setAutoResize` / `hide` / `show` / `setZoom` / `reparent` / `setBackgroundColor` / `close` / `onDragDropEvent`
- [ ] `webview_window.test.mjs` — `make` / `getCurrent` / `getAll` / `getByLabel` / `asWindow` / `asWebview` / `label` / `setTitle` / `close` / `setBackgroundColor`

### 3.2 既存補強 — Window モジュール

`window.test.mjs` の現状 5 ケースでは `Window.res.mjs` の 7.31% しか到達できない。後続で追加するテストはコンパクトで構わないので、最低でも以下を増やす:

- [ ] `setBackgroundColor` の `Nullable.null` / `Nullable.make({...})` 両方の呼び出し（steering 047 D-1 で破壊変更したシグネチャの runtime 確認）
- [ ] `setTheme` の `Nullable.null` / `Nullable.make(#dark)` 両方
- [ ] `monitorFromPoint(~x, ~y)` のラベル呼び出し（D-11 のラベル化変更の runtime 確認）
- [ ] `setSize` / `setMinSize` / `setMaxSize` の `Dpi.Size.fromLogical` 連携（Dpi runtime テストと相互補強）
- [ ] `onResized` / `onCloseRequested` 等のイベントリスナー登録（unlisten 戻り値の callability まで）

ただし Window の網羅率を目安として 50% 超まで上げる（残り 50% は examples 側で確認）。

### 3.3 plugin-fs 補強

未カバー 8 関数:

- [ ] `readFile` (バイト配列の戻り値型)
- [ ] `writeFile` (バイト配列の引数渡し)
- [ ] `remove`
- [ ] `rename`
- [ ] `lstat`
- [ ] `copyFile`
- [ ] `truncate`
- [ ] `size`

`packages/plugin-fs/tests/runtime/plugin_fs.test.mjs` に追記。

### 3.4 schema 補強

未カバー 1 関数を特定して追加。

- [ ] `coverage-final.json` を grep して未カバー関数を特定
- [ ] 該当関数を `packages/schema/tests/runtime/schema.test.mjs` に追加

### 3.5 plugin-dialog

100% 達成済み。本ステアリングでは触らない。

## 4. Out of scope

- カバレッジしきい値ゲートの導入 (`coverage.thresholds`) — 観測フェーズ継続、別ステアリング
- 例題 (`examples/*`) 側のテスト追加 — 例題は 3 OS ビルドで担保
- doc-link-lint や型レベルテストの拡充
- `Tauri.res` re-export モジュールの runtime テスト（薄い再公開のみで実体テスト不要）

## 5. 完了条件

- 上記 3.1〜3.4 の `[ ]` 項目をすべて埋める
- `pnpm --filter @rescript-tauri/core test:coverage` で
  - core: statements ≥ 60% （8 モジュール × 主要関数を埋めれば達成可能な水準）
  - functions: ≥ 60%
  - 8 つの 0% モジュールが**すべて 50% 超**になる
- `pnpm --filter @rescript-tauri/plugin-fs test:coverage` で statements ≥ 95% (14 関数全カバー)
- `pnpm --filter @rescript-tauri/schema test:coverage` で functions ≥ 95% (6 関数中 6 をカバー)
- `pnpm --recursive build` 緑、`pnpm --recursive test` 全件パス、`pnpm run check` 緑
- カバレッジ Job summary が main マージ後に CI で更新される（手動確認は不要、artifact が出ればよい）
