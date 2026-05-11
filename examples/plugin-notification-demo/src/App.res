// rescript-tauri plugin-notification example.
//
// Wires every public function of @rescript-tauri/plugin-notification
// to a button so the full surface (permissions / send / pending /
// active / actions / channels / listeners) can be exercised inside
// a real Tauri 2.x desktop app.

open RescriptTauriPluginNotification
open RescriptTauriCore

@val external document: 'a = "document"

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

let appendResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  let current = el["textContent"]
  let next = current === "(no action yet)" ? text : current ++ "\n" ++ text
  el["textContent"] = next
}

let safe = (label: string, body: unit => promise<unit>): unit => {
  let _ =
    body()->Promise.catch(err => {
      Console.error2(label, err)
      let serialized =
        err->Obj.magic->JSON.stringifyAny->Option.getOr("(non-serializable)")
      appendResult(label ++ " failed: " ++ serialized)
      Promise.resolve()
    })
}

// PluginListener handles for the live subscriptions.
let actionListener: ref<option<Core.PluginListener.t>> = ref(None)
let receivedListener: ref<option<Core.PluginListener.t>> = ref(None)

// ----- Permission -----

let runIsPermissionGranted = async () => {
  let g = await PluginNotification.isPermissionGranted()
  appendResult("isPermissionGranted: " ++ (g ? "true" : "false"))
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

// ----- Send -----

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

// ----- Pending / Active -----

let runPending = async () => {
  let xs = await PluginNotification.pending()
  appendResult("pending: " ++ Int.toString(Array.length(xs)) ++ " entries")
}

let runCancelAll = async () => {
  await PluginNotification.cancelAll()
  appendResult("cancelAll ok")
}

let runActive = async () => {
  let xs = await PluginNotification.active()
  appendResult("active: " ++ Int.toString(Array.length(xs)) ++ " entries")
}

let runRemoveAllActive = async () => {
  await PluginNotification.removeAllActive()
  appendResult("removeAllActive ok")
}

// ----- Action types -----

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
  appendResult("registerActionTypes ok (demo-actions: reply / dismiss)")
}

// ----- Channels (Android-only, no-op on desktop) -----

let runCreateChannel = async () => {
  await PluginNotification.createChannel({
    id: "test-channel",
    name: "Test Channel",
    importance: PluginNotification.Importance.default_,
    visibility: PluginNotification.Visibility.public_,
  })
  appendResult("createChannel test-channel ok (Android-only)")
}

let runListChannels = async () => {
  let xs = await PluginNotification.channels()
  appendResult("channels: " ++ Int.toString(Array.length(xs)) ++ " entries")
}

let runRemoveChannel = async () => {
  await PluginNotification.removeChannel("test-channel")
  appendResult("removeChannel test-channel ok")
}

// ----- Listeners -----

let runSubscribeAction = async () => {
  let listener = await PluginNotification.onAction(opts => {
    let id = opts.id->Option.getOr(-1)
    appendResult("onAction received id=" ++ Int.toString(id) ++ ": " ++ opts.title)
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

// ----- Type-only reachability -----

let _demoScheduleAt: PluginNotification.Schedule.t =
  PluginNotification.Schedule.at(Date.make())
let _demoScheduleInterval: PluginNotification.Schedule.t =
  PluginNotification.Schedule.interval({hour: 9})
let _demoScheduleEvery: PluginNotification.Schedule.t =
  PluginNotification.Schedule.every(#day, ~count=1)

let _demoImportance: array<int> = [
  PluginNotification.Importance.none,
  PluginNotification.Importance.min,
  PluginNotification.Importance.low,
  PluginNotification.Importance.default_,
  PluginNotification.Importance.high,
]

let _demoVisibility: array<int> = [
  PluginNotification.Visibility.secret,
  PluginNotification.Visibility.private_,
  PluginNotification.Visibility.public_,
]

// `cancel(array<int>)` exists alongside `cancelAll` — the demo UI
// uses cancelAll for ergonomics, this binding keeps the typed handle
// reachable for readers.
let _demoCancelByIds: array<int> => promise<unit> = PluginNotification.cancel
let _demoRemoveActiveByIds: array<PluginNotification.removeActiveTarget> => promise<unit> =
  PluginNotification.removeActive

let _demoAttachment: PluginNotification.attachment = {
  id: "demo-attachment",
  url: "asset://demo.png",
}

// ----- Wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-check-permission", runIsPermissionGranted)
  bind("btn-request-permission", runRequestPermission)
  bind("btn-send-text", runSendText)
  bind("btn-send-options", runSendOptions)
  bind("btn-pending", runPending)
  bind("btn-cancel-all", runCancelAll)
  bind("btn-active", runActive)
  bind("btn-remove-all-active", runRemoveAllActive)
  bind("btn-register-actions", runRegisterActions)
  bind("btn-create-channel", runCreateChannel)
  bind("btn-list-channels", runListChannels)
  bind("btn-remove-channel", runRemoveChannel)
  bind("btn-subscribe-action", runSubscribeAction)
  bind("btn-detach-action", runDetachAction)
  bind("btn-subscribe-received", runSubscribeReceived)
  bind("btn-detach-received", runDetachReceived)
}

main()
