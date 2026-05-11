# Design: sphinx-docs `user/plugin-notification.md`

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-002 |
| 関連 | requirements.md / steering 054 / `packages/plugin-notification/src/PluginNotification.resi` |

---

## 1. 出力ファイル

| ファイル | 状態 |
|---|---|
| `sphinx-docs/user/plugin-notification.md` | 新規作成 |
| `sphinx-docs/user/index.md` | 編集（Phase 2 packages テーブル / toctree） |

`sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-notification.po` は本ステアリングでは作成**しない**（後続 sub-steering）。

## 2. `plugin-notification.md` のセクション設計

各セクションの内容方針と参照ソースを明示する。実装時はこの順序で書く。

### 2.1 リード文

- `@rescript-tauri/plugin-notification` の役割を 1 段落で説明
- upstream の v2 公式リンク: `https://v2.tauri.app/plugin/notification/`
- npm 公開ステータスは `{note}` ブロックで明記（plugin-fs.md と同じ phrasing）

### 2.2 `{note}` ブロック

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-notification-v0.1.0`) is scheduled
alongside the other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-notification` via the source repository or
a workspace link.
```

### 2.3 Install

- `pnpm add @rescript-tauri/plugin-notification @tauri-apps/plugin-notification`
- `peerDependencies` 説明: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-notification ^2.3.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`
- `rescript.json` への追加 (`@rescript-tauri/core` と `@rescript-tauri/plugin-notification` を `dependencies` に列挙)
- Rust 側: `tauri-plugin-notification = "2"` を Cargo.toml に追加し、`tauri::Builder::default().plugin(tauri_plugin_notification::init())` を `src-tauri/src/main.rs` に追加

### 2.4 Capabilities

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "notification:default"
  ]
}
```

`notification:default` で `is_permission_granted` / `request_permission` / `notify` / `register_action_types` / `cancel` / `get_pending` / `remove_active` / `get_active` / `check_permissions` / `show_notification` / `batch` / `list_channels` / `delete_channel` / `create_channel` / `permission_state` をカバーする旨を一文で記載。

### 2.5 Permission flow

本プラグイン固有のセクション。ユーザに必ず提示すべきパターン:

```rescript
open RescriptTauriPluginNotification

