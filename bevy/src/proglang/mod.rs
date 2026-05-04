pub mod ast;
pub mod lexer;
pub mod parser;
pub mod compiler;
pub mod vm;

use bevy::prelude::*;

pub struct ProglangPlugin;

impl Plugin for ProglangPlugin {
    fn build(&self, _app: &mut App) {
        // Global script state could be initialized here
    }
}
