// Type-level signature test for Core extras (Resource / PluginListener /
// addPluginListener / permissionState / checkPermissions / requestPermissions
// / isTauri / LowLevel).

let _check_is_tauri: unit => bool = Core.isTauri

let _check_resource_rid: Core.Resource.t => int = Core.Resource.rid
let _check_resource_close: Core.Resource.t => promise<unit> = Core.Resource.close

let _check_plugin_listener_plugin: Core.PluginListener.t => string = Core.PluginListener.plugin
let _check_plugin_listener_event: Core.PluginListener.t => string = Core.PluginListener.event
let _check_plugin_listener_channel_id: Core.PluginListener.t => int = Core.PluginListener.channelId
let _check_plugin_listener_unregister: Core.PluginListener.t => promise<unit> =
  Core.PluginListener.unregister

let _check_add_plugin_listener: (
  string,
  string,
  'payload => unit,
) => promise<Core.PluginListener.t> = Core.addPluginListener

let _check_permission_granted: Core.permissionState = #granted
let _check_permission_denied: Core.permissionState = #denied
let _check_permission_prompt: Core.permissionState = #prompt
let _check_permission_prompt_with_rationale: Core.permissionState = #"prompt-with-rationale"

let _check_check_permissions: string => promise<'state> = Core.checkPermissions
let _check_request_permissions: string => promise<'state> = Core.requestPermissions

let _check_low_level_serialize_to_ipc_fn: string = Core.LowLevel.serializeToIpcFn
let _check_low_level_transform_callback: (
  ~callback: 'response => unit=?,
  ~once: bool=?,
) => int = Core.LowLevel.transformCallback
