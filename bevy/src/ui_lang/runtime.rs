use crate::ui_lang::ast::*;
use crate::ui_lang::lexer::Lexer;
use crate::ui_lang::parser::Parser;
use bevy::prelude::*;
use std::collections::HashMap;

#[derive(Resource, Default)]
pub struct UiRuntime {
    pub definitions: HashMap<String, UiDocument>,
    pub instances: HashMap<u32, UiInstance>,
    pub counter: u32,
}

pub struct UiInstance {
    pub id: u32,
    pub root_entities: Vec<Entity>,
}

#[derive(Component)]
pub struct UiElementMarker {
    pub element_type: String,
    pub name: String,
}

impl UiRuntime {
    pub fn load_file(&mut self, path: &str) -> Result<(), String> {
        let source = std::fs::read_to_string(path).map_err(|e| e.to_string())?;
        let mut lexer = Lexer::new(&source);
        let tokens = lexer.tokenize();
        let mut parser = Parser::new(tokens);
        let doc = parser.parse()?;
        self.definitions.insert(path.to_string(), doc);
        Ok(())
    }

    pub fn spawn(&mut self, commands: &mut Commands, doc_path: &str) -> Result<u32, String> {
        let doc = self.definitions.get(doc_path).ok_or_else(|| format!("UI Document not found: {}", doc_path))?.clone();
        
        let id = self.counter;
        self.counter += 1;

        let mut root_entities = Vec::new();

        for def in &doc.definitions {
            if let UiDef::Element(el) = def {
                let entity = spawn_element(commands, el);
                root_entities.push(entity);
            }
        }

        self.instances.insert(id, UiInstance { id, root_entities });
        Ok(id)
    }
}

fn spawn_element(commands: &mut Commands, el: &UiElement) -> Entity {
    let mut node = Node {
        position_type: PositionType::Absolute,
        ..default()
    };
    let mut background_color = BackgroundColor(Color::WHITE);

    for prop in &el.properties {
        match prop.key.as_str() {
            "size" => {
                if let UiValue::Tuple(v) = &prop.value {
                    if v.len() >= 2 {
                        node.width = resolve_val(&v[0]);
                        node.height = resolve_val(&v[1]);
                    }
                }
            }
            "position" => {
                if let UiValue::Tuple(v) = &prop.value {
                    if v.len() >= 2 {
                        node.left = resolve_val(&v[0]);
                        node.top = resolve_val(&v[1]);
                    }
                }
            }
            "color" => {
                if let UiValue::Color(c) = &prop.value {
                    background_color = BackgroundColor(Color::srgba(
                        c.r as f32 / 255.0,
                        c.g as f32 / 255.0,
                        c.b as f32 / 255.0,
                        c.a
                    ));
                }
            }
            _ => {}
        }
    }

    let cmd = commands.spawn((
        UiElementMarker {
            element_type: el.element_type.clone(),
            name: el.name.clone(),
        },
        node,
        background_color,
    ));

    let entity = cmd.id();

    for child_el in &el.children {
        let child_entity = spawn_element(commands, child_el);
        commands.entity(entity).add_child(child_entity);
    }

    entity
}

fn resolve_val(val: &UiValue) -> Val {
    match val {
        UiValue::Number(n) => Val::Px(*n as f32),
        UiValue::Percentage(p) => Val::Percent(*p as f32),
        _ => Val::Auto,
    }
}

pub fn ui_runtime_system(mut _runtime: ResMut<UiRuntime>) {
}

pub fn startup_ui(mut commands: Commands, mut runtime: ResMut<UiRuntime>) {
    let path = "../datafiles/resources/data/ui/main_menu.ui";
    match runtime.load_file(path) {
        Ok(_) => {
            if let Err(e) = runtime.spawn(&mut commands, path) {
                error!("Failed to spawn UI: {}", e);
            }
        }
        Err(e) => error!("Failed to load UI file: {}", e),
    }
}
