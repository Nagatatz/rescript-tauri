# Requirements: examples/plugin-notification-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-016 |
| 作業タイトル | examples/plugin-notification-demo |
| 作成日 | 2026-05-11 |
| 関連 steering | 002 (user guide), 054 (本体実装) |

---

## 1. 背景

`@rescript-tauri/plugin-notification` は本体実装・user guide・CHANGELOG・CI 完備、`examples/plugin-notification-demo/` のみ未存在。

## 2. 目的

plugin-notification の全公開 API を Tauri 2.x デスクトップアプリ上から呼び出せる demo を提供する。

## 3. スコープ

### 3.1 含めるもの

12 ボタン構成（実行系）+ 型レベル参照（Schedule / Importance / Visibility / actionType / pendingNotification / activeNotification 等）:

| ボタン | 関数 |
|---|---|
| Permission: check | `isPermissionGranted` |
| Permission: request | `requestPermission` |
| Send (text) | `sendNotificationText("hello")` |
| Send (options, id=1) | `sendNotification({id, title, body})` |
| List pending | `pending` |
| Cancel all pending | `cancelAll` |
| List active | `active` |
| Remove all active | `removeAllActive` |
| Register action types | `registerActionTypes` |
| Create test channel | `createChannel({id, name, ...})` |
| List channels | `channels` |
| Remove test channel | `removeChannel("test-channel")` |
| Subscribe onAction | `onAction(callback)` + 取得 `PluginListener.t` を memory に保持 |
| Detach onAction | `PluginListener.unregister` |
| Subscribe onNotificationReceived | `onNotificationReceived(callback)` |
| Detach onNotificationReceived | 同上 |

型レベル参照:
- `Schedule.at` / `Schedule.interval` / `Schedule.every`
- `Importance.{none, min, low, default_, high}`
- `Visibility.{secret, private_, public_}`
- `notificationPermission` polymorphic variant
- `scheduleEvery` / `scheduleInterval`
- `actionType` / `action`
- `pendingNotification` / `activeNotification`
- `attachment` / `removeActiveTarget`
- `cancel` 関数（cancelAll で代替可能だが reachability のため）
- `removeActive` 関数

共有ファイル更新:
- root `Cargo.toml`
- `docs/repository-structure.md` (§1 + §3)
- `sphinx-docs/user/plugin-notification.md` "See also"
- `packages/plugin-notification/CHANGELOG.md`
- `.github/workflows/examples-build.yml`

### 3.2 含めないもの

- 実 Android channel / iOS push 設定（permission 設定は capability で済む）
- npm publish 実行
- 翻訳 .po 更新

## 4. 受け入れ基準

- [ ] `examples/plugin-notification-demo/` が plugin-shell-demo 雛形と同じファイル構成
- [ ] `src/App.res` に全 16 関数 + Schedule / Importance / Visibility module への参照
- [ ] `capabilities/default.json` に `notification:default` permission
- [ ] root Cargo / docs / CI / CHANGELOG / user guide cross-link 確立
- [ ] `pnpm --filter plugin-notification-demo build` 成功
- [ ] tasklist 全タスク `[x]` で main merge 完了

## 5. リスク

- macOS で notification 表示には Info.plist や OS 設定が必要 — UI に "Permission required" を案内
- Android channel / iOS action は実機で確認できないため、call は通すが UI 観点では確認不可能
