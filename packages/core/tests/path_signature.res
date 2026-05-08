// Type-level signature test for Path.

let _check_base_audio: Path.BaseDirectory.t = Path.BaseDirectory.audio
let _check_base_cache: Path.BaseDirectory.t = Path.BaseDirectory.cache
let _check_base_config: Path.BaseDirectory.t = Path.BaseDirectory.config
let _check_base_data: Path.BaseDirectory.t = Path.BaseDirectory.data
let _check_base_local_data: Path.BaseDirectory.t = Path.BaseDirectory.localData
let _check_base_document: Path.BaseDirectory.t = Path.BaseDirectory.document
let _check_base_download: Path.BaseDirectory.t = Path.BaseDirectory.download
let _check_base_picture: Path.BaseDirectory.t = Path.BaseDirectory.picture
let _check_base_public: Path.BaseDirectory.t = Path.BaseDirectory.public
let _check_base_video: Path.BaseDirectory.t = Path.BaseDirectory.video
let _check_base_resource: Path.BaseDirectory.t = Path.BaseDirectory.resource
let _check_base_temp: Path.BaseDirectory.t = Path.BaseDirectory.temp
let _check_base_app_config: Path.BaseDirectory.t = Path.BaseDirectory.appConfig
let _check_base_app_data: Path.BaseDirectory.t = Path.BaseDirectory.appData
let _check_base_app_local_data: Path.BaseDirectory.t = Path.BaseDirectory.appLocalData
let _check_base_app_cache: Path.BaseDirectory.t = Path.BaseDirectory.appCache
let _check_base_app_log: Path.BaseDirectory.t = Path.BaseDirectory.appLog
let _check_base_desktop: Path.BaseDirectory.t = Path.BaseDirectory.desktop
let _check_base_executable: Path.BaseDirectory.t = Path.BaseDirectory.executable
let _check_base_font: Path.BaseDirectory.t = Path.BaseDirectory.font
let _check_base_home: Path.BaseDirectory.t = Path.BaseDirectory.home
let _check_base_runtime: Path.BaseDirectory.t = Path.BaseDirectory.runtime
let _check_base_template: Path.BaseDirectory.t = Path.BaseDirectory.template

let _check_app_config_dir: unit => promise<string> = Path.appConfigDir
let _check_app_data_dir: unit => promise<string> = Path.appDataDir
let _check_app_local_data_dir: unit => promise<string> = Path.appLocalDataDir
let _check_app_cache_dir: unit => promise<string> = Path.appCacheDir
let _check_app_log_dir: unit => promise<string> = Path.appLogDir
let _check_audio_dir: unit => promise<string> = Path.audioDir
let _check_cache_dir: unit => promise<string> = Path.cacheDir
let _check_config_dir: unit => promise<string> = Path.configDir
let _check_data_dir: unit => promise<string> = Path.dataDir
let _check_local_data_dir: unit => promise<string> = Path.localDataDir
let _check_desktop_dir: unit => promise<string> = Path.desktopDir
let _check_document_dir: unit => promise<string> = Path.documentDir
let _check_download_dir: unit => promise<string> = Path.downloadDir
let _check_executable_dir: unit => promise<string> = Path.executableDir
let _check_font_dir: unit => promise<string> = Path.fontDir
let _check_home_dir: unit => promise<string> = Path.homeDir
let _check_picture_dir: unit => promise<string> = Path.pictureDir
let _check_public_dir: unit => promise<string> = Path.publicDir
let _check_resource_dir: unit => promise<string> = Path.resourceDir
let _check_runtime_dir: unit => promise<string> = Path.runtimeDir
let _check_template_dir: unit => promise<string> = Path.templateDir
let _check_temp_dir: unit => promise<string> = Path.tempDir
let _check_video_dir: unit => promise<string> = Path.videoDir
let _check_resolve_resource: string => promise<string> = Path.resolveResource
let _check_sep: unit => string = Path.sep
let _check_delimiter: unit => string = Path.delimiter
let _check_join: array<string> => promise<string> = Path.join
let _check_normalize: string => promise<string> = Path.normalize
let _check_dirname: string => promise<string> = Path.dirname
let _check_basename: (string, ~ext: string=?) => promise<string> = Path.basename
let _check_extname: string => promise<string> = Path.extname
let _check_is_absolute: string => promise<bool> = Path.isAbsolute
let _check_resolve: array<string> => promise<string> = Path.resolve
