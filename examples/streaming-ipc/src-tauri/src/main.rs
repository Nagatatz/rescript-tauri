use tauri::ipc::Channel;

#[tauri::command]
fn count_to(channel: Channel<u32>, target: u32) -> Result<(), String> {
    for n in 1..=target {
        channel.send(n).map_err(|e| e.to_string())?;
    }
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![count_to])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
