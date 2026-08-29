# 要件定義: @tauri-apps/api 完全カバレッジ達成

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-049-complete-tauri-api-coverage` |
| 作成日 | 2026-05-09 |
| 関連 | `docs/product-requirements.md`, `docs/repository-structure.md` §2.1 |

## 1. 背景

`@rescript-tauri/core` は `@tauri-apps/api` v2.11.0 に対し約 95% カバーしているが、`App.resi` 冒頭に「Phase 2 once their stability is confirmed」として deferred されている API 群と、`Core.resi` の `Resource` / `PluginListener` 系、`Mocks.resi` の `mockConvertFileSrc` などが未実装。Phase 2 着手済の現在、**全 stable public API を網羅**してカバレッジ 100% 化する。

## 2. ゴール

- `@tauri-apps/api` v2.11.0 の **stable public export** すべてに対する ReScript バインディングを `packages/core/src/` に提供する。
- 型レベルテスト (`*_signature.res`) と vitest ランタイムテストを全新規 API に作成する。
- 既存 API の挙動・シグネチャは破壊的変更を加えない（追加のみ）。

## 3. 非ゴール

- TypeScript 側で **unstable** と明記された API はバインドしない:
  - `Image.transformImage` (`Note the API signature is not stable and might change.`)
- 内部 deprecated / alias は対象外:
  - `Tray.setMenuOnLeftClick` (deprecated alias of `setShowMenuOnLeftClick`)
- `@tauri-apps/api` を超えるラッパー機能（独自エラー型、独自ヘルパ）は追加しない。
- プラグインパッケージ (`plugin-fs`, `plugin-dialog`, `schema`) は本作業のスコープ外。

## 4. 対象モジュールと未実装 API

### 4.1 Core (`Core.res` / `Core.resi`)

| 種別 | 識別子 | 用途 |
|---|---|---|
| const | `SERIALIZE_TO_IPC_FN` | カスタム IPC シリアライザの key |
| function | `transformCallback` | JS コールバックを backend で `eval` 可能な ID に変換 |
| class | `PluginListener` | `addPluginListener` / `onBackButtonPress` の戻り値 |
| function | `addPluginListener` | プラグイン側のイベント listen |
| type | `PermissionState` | `granted` / `denied` / `prompt` / `prompt-with-rationale` |
| function | `checkPermissions` | プラグイン権限取得 |
| function | `requestPermissions` | プラグイン権限要求 |
| class | `Resource` | リソースハンドル基底（`rid` / `close`） |
| function | `isTauri` | Tauri 環境判定 |

### 4.2 App (`App.res` / `App.resi`)

| 種別 | 識別子 | プラットフォーム |
|---|---|---|
| type | `DataStoreIdentifier` | macOS / iOS（16-byte UUID） |
| enum | `BundleType` | `Nsis` / `Msi` / `Deb` / `Rpm` / `AppImage` / `App` |
| function | `fetchDataStoreIdentifiers` | macOS / iOS |
| function | `removeDataStore` | macOS / iOS |
| function | `getBundleType` | 全 desktop |
| type | `OnBackButtonPressPayload` | `{ canGoBack: bool }` |
| function | `onBackButtonPress` | Android |
| function | `supportsMultipleWindows` | 全プラットフォーム |

### 4.3 Window (`Window.res` / `Window.resi`)

| 識別子 | 種別 |
|---|---|
| `activityName` | instance method |
| `sceneIdentifier` | instance method |
| `setFocusable` | instance method |
| `setSimpleFullscreen` | instance method |
| `toggleMaximize` | instance method |
| `unminimize` | instance method |
| `onDragDropEvent` | instance method (Webview と整合) |

### 4.4 Webview (`Webview.res` / `Webview.resi`)

| 識別子 | 種別 |
|---|---|
| `clearAllBrowsingData` | instance method |
| `getByLabel` | static |

### 4.5 Event (`Event.res` / `Event.resi`)

| 識別子 | 種別 |
|---|---|
| `TauriEvent` | enum（17 件の predefined event 名） |
| `Options.target` | listen / once の `~target` オプション |

### 4.6 Mocks (`Mocks.res` / `Mocks.resi`)

| 識別子 | 種別 |
|---|---|
| `mockConvertFileSrc` | function |
| `MockIPCOptions` | `mockIPC` 第 2 引数 (`shouldMockEvents`) |

### 4.7 Menu (`Menu.res` / `Menu.resi`)

| 識別子 | 種別 |
|---|---|
| `NativeIcon` | enum（macOS: 60 件強の system icon） |

## 5. 互換性方針

- 既存 API は **無破壊**: `App.resi` 冒頭の "deferred to Phase 2" コメントを更新し、現在カバー済みである旨を反映。
- `App.theme` 型（`Window.theme` の alias）は維持。
- `Core.invokeError` / `Command` / `Channel` モジュールはそのまま。
- `Mocks.mockIPC` の既存シグネチャは維持しつつ、第 2 引数のラベル付きオプションを **追加**（`~options=?`）。

## 6. テスト要件

- 型レベル: `packages/core/tests/` 内の各 `*_signature.res` に新規 API 呼び出しを追加し、コンパイル成功で型整合性を担保。
- ランタイム: `packages/core/tests/runtime/*.test.mjs` に vitest テスト追加。
  - Mocks: `mockConvertFileSrc` 直接検証
  - Core: `isTauri()` の偽値判定、`Resource` の `close` 呼び出し
  - App / Window / Webview: `mockIPC` 経由で IPC 呼び出しの cmd 名・引数形状を検証

## 7. リスク

- **モバイル限定 API**: `onBackButtonPress` 等は desktop で動作しないが、`mockIPC` で IPC コマンド名が呼ばれることを検証することで、バインディング自体の正当性を確認できる。
- **`transformCallback` / `SERIALIZE_TO_IPC_FN`**: 低レベル API のため誤用リスクあり。`Core.resi` 内のドキュメントコメントで internal-leaning である旨を明記する。

## 8. 完了条件

- 上記モジュール 7 つすべてに新規バインディング追加（合計 25 関数 + 6 型/列挙）。
- `pnpm --recursive build` 成功。
- `pnpm --recursive test` 全件 pass。
- `pnpm run check` warning なし。
- ドキュメント (`docs/repository-structure.md`, `README.md`, `sphinx-docs/dev/architecture.md` 該当部) 更新。
