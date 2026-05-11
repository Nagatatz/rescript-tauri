// Type-level signature test for PluginNotification.

let _check_perm_default: PluginNotification.notificationPermission = #default
let _check_perm_granted: PluginNotification.notificationPermission = #granted
let _check_perm_denied: PluginNotification.notificationPermission = #denied

let _check_attachment: PluginNotification.attachment = {id: "a", url: "asset://x"}

let _check_schedule_interval: PluginNotification.scheduleInterval = {
  hour: ?Some(9),
  minute: ?Some(0),
}

let _check_schedule_every_day: PluginNotification.scheduleEvery = #day
let _check_schedule_every_two_weeks: PluginNotification.scheduleEvery = #twoWeeks

let _check_schedule_at: (
  Date.t,
  ~repeating: bool=?,
  ~allowWhileIdle: bool=?,
) => PluginNotification.Schedule.t = PluginNotification.Schedule.at
let _check_schedule_interval_fn: (
  PluginNotification.scheduleInterval,
  ~allowWhileIdle: bool=?,
) => PluginNotification.Schedule.t = PluginNotification.Schedule.interval
let _check_schedule_every_fn: (
  PluginNotification.scheduleEvery,
  ~count: int,
  ~allowWhileIdle: bool=?,
) => PluginNotification.Schedule.t = PluginNotification.Schedule.every

let _check_importance_none: PluginNotification.Importance.t = PluginNotification.Importance.None
let _check_importance_min: PluginNotification.Importance.t = PluginNotification.Importance.Min
let _check_importance_low: PluginNotification.Importance.t = PluginNotification.Importance.Low
let _check_importance_default: PluginNotification.Importance.t = PluginNotification.Importance.Default
let _check_importance_high: PluginNotification.Importance.t = PluginNotification.Importance.High

let _check_visibility_secret: PluginNotification.Visibility.t = PluginNotification.Visibility.Secret
let _check_visibility_private: PluginNotification.Visibility.t = PluginNotification.Visibility.Private
let _check_visibility_public: PluginNotification.Visibility.t = PluginNotification.Visibility.Public

let _check_options: PluginNotification.options = {
  title: "hi",
}

let _check_action: PluginNotification.action = {id: "a", title: "Open"}

let _check_action_type: PluginNotification.actionType = {
  id: "tauri",
  actions: [],
}

let _check_pending: PluginNotification.pendingNotification = {
  id: 0,
  schedule: PluginNotification.Schedule.every(#hour, ~count=1),
}

let _check_active: PluginNotification.activeNotification = {
  id: 0,
  groupSummary: false,
  data: Dict.make(),
  extra: Dict.make(),
  attachments: [],
}

let _check_channel: PluginNotification.channel = {id: "c", name: "n"}

let _check_remove_active_target: PluginNotification.removeActiveTarget = {id: 1}

// Functions
let _check_is_permission_granted: unit => promise<bool> = PluginNotification.isPermissionGranted
let _check_request_permission: unit => promise<
  PluginNotification.notificationPermission,
> = PluginNotification.requestPermission
let _check_send_notification: PluginNotification.options => unit =
  PluginNotification.sendNotification
let _check_send_notification_text: string => unit = PluginNotification.sendNotificationText
let _check_register_action_types: array<PluginNotification.actionType> => promise<unit> =
  PluginNotification.registerActionTypes
let _check_pending_fn: unit => promise<array<PluginNotification.pendingNotification>> =
  PluginNotification.pending
let _check_cancel: array<int> => promise<unit> = PluginNotification.cancel
let _check_cancel_all: unit => promise<unit> = PluginNotification.cancelAll
let _check_active_fn: unit => promise<array<PluginNotification.activeNotification>> =
  PluginNotification.active
let _check_remove_active: array<PluginNotification.removeActiveTarget> => promise<unit> =
  PluginNotification.removeActive
let _check_remove_all_active: unit => promise<unit> = PluginNotification.removeAllActive
let _check_create_channel: PluginNotification.channel => promise<unit> =
  PluginNotification.createChannel
let _check_remove_channel: string => promise<unit> = PluginNotification.removeChannel
let _check_channels: unit => promise<array<PluginNotification.channel>> =
  PluginNotification.channels
let _check_on_notification_received: (
  PluginNotification.options => unit,
) => promise<RescriptTauriCore.Core.PluginListener.t> = PluginNotification.onNotificationReceived
let _check_on_action: (
  PluginNotification.options => unit,
) => promise<RescriptTauriCore.Core.PluginListener.t> = PluginNotification.onAction
