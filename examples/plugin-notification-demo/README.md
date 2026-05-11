# plugin-notification demo

Minimal Tauri 2.x desktop app that exercises every public function
of [`@rescript-tauri/plugin-notification`](../../packages/plugin-notification).

## Run

```bash
pnpm install
pnpm --filter plugin-notification-demo tauri dev
```

On macOS / Linux, the OS may ask for notification permission the
first time you run **sendNotificationText** or **sendNotification**.

## Buttons

| Button | Calls |
|---|---|
| **isPermissionGranted** | `PluginNotification.isPermissionGranted` |
| **requestPermission** | `PluginNotification.requestPermission` |
| **sendNotificationText** | `PluginNotification.sendNotificationText("hello")` |
| **sendNotification (options, id=1)** | `PluginNotification.sendNotification({id, title, body})` |
| **pending** | `PluginNotification.pending` |
| **cancelAll** | `PluginNotification.cancelAll` |
| **active** | `PluginNotification.active` |
| **removeAllActive** | `PluginNotification.removeAllActive` |
| **registerActionTypes** | `PluginNotification.registerActionTypes(actionTypes)` |
| **createChannel / channels / removeChannel** | Android-only channel APIs (calls succeed but are no-ops on desktop) |
| **subscribe / detach onAction** | `PluginNotification.onAction` + `Core.PluginListener.unregister` |
| **subscribe / detach onNotificationReceived** | `PluginNotification.onNotificationReceived` + `Core.PluginListener.unregister` |

Type-only reachability covers `Schedule.{at, interval, every}`,
`Importance.{None, Min, Low, Default, High}`,
`Visibility.{Secret, Private, Public}`, the `cancel(array<int>)`
and `removeActive(array<removeActiveTarget>)` variants, and several
related record shapes (`actionType` / `pendingNotification` /
`activeNotification` / `attachment`).

## Capabilities

The demo uses `notification:default`. See
[`src-tauri/capabilities/default.json`](./src-tauri/capabilities/default.json).

## See also

- [plugin-notification user guide](../../sphinx-docs/user/plugin-notification.md)
- [`@rescript-tauri/plugin-notification` README](../../packages/plugin-notification/README.md)
- Upstream: [Tauri 2.x notification plugin](https://v2.tauri.app/plugin/notification/)
