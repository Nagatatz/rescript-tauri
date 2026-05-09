use serde::Serialize;
use tauri::ipc::Channel;

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! - from rescript-tauri ipc-typed-with-schema", name)
}

#[tauri::command]
fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[derive(Serialize)]
struct Summary {
    count: i32,
    joined: String,
}

#[tauri::command]
fn summarize(title: &str, items: Vec<String>) -> Summary {
    Summary {
        count: items.len() as i32,
        joined: format!("{}: {}", title, items.join(", ")),
    }
}

#[tauri::command]
fn count_to(channel: Channel<u32>, target: u32) -> Result<(), String> {
    for n in 1..=target {
        channel.send(n).map_err(|e| e.to_string())?;
    }
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet, add, summarize, count_to])
        .run(tauri::generate_context!())
        .expect("error while running ipc-typed-with-schema");
}
