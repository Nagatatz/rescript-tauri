// Type-level signature test for PluginOs.

let _check_platform_linux: PluginOs.platform = #linux
let _check_platform_macos: PluginOs.platform = #macos
let _check_platform_windows: PluginOs.platform = #windows

let _check_os_type_macos: PluginOs.osType = #macos

let _check_arch_x86_64: PluginOs.arch = #x86_64
let _check_arch_aarch64: PluginOs.arch = #aarch64

let _check_family_unix: PluginOs.family = #unix
let _check_family_windows: PluginOs.family = #windows

let _check_eol: unit => string = PluginOs.eol
let _check_platform_fn: unit => PluginOs.platform = PluginOs.platform
let _check_version: unit => string = PluginOs.version
let _check_family_fn: unit => PluginOs.family = PluginOs.family
let _check_os_type_fn: unit => PluginOs.osType = PluginOs.osType_
let _check_arch_fn: unit => PluginOs.arch = PluginOs.arch
let _check_exe_extension: unit => string = PluginOs.exeExtension
let _check_locale: unit => promise<Nullable.t<string>> = PluginOs.locale
let _check_hostname: unit => promise<Nullable.t<string>> = PluginOs.hostname
