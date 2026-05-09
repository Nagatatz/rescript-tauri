# @rescript-tauri/plugin-notification

ReScript bindings for [`@tauri-apps/plugin-notification`](https://www.npmjs.com/package/@tauri-apps/plugin-notification)
— Tauri 2.x's native notification plugin (toast notifications,
scheduling, channels, action types).

## Status

Phase 2+, first iteration. Awaiting first npm publish (`plugin-notification-v0.1.0`).

**Bundled in this iteration:** 100% of the stable public surface of
`@tauri-apps/plugin-notification` v2.3.3 — 15 functions, 8 record
types, 1 polymorphic variant, plus the `Schedule` factory module and
numeric-enum modules `Importance` / `Visibility`.

The upstream `sendNotification(options: Options | string)` overload
is unrolled into two ReScript functions (`sendNotification` for the
record form, `sendNotificationText` for the simple string form).

## Install (planned)

```bash
pnpm add @rescript-tauri/plugin-notification @rescript-tauri/core @tauri-apps/plugin-notification @tauri-apps/api
```

Add to `rescript.json`:

```json
{
  "dependencies": ["@rescript/core", "@rescript-tauri/core", "@rescript-tauri/plugin-notification"]
}
```

## Quick example

```rescript
module N = RescriptTauriPluginNotification.PluginNotification

let notify = async () => {
  let granted = await N.isPermissionGranted()
  let granted = if !granted {
    let perm = await N.requestPermission()
    perm === #granted
  } else {
    true
  }

  if granted {
    N.sendNotificationText("Tauri is awesome!")
    N.sendNotification({title: "TAURI", body: "Hello from ReScript"})
  }
}

let scheduleDaily = () => {
  let _ = N.sendNotification({
    title: "Daily reminder",
    body: "Drink water",
    schedule: N.Schedule.every(#day, ~count=1),
  })
}
```

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-notification` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-notification` | `^2.3.0` (peer) |
| `@tauri-apps/api` | `^2.0.0` (transitive via core) |
| Rust `tauri-plugin-notification` | `2.x` |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows / iOS / Android |

## Public API

| Symbol | Purpose |
|---|---|
| `isPermissionGranted` / `requestPermission` | Notification permission queries |
| `sendNotification` / `sendNotificationText` | Show a notification (record / simple-string forms) |
| `registerActionTypes` | Declare tap-actions for notifications |
| `pending` / `cancel` / `cancelAll` | Pending (scheduled) notification management |
| `active` / `removeActive` / `removeAllActive` | Active (delivered) notification management |
| `createChannel` / `removeChannel` / `channels` | Notification channel management (Android) |
| `onNotificationReceived` / `onAction` | Subscribe to notification / action events (returns `Core.PluginListener.t`) |
| `Schedule.at` / `Schedule.interval` / `Schedule.every` | Build a `Schedule.t` for `options.schedule` |
| `Importance.{none, min, low, default_, high}` | Android channel importance levels (numeric enum) |
| `Visibility.{secret, private_, public_}` | Android channel visibility levels (numeric enum) |
| `notificationPermission` | `[#default \| #granted \| #denied]` |
| `options` / `attachment` / `action` / `actionType` / `pendingNotification` / `activeNotification` / `channel` / `scheduleInterval` / `scheduleEvery` / `removeActiveTarget` | Records and variants matching the upstream interfaces |

See `src/PluginNotification.resi` for full doc comments and matching
upstream URLs.

## See also

- [Changelog](./CHANGELOG.md)
- Upstream docs:
  [Tauri 2.x notification plugin](https://v2.tauri.app/plugin/notification/)
- [`@rescript-tauri/core` README](../core/README.md)
