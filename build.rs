#[cfg(target_os = "macos")]
fn main() {
    use std::env;
    use std::path::PathBuf;
    use std::process::Command;

    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR missing"));
    let obj = out_dir.join("swipe_bridge.o");

    let status = Command::new("clang")
        .args([
            "-fobjc-arc",
            "-c",
            "bridge/swipe_bridge.m",
            "-o",
            obj.to_str().expect("invalid obj path"),
        ])
        .status()
        .expect("failed to run clang for Objective-C bridge");

    if !status.success() {
        panic!("Objective-C bridge compilation failed");
    }

    println!("cargo:rustc-link-arg={}", obj.display());
    println!("cargo:rustc-link-lib=framework=ApplicationServices");
    println!("cargo:rustc-link-lib=framework=AppKit");
    println!("cargo:rustc-link-lib=framework=Cocoa");
    println!("cargo:rerun-if-changed=bridge/swipe_bridge.m");
}

#[cfg(not(target_os = "macos"))]
fn main() {}
