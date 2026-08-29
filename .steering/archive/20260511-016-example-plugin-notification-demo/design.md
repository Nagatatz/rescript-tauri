# Design: examples/plugin-notification-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-016 |
| 関連 | `requirements.md`, `packages/plugin-notification/src/PluginNotification.resi`, `examples/plugin-shell-demo/` |

---

## 1. アプローチ

`plugin-shell-demo` を雛形に、`src/App.res` のロジックを plugin-notification 用に差し替え。

## 2. ファイル構成

`plugin-shell-demo` と同型。9 ファイル + icons/。

## 3. src/App.res 骨子

```rescript
open RescriptTauriPluginNotification
open RescriptTauriCore

@val external document: 'a = "document"

let setResult / appendResult / safe / ... (plugin-log-demo と同パターン)

// PluginListener handles
let actionListener: ref<option<Core.PluginListener.t>> = ref(None)
let receivedListener: ref<option<Core.PluginListener.t>> = ref(None)

let runIsPermissionGranted = async () => {
  let g = await PluginNotification.isPermissionGranted()
  appendResult("isPermissionGranted: " ++ Bool.toString(g))
}

let runRequestPermission = async () => {
  let p = await PluginNotification.requestPermission()
  let s = switch p {
    | #default => "default"
    | #granted => "granted"
    | #denied => "denied"
  }
  appendResult("requestPermission: " ++ s)
}

let runSendText = async () => {
  PluginNotification.sendNotificationText("hello from rescript-tauri")
  appendResult("sent text notification")
}

let runSendOptions = async () => {
  PluginNotification.sendNotification({
    id: 1,
    title: "rescript-tauri demo",
    body: "this is a notification via sendNotification(options)",
  })
  appendResult("sent options notification id=1")
}

let runPending = async () => {
  let xs = await PluginNotification.pending()
  appendResult("pending: " ++ Int.toString(Array.length(xs)))
}

let runCancelAll = async () => {
  await PluginNotification.cancelAll()
  appendResult("cancelAll ok")
}

let runActive = async () => {
  let xs = await PluginNotification.active()
  appendResult("active: " ++ Int.toString(Array.length(xs)))
}

let runRemoveAllActive = async () => {
  await PluginNotification.removeAllActive()
  appendResult("removeAllActive ok")
}

let runRegisterActions = async () => {
  await PluginNotification.registerActionTypes([
    {
      id: "demo-actions",
      actions: [
        {id: "reply", title: "Reply", input: true},
        {id: "dismiss", title: "Dismiss", destructive: true},
      ],
    },
  ])
  appendResult("registerActionTypes ok")
}

let runCreateChannel = async () => {
  await PluginNotification.createChannel({
    id: "test-channel",
    name: "Test Channel",
    importance: PluginNotification.Importance.default_,
    visibility: PluginNotification.Visibility.public_,
  })
  appendResult("createChannel test-channel")
}

let runListChannels = async () => {
  let xs = await PluginNotification.channels()
  appendResult("channels: " ++ Int.toString(Array.length(xs)))
}

let runRemoveChannel = async () => {
  await PluginNotification.removeChannel("test-channel")
  appendResult("removeChannel test-channel")
}

let runSubscribeAction = async () => {
  let listener = await PluginNotification.onAction(opts => {
    appendResult("onAction received id=" ++ Int.toString(opts.id->Option.getOr(-1)))
  })
  actionListener := Some(listener)
  appendResult("subscribed onAction")
}

let runDetachAction = async () => {
  switch actionListener.contents {
  | Some(l) => {
    await Core.PluginListener.unregister(l)
    actionListener := None
    appendResult("detached onAction")
  }
  | None => appendResult("onAction not subscribed")
  }
}

let runSubscribeReceived = async () => {
  let listener = await PluginNotification.onNotificationReceived(opts => {
    appendResult("onNotificationReceived: " ++ opts.title)
  })
  receivedListener := Some(listener)
  appendResult("subscribed onNotificationReceived")
}

let runDetachReceived = async () => {
  switch receivedListener.contents {
  | Some(l) => {
    await Core.PluginListener.unregister(l)
    receivedListener := None
    appendResult("detached onNotificationReceived")
  }
  | None => appendResult("onNotificationReceived not subscribed")
  }
}

// Type-only reachability:

let _demoScheduleAt: PluginNotification.Schedule.t =
  PluginNotification.Schedule.at(Date.make())
let _demoScheduleInterval: PluginNotification.Schedule.t =
  PluginNotification.Schedule.interval({hour: 9})
let _demoScheduleEvery: PluginNotification.Schedule.t =
  PluginNotification.Schedule.every(#day, ~count=1)

let _demoImportance = [
  PluginNotification.Importance.none,
  PluginNotification.Importance.min,
  PluginNotification.Importance.low,
  PluginNotification.Importance.default_,
  PluginNotification.Importance.high,
]
let _demoVisibility = [
  PluginNotification.Visibility.secret,
  PluginNotification.Visibility.private_,
  PluginNotification.Visibility.public_,
]

let _demoCancelById = async () => {
  // Demonstrates `cancel(array<int>)` exists; cancelAll button is
  // wired instead for ergonomics.
  await PluginNotification.cancel([1, 2, 3])
}

let _demoRemoveActiveById: array<PluginNotification.removeActiveTarget> => promise<unit> =
  PluginNotification.removeActive
```

### Notes on `channel` shape

```rescript
type channel = {
  id: string,
  name: string,
  importance: int,
  visibility: int,
  // ... 他の Android-only fields
}
```

実装時に `.resi` を再確認して record の全 required field を埋める。

## 4. capabilities/default.json

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for the plugin-notification demo",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "notification:default"
  ]
}
```

## 5. src-tauri/Cargo.toml

```toml
[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-notification = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

## 6. src-tauri/src/main.rs

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_notification::init())
        .run(tauri::generate_context!())
        .expect("error while running plugin-notification-demo");
}
```

## 7. tauri.conf.json

`productName: "rescript-tauri-plugin-notification-demo"`、`identifier: "com.rescript-tauri.example.plugin-notification-demo"`、title `"plugin-notification demo"`。

## 8. 共有ファイル

- `Cargo.toml`: members に追加
- `docs/repository-structure.md` §1 + §3
- `sphinx-docs/user/plugin-notification.md` "See also"
- `packages/plugin-notification/CHANGELOG.md` `Added` 追記 + `Deferred` 削除
- `.github/workflows/examples-build.yml` の plugin-log-demo の隣に 2 step
