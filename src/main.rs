use std::process;
use std::sync::{mpsc, Mutex, OnceLock};
use std::thread;

use aeroswiper::gesture::{GestureConfig, GestureDetector};
use aeroswiper::switcher::WorkspaceSwitcher;
use aeroswiper::transport::AerospaceSocket;
use aeroswiper::Direction;

static DETECTOR: OnceLock<Mutex<GestureDetector>> = OnceLock::new();
static SENDER: OnceLock<mpsc::Sender<Direction>> = OnceLock::new();

#[cfg(target_os = "macos")]
unsafe extern "C" {
    fn check_accessibility_permission(prompt: i32) -> i32;
    fn run_swipe_event_loop(prompt: i32, callback: extern "C" fn(i32, f32, f32, f64)) -> i32;
}

extern "C" fn on_swipe_sample(touch_count: i32, avg_x: f32, avg_y: f32, _timestamp: f64) {
    let Some(detector) = DETECTOR.get() else {
        return;
    };

    let Ok(mut detector) = detector.lock() else {
        return;
    };

    let Some(direction) = detector.process_sample(touch_count, avg_x, avg_y) else {
        return;
    };

    if let Some(tx) = SENDER.get() {
        let _ = tx.send(direction);
    }
}

fn start_worker(rx: mpsc::Receiver<Direction>) {
    let mut switcher = WorkspaceSwitcher::new(AerospaceSocket::new(AerospaceSocket::default_path()));

    while let Ok(direction) = rx.recv() {
        if let Err(err) = switcher.switch(direction) {
            eprintln!("workspace switch failed: {err}");
        }
    }
}

#[derive(Debug, Clone, Copy)]
struct CliOptions {
    prompt_accessibility: bool,
    check_only: bool,
}

fn parse_cli_options() -> Result<CliOptions, String> {
    let mut opts = CliOptions {
        prompt_accessibility: false,
        check_only: false,
    };

    for arg in std::env::args().skip(1) {
        match arg.as_str() {
            "--prompt-accessibility" => opts.prompt_accessibility = true,
            "--check-accessibility" => opts.check_only = true,
            "--help" | "-h" => {
                println!("Usage: aeroswiper [--prompt-accessibility] [--check-accessibility]");
                process::exit(0);
            }
            _ => return Err(format!("unknown option: {arg}")),
        }
    }

    Ok(opts)
}

fn main() {
    let opts = match parse_cli_options() {
        Ok(opts) => opts,
        Err(err) => {
            eprintln!("{err}");
            process::exit(64);
        }
    };

    #[cfg(target_os = "macos")]
    unsafe {
        if opts.check_only {
            let rc = check_accessibility_permission(if opts.prompt_accessibility { 1 } else { 0 });
            process::exit(rc);
        }
    }

    let _ = DETECTOR.set(Mutex::new(GestureDetector::new(GestureConfig::default())));

    let (tx, rx) = mpsc::channel::<Direction>();
    let _ = SENDER.set(tx);

    thread::spawn(move || start_worker(rx));

    #[cfg(target_os = "macos")]
    unsafe {
        let rc = run_swipe_event_loop(if opts.prompt_accessibility { 1 } else { 0 }, on_swipe_sample);
        if rc != 0 {
            eprintln!("failed to start swipe event loop, rc={rc}");
            process::exit(rc);
        }
    }

    #[cfg(not(target_os = "macos"))]
    {
        eprintln!("aerospace-swipe-minimal currently supports macOS only");
        process::exit(2);
    }
}
