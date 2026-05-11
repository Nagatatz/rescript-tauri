/** Bindings for `@tauri-apps/plugin-notification` (Tauri 2.x
    notification plugin).

    Phase 2+ first iteration: 100% coverage of the stable public
    surface of `@tauri-apps/plugin-notification` v2.3.3 — toast
    notifications, scheduling, channels, action types.

    The upstream `sendNotification(options: Options | string)`
    overload is unrolled into two ReScript functions
    (`sendNotification` for the record form, `sendNotificationText`
    for the simple string form).

    See: https://v2.tauri.app/plugin/notification/
*/

/** Permission state returned by `requestPermission`. Mirrors the DOM
    `NotificationPermission` type.

    See: https://v2.tauri.app/reference/javascript/notification/#notificationpermission
*/
type notificationPermission = [#default | #granted | #denied]

/** Notification attachment.

    See: https://v2.tauri.app/reference/javascript/notification/#attachment
*/
type attachment = {
  /** Attachment identifier. */
  id: string,
  /** Attachment URL — accepts `asset://` and `file://` schemes. */
  url: string,
}

/** Calendar-based recurring schedule. All fields are optional; the
    notification fires when every present field matches the wallclock.

    `weekday` follows the upstream convention: 1=Sunday, 2=Monday,
    ..., 7=Saturday.

    See: https://v2.tauri.app/reference/javascript/notification/#scheduleinterval
*/
type scheduleInterval = {
  year?: int,
  month?: int,
  day?: int,
  weekday?: int,
  hour?: int,
  minute?: int,
  second?: int,
}

/** Coarse-grained recurrence kinds for `Schedule.every`. `#second` is
    not supported on iOS upstream.

    See: https://v2.tauri.app/reference/javascript/notification/#scheduleevery
*/
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

/** Schedule factory. Construct via `at` / `interval` / `every`.

    See: https://v2.tauri.app/reference/javascript/notification/#schedule
*/
module Schedule: {
  /** Opaque `Schedule` instance. Pass to `options.schedule`. */
  type t

  /** Fires once at the given `Date`. `~repeating=true` keeps it
      recurring on the same calendar interval; `~allowWhileIdle=true`
      lets the OS deliver during low-power / Doze states (Android). */
  let at: (Date.t, ~repeating: bool=?, ~allowWhileIdle: bool=?) => t

  /** Fires whenever every present field of `interval` matches the
      wallclock. */
  let interval: (scheduleInterval, ~allowWhileIdle: bool=?) => t

  /** Fires every `count` units of `kind` (e.g. every 2 days). */
  let every: (scheduleEvery, ~count: int, ~allowWhileIdle: bool=?) => t
}

/** Android channel importance. Matches the upstream numeric enum
    `none=0` / `min=1` / `low=2` / `default=3` / `high=4`.

    The variant is `@unboxed` with per-constructor `@as(N)` so its
    runtime representation is the bare integer — wire-compatible with
    the upstream `channel.importance` field.

    See: https://v2.tauri.app/reference/javascript/notification/#importance
*/
module Importance: {
  @unboxed
  type t =
    | @as(0) None
    | @as(1) Min
    | @as(2) Low
    | @as(3) Default
    | @as(4) High
}

/** Android channel visibility. Matches the upstream numeric enum
    `secret=-1` / `private=0` / `public=1`.

    The variant is `@unboxed` with per-constructor `@as(N)` so its
    runtime representation is the bare integer — wire-compatible with
    the upstream `channel.visibility` / `options.visibility` fields.

    See: https://v2.tauri.app/reference/javascript/notification/#visibility
*/
module Visibility: {
  @unboxed
  type t =
    | @as(-1) Secret
    | @as(0) Private
    | @as(1) Public
}

/** Options for `sendNotification`. `title` is the only required
    field; all others are optional and platform-specific. See the
    upstream documentation for per-field details and platform
    coverage.

    See: https://v2.tauri.app/reference/javascript/notification/#options
*/
type options = {
  /** 32-bit identifier; assign one to reference the notification
      later via `cancel` / `removeActive`. */
  id?: int,
  /** Android channel to deliver through; the channel must exist. */
  channelId?: string,
  /** Notification title (required). */
  title: string,
  /** Notification body. */
  body?: string,
  /** Schedule the notification for a future time / interval. */
  schedule?: Schedule.t,
  /** Multiline text — switches Android style to "big text". Cannot
      be combined with `inboxLines`. */
  largeBody?: string,
  /** Summary text for the `largeBody` / `inboxLines` /
      `groupSummary` styles. */
  summary?: string,
  /** Identifier of the registered action type for tap actions. */
  actionTypeId?: string,
  /** Group identifier — multiple notifications with the same
      `group` are visually grouped. */
  group?: string,
  /** On Android, marks this notification as the summary of its
      `group`. */
  groupSummary?: bool,
  /** OS-dependent sound name or path. */
  sound?: string,
  /** List of lines for the Android "inbox" style (max 5). Cannot be
      combined with `largeBody`. */
  inboxLines?: array<string>,
  /** Notification icon. On Android the icon must live under
      `res/drawable`. */
  icon?: string,
  /** Android-only large icon. */
  largeIcon?: string,
  /** Android icon tint color. */
  iconColor?: string,
  /** Notification attachments. */
  attachments?: array<attachment>,
  /** Arbitrary JSON payload stored alongside the notification. */
  extra?: Dict.t<JSON.t>,
  /** Android: prevent the user from dismissing this notification. */
  ongoing?: bool,
  /** Auto-cancel the notification when the user taps it. */
  autoCancel?: bool,
  /** iOS: deliver silently (no badge / sound, no list entry). */
  silent?: bool,
  /** Channel visibility (use `Visibility.{Secret, Private, Public}`). */
  visibility?: Visibility.t,
  /** Android: number of items represented by this notification. */
  number?: int,
}

/** A tap-action attached to a notification action type.

    See: https://v2.tauri.app/reference/javascript/notification/#action
*/
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

/** A registered action type (group of actions).

    See: https://v2.tauri.app/reference/javascript/notification/#actiontype
*/
type actionType = {
  id: string,
  actions: array<action>,
  hiddenPreviewsBodyPlaceholder?: string,
  customDismissAction?: bool,
  allowInCarPlay?: bool,
  hiddenPreviewsShowTitle?: bool,
  hiddenPreviewsShowSubtitle?: bool,
}

/** A pending (scheduled, not yet delivered) notification.

    See: https://v2.tauri.app/reference/javascript/notification/#pendingnotification
*/
type pendingNotification = {
  id: int,
  title?: string,
  body?: string,
  schedule: Schedule.t,
}

/** A currently active (delivered, not yet dismissed) notification.

    See: https://v2.tauri.app/reference/javascript/notification/#activenotification
*/
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

/** Android notification channel.

    See: https://v2.tauri.app/reference/javascript/notification/#channel
*/
type channel = {
  id: string,
  name: string,
  description?: string,
  sound?: string,
  lights?: bool,
  lightColor?: string,
  vibration?: bool,
  importance?: Importance.t,
  visibility?: Visibility.t,
}

/** Argument to `removeActive` — identifies one active notification
    by id, optionally narrowed by `tag`. */
type removeActiveTarget = {id: int, tag?: string}

/** Returns whether the user has granted notification permission.

    See: https://v2.tauri.app/reference/javascript/notification/#ispermissiongranted
*/
let isPermissionGranted: unit => promise<bool>

/** Requests notification permission from the user. Backed by the
    DOM `Notification.requestPermission()` Web API rather than IPC.

    See: https://v2.tauri.app/reference/javascript/notification/#requestpermission
*/
let requestPermission: unit => promise<notificationPermission>

/** Sends a notification described by an `options` record. Backed
    by `new window.Notification(...)` (Web API), not IPC.

    See: https://v2.tauri.app/reference/javascript/notification/#sendnotification
*/
let sendNotification: options => unit

/** Sends a notification with just a title string. Convenience for
    the upstream overload that accepts a plain string. Backed by
    `new window.Notification(text)`.

    See: https://v2.tauri.app/reference/javascript/notification/#sendnotification
*/
let sendNotificationText: string => unit

/** Registers tap-action types referenced by `options.actionTypeId`.

    See: https://v2.tauri.app/reference/javascript/notification/#registeractiontypes
*/
let registerActionTypes: array<actionType> => promise<unit>

/** Returns the list of pending (scheduled) notifications.

    See: https://v2.tauri.app/reference/javascript/notification/#pending
*/
let pending: unit => promise<array<pendingNotification>>

/** Cancels the pending notifications with the given ids.

    See: https://v2.tauri.app/reference/javascript/notification/#cancel
*/
let cancel: array<int> => promise<unit>

/** Cancels every pending notification.

    See: https://v2.tauri.app/reference/javascript/notification/#cancelall
*/
let cancelAll: unit => promise<unit>

/** Returns the list of currently active (delivered) notifications.

    See: https://v2.tauri.app/reference/javascript/notification/#active
*/
let active: unit => promise<array<activeNotification>>

/** Removes the active notifications matching the given (id, tag?)
    targets.

    See: https://v2.tauri.app/reference/javascript/notification/#removeactive
*/
let removeActive: array<removeActiveTarget> => promise<unit>

/** Removes every active notification.

    See: https://v2.tauri.app/reference/javascript/notification/#removeallactive
*/
let removeAllActive: unit => promise<unit>

/** Creates an Android notification channel.

    See: https://v2.tauri.app/reference/javascript/notification/#createchannel
*/
let createChannel: channel => promise<unit>

/** Removes the channel with the given id.

    See: https://v2.tauri.app/reference/javascript/notification/#removechannel
*/
let removeChannel: string => promise<unit>

/** Returns the list of registered notification channels.

    See: https://v2.tauri.app/reference/javascript/notification/#channels
*/
let channels: unit => promise<array<channel>>

/** Subscribes to incoming notifications. Returns a
    `RescriptTauriCore.Core.PluginListener.t` — call `unregister` to stop.

    See: https://v2.tauri.app/reference/javascript/notification/#onnotificationreceived
*/
let onNotificationReceived: (options => unit) => promise<RescriptTauriCore.Core.PluginListener.t>

/** Subscribes to action-tap events.

    See: https://v2.tauri.app/reference/javascript/notification/#onaction
*/
let onAction: (options => unit) => promise<RescriptTauriCore.Core.PluginListener.t>
