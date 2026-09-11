#![allow(dead_code)]

mod app;
mod buffer;
mod bufferline;
mod explorer;
mod keymap;
mod style;
mod terminal_theme;
mod theme;
mod ui;
mod vim;
mod whichkey;

use clap::Parser;
use std::path::PathBuf;

#[derive(Parser, Debug)]
#[command(
    name = "rvm",
    version = "2.6.0",
    about = "RVM — Native terminal code editor (Vim + LazyVim UX)"
    )]
struct Args {
    /// Path to a file or project directory to open
    #[arg(value_name = "PATH")]
    path: Option<PathBuf>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();
    let mut app = app::App::new(args.path)?;
    app.run()?;
    Ok(())
}
