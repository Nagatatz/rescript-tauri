# Steering 035: @rescript-tauri/plugin-dialog パッケージ実装

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | .steering/20260509-030-phase2-planning, .steering/20260509-032-plugin-fs |
| ブランチ | `worktree-phase2-plugin-dialog` |

## 背景

Phase 2 計画 (steering 030) の Must スコープのうち最後の項目。upstream `@tauri-apps/plugin-dialog` v2.7.x の OS ネイティブダイアログ API (open / save / message / ask / confirm) をバインディングする。

## 要求

### A. パッケージ bootstrap

`packages/plugin-dialog/` を schema / plugin-fs と同じ構造で:

- `package.json` — `@rescript-tauri/plugin-dialog`, peerDeps
- `rescript.json`, `vitest.config.mjs`
- `src/PluginDialog.res` / `.resi`
- `tests/plugin_dialog_signature.res`
- `tests/runtime/plugin_dialog.test.mjs`
- `README.md`

### B. 公開 API

#### B.1 ファイル選択ダイアログ

upstream の `open(options)` は TypeScript 条件型で戻り値が変わる (single vs multiple, file vs directory)。ReScript にはないので **4 関数に分割** する:

```rescript
let openFile: (~options: openOptions=?) => promise<Nullable.t<string>>
let openFiles: (~options: openOptions=?) => promise<Nullable.t<array<string>>>
let openDirectory: (~options: openOptions=?) => promise<Nullable.t<string>>
let openDirectories: (~options: openOptions=?) => promise<Nullable.t<array<string>>>
```

`openOptions` は `multiple` / `directory` を含めない（関数名で表現）。各関数の内部で `multiple` / `directory` を upstream に渡す。

#### B.2 保存ダイアログ

```rescript
let save: (~options: saveOptions=?) => promise<Nullable.t<string>>
```

#### B.3 メッセージ系

```rescript
let message: (string, ~options: messageOptions=?) => promise<messageResult>
let ask: (string, ~options: confirmOptions=?) => promise<bool>
let confirm: (string, ~options: confirmOptions=?) => promise<bool>
```

upstream の `message(msg, string | options)` の string-as-title overload は採用しない（ReScript 側では options.title で指定）。

### C. 型定義

- `dialogFilter` — `{name, extensions: array<string>}`
- `pickerMode = [#document | #media | #image | #video]`（mobile 用）
- `fileAccessMode = [#copy | #scoped]`（iOS 用）
- `dialogKind = [#info | #warning | #error]`
- `messageButtonsKind` — variant
- `messageResult = string`（upstream は `'Yes' | 'No' | 'Ok' | 'Cancel' | string`、シンプルに string で公開）
- `openOptions` / `saveOptions` / `messageOptions` / `confirmOptions` — record 型

### D. テスト

- 型レベル: 全公開シンボルを `_check_*` で参照
- runtime（happy-dom + Mocks）:
  - `openFile` で IPC が呼ばれ、`multiple: false, directory: false` を渡す
  - `openFiles` で `multiple: true, directory: false`
  - `openDirectory` で `multiple: false, directory: true`
  - `save` で IPC が呼ばれる
  - `message` / `ask` / `confirm` の戻り値型が正しく推論できる

### E. 互換マトリクス

| `@rescript-tauri/plugin-dialog` | `@rescript-tauri/core` | `@tauri-apps/plugin-dialog` | `@tauri-apps/api` |
|---|---|---|---|
| `^0.1.0` | `^0.1.0` | `^2.7.0` | `^2.0.0` |

## Non-goals

- `message` の string-as-title overload（unsafe API）
- `MessageDialogButtonsYesNoCancel` / `OkCancel` / `Ok` カスタム文言の variant（Phase 2 後期で再評価。本 steering ではデフォルト 4 種のみサポート）
- npm publish（Phase 2 release-checklist で実施）
- examples / 専用 CI 追加（別 sub-steering）

## 受け入れ条件

- [x] `packages/plugin-dialog/` 雛形 + 全ファイル
- [x] 7 関数 + 関連 record / variant 型公開
- [x] `pnpm --filter @rescript-tauri/plugin-dialog build` 緑
- [x] `pnpm --filter @rescript-tauri/plugin-dialog test` 緑
- [x] core / schema / plugin-fs に regression なし
- [x] `docs/repository-structure.md` 更新
