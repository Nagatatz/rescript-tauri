fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_os::init())
        .run(tauri::generate_context!())
        .expect("error while running plugin-os-demo");
}
