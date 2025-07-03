use anyhow::Result;
use tauri::{App, Manager};

pub fn run_gui() -> Result<()> {
    tauri::Builder::default()
        .setup(|app| {
            let window = app.get_window("main").unwrap();
            // Add any initial setup here
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");

    Ok(())
}
