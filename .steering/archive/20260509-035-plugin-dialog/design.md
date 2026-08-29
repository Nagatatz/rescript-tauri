# Design: @rescript-tauri/plugin-dialog パッケージ実装

| 項目 | 内容 |
|---|---|
| 関連 | [requirements.md](./requirements.md), `.steering/20260509-032-plugin-fs/` (パッケージ雛形パターン) |

## 1. ファイル配置

```
packages/plugin-dialog/
├── src/
│   ├── PluginDialog.res                  # 実装本体
│   └── PluginDialog.resi                 # 公開シグネチャ
├── tests/
│   ├── plugin_dialog_signature.res       # 型レベル網羅
│   └── runtime/
│       └── plugin_dialog.test.mjs        # vitest + Mocks 経由
├── package.json                          # @rescript-tauri/plugin-dialog
├── rescript.json
├── vitest.config.mjs
└── README.md

docs/
└── repository-structure.md               # §2.2 に plugin-dialog セクション追記
```

## 2. 公開 API

### 2.1 関数（7）

| 関数 | シグネチャ | upstream |
|---|---|---|
| `openFile` | `(~options: openOptions=?) => promise<Nullable.t<string>>` | `open({multiple: false, directory: false})` |
| `openFiles` | `(~options: openOptions=?) => promise<Nullable.t<array<string>>>` | `open({multiple: true, directory: false})` |
| `openDirectory` | `(~options: openOptions=?) => promise<Nullable.t<string>>` | `open({multiple: false, directory: true})` |
| `openDirectories` | `(~options: openOptions=?) => promise<Nullable.t<array<string>>>` | `open({multiple: true, directory: true})` |
| `save` | `(~options: saveOptions=?) => promise<Nullable.t<string>>` | `save` |
| `message` | `(string, ~options: messageOptions=?) => promise<messageResult>` | `message` |
| `ask` | `(string, ~options: confirmOptions=?) => promise<bool>` | `ask` |
| `confirm` | `(string, ~options: confirmOptions=?) => promise<bool>` | `confirm` |

合計 8 関数（`open` 系 4 + `save` + `message`/`ask`/`confirm` の 3）。

### 2.2 型

- `dialogFilter = {name: string, extensions: array<string>}`
- `pickerMode = [#document | #media | #image | #video]`（mobile 用）
- `fileAccessMode = [#copy | #scoped]`（iOS 用）
- `dialogKind = [#info | #warning | #error]`
- `messageButtons = [#Ok | #OkCancel | #YesNo | #YesNoCancel]`
- `messageResult = string`
- `openOptions` / `saveOptions` / `messageOptions` / `confirmOptions` — record 型

## 3. 主要設計判断

### 3.1 `open` の 4 関数分割

upstream の `open(options)` は TypeScript の条件型で戻り値が変わる:

```ts
open<T extends OpenDialogOptions>(opts: T): Promise<
  T['multiple'] extends true ? string[] | null : string | null
>
```

ReScript には条件型がないため、`multiple` × `directory` の 4 通りを 4 つの公開関数に分割し、戻り値型を静的に決定する。`openOptions` には `multiple` / `directory` を含めず、関数名で表現する。

### 3.2 `_open` external + `_toJsOpen` ヘルパ

実装は単一の private external `_open: _openOptionsJs => promise<Nullable.t<'a>>` と、`openOptions + multiple + directory` を `_openOptionsJs` に詰め直す `_toJsOpen` ヘルパで構成。各公開関数は `multiple` / `directory` を hard-coded で渡し、戻り値型のみアノテートする。

### 3.3 `message` overload を採用しない

upstream `message(msg, string | options)` の string-as-title overload は ReScript の型システム上 unsafe（unboxed union）になるため採用しない。タイトル指定は常に `~options.title` 経由。

### 3.4 `messageResult = string`

upstream の戻り値型は `'Yes' | 'No' | 'Ok' | 'Cancel' | string` ユニオンだが、ReScript の variant 化は (a) custom-button label を `#Custom(string)` で抱える必要がある、(b) 標準 4 ボタンも variant 化すると pattern match が冗長、というデメリットがある。本 steering ではシンプルに `string` で公開し、呼び出し側で文字列比較する設計。

### 3.5 `messageButtons` variant

デフォルト 4 ボタンレイアウト (`Ok` / `OkCancel` / `YesNo` / `YesNoCancel`) のみ variant で公開。カスタム文言の `MessageDialogButtonsYesNoCustom` 系は upstream で record 形式（`{kind: ..., yesLabel: ..., noLabel: ...}`）になっているため、Phase 2 後期で再評価。

### 3.6 vitest 環境

`@rescript-tauri/core` / `schema` / `plugin-fs` と同じく `happy-dom`。`Mocks.mockIPC` / `Mocks.clearMocks` で `__TAURI_INTERNALS__.invoke` を差し替える。

### 3.7 peerDependencies

| Peer | 範囲 |
|---|---|
| `@rescript-tauri/core` | `^0.1.0` |
| `@tauri-apps/plugin-dialog` | `^2.7.0` (v2.7.1 が確認時点の最新) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |

## 4. テストカバレッジ

### 4.1 型レベル

`tests/plugin_dialog_signature.res`:
- 8 関数 × `_check_*`
- 4 variant 値の存在確認 (`pickerMode` / `fileAccessMode` / `dialogKind` / `messageButtons`)

### 4.2 runtime（9 ケース）

- `openFile` で IPC が `plugin:dialog|open` を `multiple: false, directory: false` で受ける
- `openFiles` で `multiple: true, directory: false`
- `openDirectory` で `multiple: false, directory: true`
- `openDirectories` で `multiple: true, directory: true`
- ユーザーキャンセル時に `Nullable.null` を返す
- `openFile` のオプション透過（`title` / `defaultPath` / `filters`）
- `save` で `plugin:dialog|save` を呼ぶ
- `message` の戻り値が string で得られる
- `ask` / `confirm` は upstream 内部で `plugin:dialog|message` を経由する（`bool` 比較）

## 5. 後続スコープ（本 steering 外）

| 項目 | 想定 sub-steering |
|---|---|
| `MessageDialogButtonsYesNoCustom` / `OkCancel` / `Ok` カスタム文言 | `2026MMDD-NNN-plugin-dialog-custom-buttons` |
| examples / 専用 CI ジョブ | `2026MMDD-NNN-plugin-dialog-example` |
| npm publish (`plugin-dialog-v0.1.0`) | Phase 2 release-checklist |

## 6. CI 影響

- core / schema / plugin-fs 既存ジョブには影響なし（path filter で plugin-dialog を拾わない）
- 当面は `pnpm --recursive build / test` で plugin-dialog もカバーされる
- 専用 CI / `release.yml` の `plugin-dialog-v*` タグサポートは別 sub-steering

## 7. リスク

| リスク | 兆候 | 対策 |
|---|---|---|
| upstream `@tauri-apps/plugin-dialog` v3 の API drift | upstream major | peerDep 範囲を `^2.7.0` に絞る、互換 CI で先行検知 |
| `messageResult` の variant 化を後で要望される | ユーザーが string 比較を嫌がる | `string` から `messageResult` private newtype への将来拡張余地を残す（型エイリアスのまま） |
| `open` のオプション形状が headers 形式へ変更 | upstream minor で内部実装変更 | テストは cmd 名と options 内の `multiple` / `directory` のみ assert |
