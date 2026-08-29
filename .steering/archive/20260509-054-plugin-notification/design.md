# 設計: `@rescript-tauri/plugin-notification` 新規パッケージ

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-054-plugin-notification` |
| 作成日 | 2026-05-09 |
| 関連 | `requirements.md` |

## 1. 全体構造

`packages/plugin-notification/src/PluginNotification.res` 内に:

- トップレベル: 8 個の record 型 + 1 polymorphic variant + 15 関数
- `Schedule` モジュール（type + 3 static factory）
- `Importance` モジュール（5 個の int 定数）
- `Visibility` モジュール（3 個の int 定数）

## 2. 型定義

```rescript
type notificationPermission = [#default | #granted | #denied]

type attachment = {
  id: string,
  url: string,
}

type scheduleInterval = {
  year?: int,
  month?: int,
  day?: int,
  weekday?: int,
  hour?: int,
  minute?: int,
  second?: int,
}

type scheduleEvery = [
  | #year
  | #month
  | #twoWeeks
  | #week
  | #day
  | #hour
  | #minute
  | #second
]

type options = {
  id?: int,
  channelId?: string,
  title: string,
  body?: string,
  schedule?: Schedule.t,
  largeBody?: string,
  summary?: string,
  actionTypeId?: string,
  group?: string,
  groupSummary?: bool,
  sound?: string,
  inboxLines?: array<string>,
  icon?: string,
  largeIcon?: string,
  iconColor?: string,
  attachments?: array<attachment>,
  extra?: Dict.t<JSON.t>,
  ongoing?: bool,
  autoCancel?: bool,
  silent?: bool,
  visibility?: int,
  number?: int,
}

type action = {
  id: string,
  title: string,
  requiresAuthentication?: bool,
  foreground?: bool,
  destructive?: bool,
  input?: bool,
  inputButtonTitle?: string,
  inputPlaceholder?: string,
}

type actionType = {
  id: string,
  actions: array<action>,
  hiddenPreviewsBodyPlaceholder?: string,
  customDismissAction?: bool,
  allowInCarPlay?: bool,
  hiddenPreviewsShowTitle?: bool,
  hiddenPreviewsShowSubtitle?: bool,
}

type pendingNotification = {
  id: int,
  title?: string,
  body?: string,
  schedule: Schedule.t,
}

type activeNotification = {
  id: int,
  tag?: string,
  title?: string,
  body?: string,
  group?: string,
  groupSummary: bool,
  data: Dict.t<string>,
  extra: Dict.t<JSON.t>,
  attachments: array<attachment>,
  actionTypeId?: string,
  schedule?: Schedule.t,
  sound?: string,
}

type channel = {
  id: string,
  name: string,
  description?: string,
  sound?: string,
  lights?: bool,
  lightColor?: string,
  vibration?: bool,
  importance?: int,
  visibility?: int,
}

type removeActiveTarget = {id: int, tag?: string}
```

注: `options.schedule` / `pendingNotification.schedule` / `activeNotification.schedule` は前方参照 (`Schedule.t`) を使うため、宣言順序: `Schedule` モジュール → 残りの型。

## 3. `Schedule` モジュール

```rescript
module Schedule = {
  type t

  @scope("Schedule") @module("@tauri-apps/plugin-notification")
  external at: (Date.t, ~repeating: bool=?, ~allowWhileIdle: bool=?) => t = "at"

  @scope("Schedule") @module("@tauri-apps/plugin-notification")
  external interval: (scheduleInterval, ~allowWhileIdle: bool=?) => t = "interval"

  @scope("Schedule") @module("@tauri-apps/plugin-notification")
  external every: (scheduleEvery, ~count: int, ~allowWhileIdle: bool=?) => t = "every"
}
```

呼び出しパターン:
- `Schedule.at(Date.make())` → `Schedule.at(new Date())` 同等
- `Schedule.every(#day, ~count=2)` → `Schedule.every("day", 2)` 同等

## 4. `Importance` / `Visibility` モジュール

```rescript
module Importance = {
  let none: int = 0
  let min: int = 1
  let low: int = 2
  let default: int = 3
  let high: int = 4
}

module Visibility = {
  let secret: int = -1
  let private_: int = 0
  let public: int = 1
}
```

`private` は ReScript 予約語のため `private_` を使用。

## 5. 関数バインディング

```rescript
@module("@tauri-apps/plugin-notification")
external isPermissionGranted: unit => promise<bool> = "isPermissionGranted"

@module("@tauri-apps/plugin-notification")
external requestPermission: unit => promise<notificationPermission> = "requestPermission"

@module("@tauri-apps/plugin-notification")
external sendNotification: options => unit = "sendNotification"

@module("@tauri-apps/plugin-notification")
external sendNotificationText: string => unit = "sendNotification"

@module("@tauri-apps/plugin-notification")
external registerActionTypes: array<actionType> => promise<unit> = "registerActionTypes"

@module("@tauri-apps/plugin-notification")
external pending: unit => promise<array<pendingNotification>> = "pending"

@module("@tauri-apps/plugin-notification")
external cancel: array<int> => promise<unit> = "cancel"

@module("@tauri-apps/plugin-notification")
external cancelAll: unit => promise<unit> = "cancelAll"

@module("@tauri-apps/plugin-notification")
external active: unit => promise<array<activeNotification>> = "active"

@module("@tauri-apps/plugin-notification")
external removeActive: array<removeActiveTarget> => promise<unit> = "removeActive"

@module("@tauri-apps/plugin-notification")
external removeAllActive: unit => promise<unit> = "removeAllActive"

@module("@tauri-apps/plugin-notification")
external createChannel: channel => promise<unit> = "createChannel"

@module("@tauri-apps/plugin-notification")
external removeChannel: string => promise<unit> = "removeChannel"

@module("@tauri-apps/plugin-notification")
external channels: unit => promise<array<channel>> = "channels"

@module("@tauri-apps/plugin-notification")
external onNotificationReceived: (
  options => unit,
) => promise<Core.PluginListener.t> = "onNotificationReceived"

@module("@tauri-apps/plugin-notification")
external onAction: (options => unit) => promise<Core.PluginListener.t> = "onAction"
```

## 6. テスト戦略

### 6.1 型レベル (`plugin_notification_signature.res`)

各 export を型注釈付きで参照する `_check_*` 行。約 27 行。

### 6.2 ランタイム (`plugin_notification.test.mjs`)

`Mocks.mockIPC` で IPC コマンド名を検証:
- `plugin:notification|is_permission_granted`
- `plugin:notification|request_permission`
- `plugin:notification|notify`（sendNotification）
- `plugin:notification|register_action_types`
- `plugin:notification|get_pending`（pending）
- `plugin:notification|cancel`
- `plugin:notification|cancel_all`
- `plugin:notification|get_active`（active）
- `plugin:notification|remove_active`
- `plugin:notification|remove_all_active`
- `plugin:notification|create_channel`
- `plugin:notification|delete_channel`（removeChannel）
- `plugin:notification|listChannels`（channels）

実コマンド名は upstream の `index.js` を読んで確定する。

## 7. パッケージ設定

`plugin-shell` を雛形として:

- `package.json`: name / description / peer / devDeps を notification 用に置換
- `rescript.json`: name のみ変更
- `vitest.config.mjs`: そのまま
- `README.md` / `CHANGELOG.md`: notification 用に書き起こし

## 8. CI 設定

`.github/workflows/`:
- `tests-plugin-notification-types.yml`（plugin-shell コピー）
- `tests-plugin-notification-runtime.yml`（同）
- `tests-coverage.yml` matrix に追加
- `release.yml` の tag prefix と case に追加

## 9. ドキュメント更新

- `README.md` (root) の Packages 表に行追加
- `docs/repository-structure.md` §1 ルートツリー + §2.2 plugin-notification セクション

## 10. 影響範囲

- 新設: `packages/plugin-notification/`
- 編集: `tests-coverage.yml`, `release.yml`
- 新設: 2 ファイル `.github/workflows/tests-plugin-notification-{types,runtime}.yml`
- 編集: `README.md`, `docs/repository-structure.md`

他パッケージに変更なし。
