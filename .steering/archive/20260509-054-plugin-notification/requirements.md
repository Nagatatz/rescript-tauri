# 要件定義: `@rescript-tauri/plugin-notification` 新規パッケージ

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-054-plugin-notification` |
| 作成日 | 2026-05-09 |
| 関連 | `docs/product-requirements.md` §284, `docs/repository-structure.md` §2.2, steering 049 (Core.PluginListener) |

## 1. 背景

未バインドの公式 Tauri プラグイン群を規模順（大→小）に bind するシリーズの **1 件目**。

`@tauri-apps/plugin-notification` は OS のトースト通知機能を Tauri アプリから利用するためのプラグインで、未バインド plugin の中で最大規模（462 行 / 19 export）。スコープ:

- 通知の送信 / スケジューリング
- パーミッション管理
- 通知チャンネル（Android）
- アクションタイプ（タップ時の振る舞い）
- 受信 / アクションのリスナー登録

## 2. ゴール

- `@tauri-apps/plugin-notification` v2.3.3 の **stable public surface 100%** をカバーする `@rescript-tauri/plugin-notification` 独立パッケージを `packages/plugin-notification/` に新設する。
- 既存の `plugin-fs` / `plugin-dialog` / `plugin-shell` と同じスタイルで実装する。
- 型レベルテストとランタイム vitest テストを各シンボルに用意する。
- 専用 CI ワークフローを 2 件追加し、`tests-coverage.yml` matrix と `release.yml` のタグ prefix を更新する。

## 3. 非ゴール

- 後続 sub-steering へ分離: `examples/plugin-notification-demo/` 例題、sphinx-docs `user/plugin-notification.md`。
- upstream で deprecated / unstable 表記された API はバインドしない（現時点では該当なし）。

## 4. 対象 API

### 4.1 関数 (15)

| 識別子 | TypeScript シグネチャ | ReScript 表現 |
|---|---|---|
| `isPermissionGranted` | `() => Promise<boolean>` | 同 |
| `requestPermission` | `() => Promise<NotificationPermission>` | DOM `NotificationPermission` を `[#default \| #granted \| #denied]` polymorphic variant に |
| `sendNotification` | `(options: Options \| string) => void` | **2 関数に分割**: `sendNotification: options => unit` / `sendNotificationText: string => unit` |
| `registerActionTypes` | `(types: ActionType[]) => Promise<void>` | 同 |
| `pending` | `() => Promise<PendingNotification[]>` | 同 |
| `cancel` | `(notifications: number[]) => Promise<void>` | `cancel: array<int> => promise<unit>` |
| `cancelAll` | `() => Promise<void>` | 同 |
| `active` | `() => Promise<ActiveNotification[]>` | 同 |
| `removeActive` | `(notifications: Array<{id, tag?}>) => Promise<void>` | inline 匿名 record を `removeActiveTarget = {id: int, tag?: string}` に明名化 |
| `removeAllActive` | `() => Promise<void>` | 同 |
| `createChannel` | `(channel: Channel) => Promise<void>` | 同 |
| `removeChannel` | `(id: string) => Promise<void>` | 同 |
| `channels` | `() => Promise<Channel[]>` | 同 |
| `onNotificationReceived` | `(cb) => Promise<PluginListener>` | 戻り値型は `Core.PluginListener.t` を使用 |
| `onAction` | `(cb) => Promise<PluginListener>` | 同 |

### 4.2 型 / インターフェース (8)

| 識別子 | 表現 |
|---|---|
| `Options` | record（20+ フィールド、ほぼ全 optional） |
| `Attachment` | `{id: string, url: string}` |
| `Action` | record |
| `ActionType` | record |
| `PendingNotification` | record |
| `ActiveNotification` | record |
| `Channel` | record |
| `ScheduleInterval` | record |

### 4.3 Enum (3)

| 識別子 | 種別 | ReScript 表現 |
|---|---|---|
| `ScheduleEvery` | string enum | polymorphic variant `[#year \| #month \| #twoWeeks \| #week \| #day \| #hour \| #minute \| #second]` |
| `Importance` | numeric enum (0..4) | `int` 定数モジュール `Importance.{none, min, low, default, high}` (各 `int`) |
| `Visibility` | numeric enum (-1..1) | `int` 定数モジュール `Visibility.{secret, private_, public}` |

`Importance` / `Visibility` は数値 enum なので、polymorphic variant ではなく `int` の named constant 群として公開する（`@as` を使った enum エミュレーションは upstream の数値値とのラウンドトリップで誤差が生じうる）。

### 4.4 `Schedule` クラス

```ts
class Schedule {
  at: {date, repeating, allowWhileIdle} | undefined
  interval: {interval, allowWhileIdle} | undefined
  every: {interval, count, allowWhileIdle} | undefined
  static at(date: Date, repeating?: boolean, allowWhileIdle?: boolean): Schedule
  static interval(interval: ScheduleInterval, allowWhileIdle?: boolean): Schedule
  static every(kind: ScheduleEvery, count: number, allowWhileIdle?: boolean): Schedule
}
```

ReScript では `Schedule` モジュール + 不透明型 `t`:

```rescript
module Schedule: {
  type t

  let at: (Date.t, ~repeating: bool=?, ~allowWhileIdle: bool=?) => t
  let interval: (scheduleInterval, ~allowWhileIdle: bool=?) => t
  let every: (scheduleEvery, ~count: int, ~allowWhileIdle: bool=?) => t
}
```

3 つの mutually-exclusive プロパティ（`at` / `interval` / `every`）はファクトリ関数経由で構築するため、accessor は提供しない（不要なら `Obj.magic` で抜け出せる、それで十分）。

### 4.5 PermissionState 再 export

upstream: `export type { PermissionState } from '@tauri-apps/api/core'`

ReScript 側では `Core.permissionState` がすでに steering 049 で公開済みのため、本パッケージでは **再 export しない**（呼び出し側で `Core.permissionState` を直接参照する）。

## 5. パッケージ構成

```
packages/plugin-notification/
├── src/
│   └── PluginNotification.res / .resi
├── tests/
│   ├── plugin_notification_signature.res
│   └── runtime/
│       └── plugin_notification.test.mjs
├── package.json
├── rescript.json
├── vitest.config.mjs
├── README.md
└── CHANGELOG.md
```

`peerDependencies`:
```json
{
  "@rescript-tauri/core": "^0.1.0",
  "@tauri-apps/plugin-notification": "^2.3.0",
  "rescript": ">=12.0.0",
  "@rescript/core": ">=1.6.0"
}
```

## 6. テスト要件

- **型レベル**: `plugin_notification_signature.res` に全 19 公開シンボルへの型注釈付き呼び出しを記述（19 + 8 型 = 27 程度の `_check_*` 行）。
- **ランタイム**: `Mocks.mockIPC` 経由で各関数の IPC コマンド名（`plugin:notification|*`）を検証。

## 7. CI

- `.github/workflows/tests-plugin-notification-types.yml`
- `.github/workflows/tests-plugin-notification-runtime.yml`
- `tests-coverage.yml` matrix に `plugin-notification` 追加
- `release.yml` のタグ prefix に `plugin-notification-v*` 追加

## 8. リスク

- **数値 enum (`Importance` / `Visibility`)**: ReScript で numeric enum を polymorphic variant にすると JS-side との等価性が失われる。`int` named constants で公開し、upstream の数値値 (0..4 / -1..1) を保証する。
- **`Schedule` クラスの mutability**: upstream は class instance を作って渡す形式。`Schedule.at(date)` / `Schedule.interval(...)` / `Schedule.every(...)` は内部で `new Schedule()` 相当を生成。`@new` または upstream の static factory を `@scope("Schedule")` で呼び出す。
- **`Options` の巨大さ**: 20+ optional フィールド。すべて `?:` で表現できるため問題なし。

## 9. 完了条件

- 上記 API 群すべての binding 追加（合計約 **15 関数 + 8 型 + 3 enum + 1 class モジュール**）。
- `pnpm --workspace-concurrency 1 --recursive build` 成功。
- `pnpm --workspace-concurrency 1 --recursive test` 全件 pass（既存 161 件 + plugin-notification 新規分）。
- 専用 CI ジョブ 2 件追加 + `tests-coverage.yml` matrix + `release.yml` 更新。
- `docs/repository-structure.md` §1 / §2.2 に plugin-notification 追記、root README の Packages 表に行追加。
