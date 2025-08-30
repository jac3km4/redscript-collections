use std::env;
use std::fs::File;
use std::io::Write;

fn main() {
    let major = env::var("CARGO_PKG_VERSION_MAJOR").unwrap();
    let minor = env::var("CARGO_PKG_VERSION_MINOR").unwrap();
    let patch = env::var("CARGO_PKG_VERSION_PATCH").unwrap();

    let mut f = File::create("src/version.rs").unwrap();
    writeln!(f, "pub const MAJOR: u8 = {};", major).unwrap();
    writeln!(f, "pub const MINOR: u16 = {};", minor).unwrap();
    writeln!(f, "pub const PATCH: u32 = {};", patch).unwrap();
}
