# `@rescript-tauri/plugin-notification`

ReScript bindings for the [Tauri 2.x notification
plugin](https://v2.tauri.app/plugin/notification/) — toast
notifications, scheduling, channels, and tap-action types. The
100% stable public surface of `@tauri-apps/plugin-notification`
v2.3.x is covered.

```{note}
{{ phase_2_note }}
```

## Install

```bash
pnpm add @rescript-tauri/plugin-notification @tauri-apps/plugin-notification
```

`@rescript-tauri/plugin-notification` declares both
`@rescript-tauri/core` and `@tauri-apps/plugin-notification` as
`peerDependencies`, so you control each upstream version.

Add the package to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-notification"
  ]
}
```

On the Rust side, add the plugin crate and register it on the
builder:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-notification = "2"
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_notification::init())
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

## Capabilities

Tauri 2.x requires every plugin permission to be granted
explicitly. The minimal set for notifications is:

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

`notification:default` covers every notification API surfaced by
this binding (permission queries, sending, scheduling, action
type registration, pending / active management, and Android
channel management).

## Permission flow

Most platforms require the user to grant notification permission
before delivery succeeds. Always gate `sendNotification` calls
behind a permission check:

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

`requestPermission` returns a polymorphic variant
`[#default | #granted | #denied]` (`notificationPermission`).
`#default` represents the "not yet decided" state on platforms
that distinguish it from `#denied`.

## Minimal example

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

## Public API

All 15 notification functions are exposed under `PluginNotification`,
together with the `Schedule` factory module and the numeric-enum
modules `Importance` / `Visibility`:

| Symbol | Purpose |
|---|---|
| `isPermissionGranted` / `requestPermission` | Permission queries |
| `sendNotification` / `sendNotificationText` | Show a notification (record / string form) |
| `registerActionTypes` | Declare tap-actions referenced by `options.actionTypeId` |
| `pending` / `cancel` / `cancelAll` | Pending (scheduled) notification management |
| `active` / `removeActive` / `removeAllActive` | Active (delivered) notification management |
| `createChannel` / `removeChannel` / `channels` | Android channel management |
| `onNotificationReceived` / `onAction` | Subscribe to delivery / tap events (returns `Core.PluginListener.t`) |
| `Schedule.at` / `Schedule.interval` / `Schedule.every` | Build a `Schedule.t` for `options.schedule` |
| `Importance.{None, Min, Low, Default, High}` | `@unboxed` variant: Android channel importance (`@as(0..4)`) |
| `Visibility.{Secret, Private, Public}` | `@unboxed` variant: Android channel visibility (`@as(-1..1)`) |
| `notificationPermission` | `[#default \| #granted \| #denied]` |

The associated record and variant types — `options`,
`attachment`, `action`, `actionType`, `pendingNotification`,
`activeNotification`, `channel`, `scheduleInterval`,
`scheduleEvery`, and `removeActiveTarget` — are all re-exported
from `PluginNotification`. Per-field doc comments and upstream
URLs live in `packages/plugin-notification/src/PluginNotification.resi`.

## Schedule helpers

`Schedule.t` is an opaque type built through three factories:

```rescript
// Fire once at a specific Date
let _ = PluginNotification.Schedule.at(Date.make(), ~allowWhileIdle=true)

// Fire whenever every present field of the interval matches
let _ = PluginNotification.Schedule.interval({hour: 9, minute: 0})

// Fire every N units of a recurrence kind
let _ = PluginNotification.Schedule.every(#day, ~count=1)
```

The recurrence kinds accepted by `Schedule.every` are
`#year`, `#month`, `#twoWeeks`, `#week`, `#day`, `#hour`,
`#minute`, and `#second`. `#second` is **not** supported on iOS
upstream — see [Schedule.every reference](https://v2.tauri.app/reference/javascript/notification/#scheduleevery).

`scheduleInterval` follows upstream's `1=Sunday … 7=Saturday`
convention for the `weekday` field.

## Pitfalls

### Split `sendNotification` overload

Upstream's TypeScript signature is:

```typescript
sendNotification(options: Options | string): void
```

ReScript can't express the `Options | string` union without
phantom types or runtime branching. The binding splits the
overload into two functions whose argument types are pinned:

```rescript
PluginNotification.sendNotificationText("Hello")         // string form
PluginNotification.sendNotification({title: "Hi"})       // record form
```

### `Importance` / `Visibility` variants

`Importance.t` and `Visibility.t` are `@unboxed` variants with
`@as(N)` annotations — wire-compatible with the upstream numeric
enum at runtime, but exhaustively pattern-matchable in ReScript:

```rescript
let importance: PluginNotification.Importance.t = Default  // @as(3)
let visibility: PluginNotification.Visibility.t = Private  // @as(0)
```

| Module | Constructors | Wire values |
|---|---|---|
| `Importance` | `None` / `Min` / `Low` / `Default` / `High` | `0 / 1 / 2 / 3 / 4` |
| `Visibility` | `Secret` / `Private` / `Public` | `-1 / 0 / 1` |

Pattern-match for branching:

```rescript
switch channel.importance {
| Some(High) => /* loud */
| Some(Low) | Some(Min) | Some(None) => /* quiet */
| _ => /* default */
}
```

### Web API path, not IPC

`isPermissionGranted`, `requestPermission`, `sendNotification`,
and `sendNotificationText` are dispatched by upstream through the
DOM `window.Notification` Web API rather than Tauri IPC. The
practical consequences:

- `Mocks.mockIPC` cannot intercept these calls. Runtime tests
  stub `globalThis.window.Notification` (and
  `Notification.requestPermission`) directly — see the package's
  `tests/runtime/plugin_notification.test.mjs`.
- `core:default` is not sufficient on its own; the plugin's
  `notification:default` permission must also be granted so the
  Tauri capability layer allows the Web API call.

The remaining functions (`pending`, `cancel`, `active`,
`registerActionTypes`, channel APIs, `onNotificationReceived`,
`onAction`, …) go through the regular Tauri IPC and are
exercisable from `Mocks.mockIPC`.

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-notification` | `^2.3.0` (peer) |
| Rust `tauri-plugin-notification` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows / iOS / Android |

## See also

- Live demo:
  [`examples/plugin-notification-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-notification-demo)
- Source:
  [`packages/plugin-notification`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-notification)
- Upstream docs:
  [Tauri 2.x notification plugin](https://v2.tauri.app/plugin/notification/)
- Upstream JS reference:
  [notification module](https://v2.tauri.app/reference/javascript/notification/)
