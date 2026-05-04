mod consts;
mod data;
mod atlas;
mod chunk;
mod player;
mod camera;
mod gametick;
mod render;
mod proglang;
mod ui_lang;

use bevy::prelude::*;
use bevy::asset::AssetPlugin;

fn main()
{
    App::new()
        .add_plugins(DefaultPlugins
            .set(WindowPlugin {
                primary_window: Some(Window {
                    title:           "Phantasia".into(),
                    resolution:      (1280.0, 720.0).into(),
                    resizable:       true,
                    ..default()
                }),
                ..default()
            })
            /* nearest-neighbor filtering for pixel-art tiles */
            .set(ImagePlugin::default_nearest())
            /* point Bevy's asset loader at the existing sprite/data folder */
            .set(AssetPlugin {
                file_path: "../datafiles/resources/assets".to_string(),
                ..default()
            }))
        .add_plugins((
            data::DataPlugin,
            atlas::AtlasPlugin,
            chunk::ChunkPlugin,
            player::PlayerPlugin,
            camera::CameraPlugin,
            gametick::GameTickPlugin,
            render::RenderPlugin,
            proglang::ProglangPlugin,
            ui_lang::UiLangPlugin,
        ))
        .run();
}
