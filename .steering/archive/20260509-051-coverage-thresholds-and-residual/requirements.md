# Coverage しきい値ゲートと残カバレッジ補強 — 要件定義 (requirements.md)

| 項目 | 内容 |
|---|---|
| 開発タイトル | coverage-thresholds-and-residual |
| 起票日 | 2026-05-09 |
| ステータス | Approved（ユーザー承認済み 2026-05-09） |
| 関連 | 直前のセッション（steering 048）で残務として記録された 2 項目 |

## 1. 目的

steering 048 で大きく底上げした runtime カバレッジ観測フェーズを締めくくり、

- **観測フェーズ → ゲートフェーズ**へ移行する。`vitest.config.mjs` の `coverage.thresholds` を全 4 パッケージ（core / plugin-fs / plugin-dialog / schema）に設定し、`tests-coverage.yml` が「現状値を下回ったら fail」する CI ジョブとして機能するようにする。
- core パッケージに残った非自明な未カバー領域（Tray action callback の Channel 配信、Webview onDragDropEvent の variant 解釈、Menu predefined item の他バリアント、steering 049 で追加された Core / Event / Window / Webview / Mocks の新 API）を**段階的に補強**してから、しきい値を「現状値プラス余裕なし」で固定する。

を達成する。

## 2. 背景

steering 048 終盤で記録した残務 2 件:

1. カバレッジしきい値ゲート (`coverage.thresholds`) の導入 — 観測フェーズ継続、別ステアリング案件
2. core で残る 12% (Tray の action callback 配信検証 / Webview の onDragDropEvent payload variant 解釈 / Menu の predefined item の他バリアント / steering 049 で追加された新 API 群) — 段階追加が望ましい

加えて、この間に並行で merge された steering 049（`Resource` / `PluginListener` / `transformCallback` / `addPluginListener` / `checkPermissions` / `requestPermissions` / `isTauri` / TauriEvent enum / `~target` オプション / `mockConvertFileSrc` / `Window` & `Webview` の追加メソッド / `Menu.NativeIcon` 等）の追加 API が runtime テストで未カバーのままになっており、本ステアリングで一括補強する。

ベースライン (本ステアリング着手時点):

| パッケージ | Statements | Functions | Branches |
|---|---|---|---|
| core | 78.49% (332/423) | 88.31% (272/308) | 45.94% (51/111) |
| plugin-fs | 100% | 100% | 50% (14/28) |
| plugin-dialog | 100% | 100% | 60% (6/10) |
| schema | 90.90% (10/11) | 100% (6/6) | 50% (1/2) |

core の残 12% は以下に偏っている:

| Module | Lines | Functions | Branches |
|---|---|---|---|
| Webview | 57.14% | 84.21% | **0%** |
| Tray | 62.96% | 88.23% | 28.57% |
| Menu | 63.36% | 74.19% | 31.81% |
| Event | 77.27% | 83.33% | 71.42% |
| Window | 80.80% | 88.88% | 46.15% |
| Core | 88.88% | 86.36% | 60% |

## 3. スコープ

### 3.1 Scope A — core 残カバレッジ補強

**A-1. Tray action callback の配信検証**

`Tray.make({action: handler})` で登録した handler が、Tauri 内部の `Channel` から `_eventFromJs` を経由して `trayIconEvent` variant に正しく解釈されることを runtime テストで検証する。

- `Click` / `DoubleClick` / `Enter` / `Move` / `Leave` の 5 variant すべて 1 ケースずつ
- 各ケースで `id` / `position` / `rect` フィールドが意図したまま保持されること
- 不明な `type` 文字列は default ブランチで Leave に fall-through する仕様（`Tray.res:79`）の検証

実装手段: `Mocks.mockIPC` の handler 内で Channel に流すペイロードを `__TAURI_INTERNALS__.transformCallback` で取得した callback ID 経由で発火する。具体的な setup は `packages/schema/tests/runtime/schema.test.mjs` の `channelFromSchema` テストパターン（callbacks Map + 直接呼び出し）を流用する。

**A-2. Webview onDragDropEvent の variant 解釈**

`Webview.res:53` の `onDragDropEvent` ラッパが `enter` / `over` / `drop` / `leave` の各 `kind` 文字列を正しく variant に翻訳することを検証する。steering 047 D-2 で追加した「未知 kind は `Console.warn` でログ」のフォールバックも検証対象。

- `Enter({paths, position})` / `Over({position})` / `Drop({paths, position})` / `Leave` の 4 ケース
- 未知 kind を投入したときの `Console.warn` 呼び出し（`vi.spyOn(console, "warn")` で観測）

**A-3. Menu PredefinedItem 全バリアント**

steering 049 で追加された `NativeIcon` enum と既存 `predefinedItem` 列挙 17 値（`Separator` / `Copy` / `Cut` / `Paste` / `SelectAll` / `Undo` / `Redo` / `Minimize` / `Maximize` / `Fullscreen` / `Hide` / `HideOthers` / `ShowAll` / `CloseWindow` / `Quit` / `Services` / `BringAllToFront` / `About(meta)`）の `_predefinedToJs` 変換を網羅する。