let ensurePermission = async () => {
  let granted = await PluginNotification.isPermissionGranted()
  if granted {
    true
  } else {
    let perm = await PluginNotification.requestPermission()
    perm === #granted
  }
}
```

`notificationPermission` の polymorphic variant `[#default | #granted | #denied]` を簡単に説明。

### 2.6 Minimal example

```rescript
open RescriptTauriPluginNotification

let granted = await ensurePermission()
if granted {
  PluginNotification.sendNotificationText("Hello from rescript-tauri")
  PluginNotification.sendNotification({
    title: "TAURI",
    body: "ReScript bindings work",
  })
}
```

### 2.7 Public API テーブル

`packages/plugin-notification/README.md` の "Public API" 表をベースに sphinx-docs 向けに調整:

| Symbol | Purpose |
|---|---|
| `isPermissionGranted` / `requestPermission` | Permission queries |
| `sendNotification` / `sendNotificationText` | Show a notification (record / string form) |
| `registerActionTypes` | Declare tap-actions |
| `pending` / `cancel` / `cancelAll` | Pending (scheduled) notification management |
| `active` / `removeActive` / `removeAllActive` | Active (delivered) notification management |
| `createChannel` / `removeChannel` / `channels` | Android channel management |
| `onNotificationReceived` / `onAction` | Subscribe to events (returns `Core.PluginListener.t`) |
| `Schedule.at` / `Schedule.interval` / `Schedule.every` | Build a `Schedule.t` |
| `Importance.{none, min, low, default_, high}` | Android channel importance (numeric enum) |
| `Visibility.{secret, private_, public_}` | Android channel visibility (numeric enum) |
| `notificationPermission` | `[#default \| #granted \| #denied]` |

`options` / `attachment` / `action` / `actionType` / `pendingNotification` / `activeNotification` / `channel` / `scheduleInterval` / `scheduleEvery` / `removeActiveTarget` は record リストとして列挙し、詳細フィールドは upstream の `src/PluginNotification.resi` を参照させる。

### 2.8 Schedule helpers

3 つの factory を 1 つずつ短いコード例で紹介:

```rescript
// Fire once at a specific Date
let _ = PluginNotification.Schedule.at(Date.make(), ~allowWhileIdle=true)

// Fire whenever the wallclock matches every present field
let _ = PluginNotification.Schedule.interval({hour: 9, minute: 0})

// Fire every N units of a recurrence kind
let _ = PluginNotification.Schedule.every(#day, ~count=1)
```

`scheduleEvery` の polymorphic variant 一覧（`#year` / `#month` / `#twoWeeks` / `#week` / `#day` / `#hour` / `#minute` / `#second`）と iOS の `#second` 非対応を 1 行で注記。

### 2.9 Pitfalls

3 つのサブセクションを設ける（plugin-fs.md と同じスタイル）:

1. **Split `sendNotification` overload** — upstream の `sendNotification(options: Options | string)` を 2 関数に分けた理由（ReScript 側では union 直接表現ができない / 静的型を優先）。
2. **Numeric enum constants** — `Importance.default_` / `Visibility.private_` / `Visibility.public_` の suffix が JS 出力の `$$` エスケープを避けるためであること、対応する upstream の数値 (`none=0`/`min=1`/`low=2`/`default=3`/`high=4`、`secret=-1`/`private=0`/`public=1`) を提示。
3. **Web API path, not IPC** — `requestPermission` / `sendNotification` / `sendNotificationText` が upstream で IPC ではなく `window.Notification` を経由する件。`Mocks.mockIPC` ではテストできず、`globalThis.window.Notification` を stub する必要があることに触れる（実装側 README と同等の説明）。

### 2.10 Compatibility テーブル

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-notification` | `^2.3.0` (peer) |
| Rust `tauri-plugin-notification` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows / iOS / Android |

iOS / Android を含めて 5 OS であることを明示（plugin-fs / plugin-dialog はデスクトップ 3 OS だが、notification は mobile 込み）。

### 2.11 See also

- Source: `https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-notification`
- Upstream docs: `https://v2.tauri.app/plugin/notification/`
- Upstream JS reference: `https://v2.tauri.app/reference/javascript/notification/`

`examples/plugin-notification-demo` のリンクは未存在のため**追加しない**（後続 sub-steering で追加）。

## 3. `index.md` の編集方針

### 3.1 Phase 2 packages テーブルに 1 行追加

```markdown
| `@rescript-tauri/plugin-notification` | Native notifications (toast / schedule / channels) | [plugin-notification](plugin-notification.md) |
```

挿入位置: 既存テーブルの末尾（`@rescript-tauri/schema` の前 or 後）。Phase 2 plugin を schema より上に並べる方が読者の理解が直線的なので、`plugin-dialog` の直後に挿入する。

### 3.2 `toctree` directive に追加

```
plugin-notification
```

挿入位置: `plugin-dialog` の直後 / `schema` の前。並列 steering `20260511-001` が `plugin-shell` を追加している可能性があるため、マージ時に最新 main を取り込んでから配置を最終調整する。

### 3.3 並列セッションとの衝突回避

- worktree 作成前に `git fetch origin && git log --oneline origin/main..HEAD` で main の鮮度確認（pre-flight-verification.md §必須検証ケース）
- worktree 内で commit したあと、マージ直前にもう一度 `git fetch origin && git log --oneline HEAD..origin/main` で衝突可能性を確認
- `index.md` で plugin-shell が先にマージされていた場合、本 steering の編集は plugin-notification 行のみを `plugin-shell` の後ろに追加する

## 4. テスト戦略

ドキュメント追加のみで実行可能なテストは無い。以下を手動で確認する:

1. **Markdown 構造**: `plugin-fs.md` / `plugin-dialog.md` と同じセクションが揃っていること
2. **API シンボル整合性**: 文中で言及する関数・型がすべて `packages/plugin-notification/src/PluginNotification.resi` に実在すること（grep で検証）
3. **リンク先**: upstream リンクが `https://v2.tauri.app/` ドメインで 404 にならない形式であること（パス手入力なので目視で十分。CI の `doc-link-lint` が後で確認する）
4. **`index.md` の整合性**: Phase 2 packages テーブルと toctree の両方に `plugin-notification` が含まれていること

## 5. 完了条件

requirements §5 の受け入れ基準すべてを満たすこと。
