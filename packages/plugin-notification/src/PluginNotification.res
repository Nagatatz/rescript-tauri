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

module Schedule = {
  type t

  @scope("Schedule") @module("@tauri-apps/plugin-notification")
  external at: (Date.t, ~repeating: bool=?, ~allowWhileIdle: bool=?) => t = "at"

  @scope("Schedule") @module("@tauri-apps/plugin-notification")
  external interval: (scheduleInterval, ~allowWhileIdle: bool=?) => t = "interval"

  @scope("Schedule") @module("@tauri-apps/plugin-notification")
  external every: (scheduleEvery, ~count: int, ~allowWhileIdle: bool=?) => t = "every"
}

module Importance = {
  let none: int = 0
  let min: int = 1
  let low: int = 2
  let default_: int = 3
  let high: int = 4
}

module Visibility = {
  let secret: int = -1
  let private_: int = 0
  let public_: int = 1
}

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
) => promise<RescriptTauriCore.Core.PluginListener.t> = "onNotificationReceived"

@module("@tauri-apps/plugin-notification")
external onAction: (options => unit) => promise<RescriptTauriCore.Core.PluginListener.t> = "onAction"