- 17 個の string-only バリアントを `_predefinedToJs` 直接呼び出し（公開されていないので Menu.res 側を export するか、`PredefinedMenuItem.make` 経由で確認）で確認
- `About(meta)` の object encoding（既存）
- `NativeIcon` の代表 5 値（`Add` / `BluetoothTemplate` / `User` / `Trash` / `Network`）が string にコンパイルされて invoke 引数に乗ることを確認

**A-4. steering 049 新 API のカバレッジ**

| Module | API | テスト |
|---|---|---|
| Core | `isTauri()` | 偽値 / 真値の両ケース |
| Core | `Resource.rid` / `Resource.close()` | mockIPC で plugin:resources\|close 検証 |
| Core | `PluginListener.unregister` | callable check |
| Core | `addPluginListener` | mockIPC で plugin:<plugin>\|register_listener 検証 |
| Core | `checkPermissions` / `requestPermissions` | mockIPC でコマンド名検証 |
| Core | `transformCallback` | 直接呼び出して数値 ID を受け取る |
| Mocks | `mockConvertFileSrc` | 既存テストと同パターン |
| Mocks | `MockIPCOptions` (~options=?) | shouldMockEvents=true で event hooked check |
| Event | `TauriEvent.windowResized` 他全 17 値 | string コンパイル後の値が `tauri://...` であることを assertion |
| Event | `listen(~target=?)` / `once(~target=?)` | mockIPC で listenOptions.target が JS 側に渡ること |
| Window | `activityName` / `sceneIdentifier` / `setFocusable` / `setSimpleFullscreen` / `toggleMaximize` / `unminimize` / `onDragDropEvent` | mockIPC 経由で各 dispatch 確認 |
| Webview | `clearAllBrowsingData` / `getByLabel` | mockIPC 経由 |

### 3.2 Scope B — `coverage.thresholds` の導入

各パッケージの `vitest.config.mjs` に以下を追加:

```js
coverage: {
  ...,
  thresholds: {
    statements: <X>,
    branches: <X>,
    functions: <X>,
    lines: <X>,
  },
},
```

しきい値の方針:

- Scope A 補強後の実測値より **2-3 ポイント低い値**を設定し、誤計測ジッタで CI が割れない安全マージンを確保する
- `tests-coverage.yml` の `Run coverage` ステップは vitest が thresholds 未達で exit 非 0 を返すので、追加の判定ロジックは不要
- 達成済みパッケージ（plugin-dialog 100%, plugin-fs 100%）は **100% を維持**するしきい値を設定（regression を即検知）

具体目標値（Scope A 完了後に再計測して最終値を決定するが、初期目標は以下）:

| パッケージ | statements | branches | functions | lines |
|---|---|---|---|---|
| core | 90 | 60 | 95 | 90 |
| plugin-fs | 100 | 50 | 100 | 100 |
| plugin-dialog | 100 | 60 | 100 | 100 |
| schema | 90 | 50 | 100 | 90 |

### 3.3 Scope C — CI ドキュメンテーション更新

- `docs/functional-design.md` §6 の `tests-coverage` 行で「観測フェーズ：しきい値による fail ゲートは設定しない」記述を「しきい値ゲート設定済み」に更新
- `docs/product-requirements.md` §5.4 の coverage 関連記述を実態に合わせる
- `.steering/20260509-040-test-coverage-ci/` の planning ノートを参照（必要に応じて archive リンク）

## 4. Out of scope

- 例題 (`examples/*`) 側のカバレッジ計測 — 例題は 3 OS ビルドで担保
- doc-link-lint や型レベルテストの拡充
- `Tauri.res` re-export モジュールへの直接テスト
- Tauri 上流が持っていない API のラッパー追加（カバレッジ補強の範囲を超える）

## 5. 完了条件

- 上記 Scope A〜C の全タスクが `[x]` 化
- `pnpm --filter @rescript-tauri/core test:coverage` で
  - statements ≥ 90%
  - functions ≥ 95%
  - branches ≥ 60%（Webview / Tray / Menu の主要 branch を網羅した結果）
- `pnpm --filter @rescript-tauri/plugin-fs test:coverage` で 100% / 100% / 50% 維持
- `pnpm --filter @rescript-tauri/plugin-dialog test:coverage` で 100% / 100% / 60% 維持
- `pnpm --filter @rescript-tauri/schema test:coverage` で 90% / 100% / 50% 維持
- 各パッケージの coverage コマンドが thresholds 違反で fail しない
- `pnpm --recursive build` 緑、`pnpm --recursive test` 全件パス、`pnpm run check` 緑
- マージ後、`tests-coverage.yml` ジョブが threshold check を含む形で通る（CI で確認）
