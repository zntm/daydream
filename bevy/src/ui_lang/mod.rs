pub mod ast;
pub mod lexer;
pub mod parser;
pub mod runtime;

use bevy::prelude::*;
use crate::ui_lang::runtime::{UiRuntime, startup_ui, ui_runtime_system};

pub struct UiLangPlugin;

impl Plugin for UiLangPlugin {
    fn build(&self, app: &mut App) {
        app.init_resource::<UiRuntime>()
           .add_systems(Startup, startup_ui)
           .add_systems(Update, ui_runtime_system);
    }
}
