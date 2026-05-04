use bevy::prelude::*;
use serde::Deserialize;
use std::{collections::HashMap, fs};

/* ── item JSON schema ───────────────────────────────────────────────────── */

#[derive(Debug, Deserialize, Clone)]
pub struct ItemJson
{
    pub sprite:     Option<String>,
    #[serde(rename = "type")]
    pub item_type:  Option<String>,
    pub properties: Option<Vec<String>>,
}

/* ── sprite metadata JSON schema ────────────────────────────────────────── */

#[derive(Debug, Deserialize, Clone)]
pub struct SpriteMetaJson
{
    pub length:  u32,
    pub xoffset: i32,
    pub yoffset: i32,
}

/* ── resolved tile info stored at runtime ───────────────────────────────── */

#[derive(Debug, Clone)]
pub struct TileInfo
{
    /* "phantasia:item/stone" → sprite key used to look up the loaded image */
    pub sprite_key:      String,
    /* how many horizontal frames the sprite sheet has */
    pub frame_count:     u32,
    /* item type flags */
    pub is_solid:        bool,
    pub is_tile:         bool,
    pub is_transparent:  bool,
    /* connected-texture: sprite has the 5-frame layout */
    pub is_connected:    bool,
}

/* ── tile registry resource ─────────────────────────────────────────────── */

#[derive(Resource, Default)]
pub struct TileRegistry
{
    /* "phantasia:stone" → TileInfo */
    pub entries: HashMap<String, TileInfo>,
}

impl TileRegistry
{
    pub fn get(&self, id: &str) -> Option<&TileInfo>
    {
        self.entries.get(id)
    }
}

/* ── plugin ─────────────────────────────────────────────────────────────── */

pub struct DataPlugin;

impl Plugin for DataPlugin
{
    fn build(&self, app: &mut App)
    {
        app.init_resource::<TileRegistry>()
           .add_systems(PreStartup, load_item_data);
    }
}

fn load_item_data(mut registry: ResMut<TileRegistry>)
{
    /* path is relative to bevy/ working directory at runtime */
    let items_dir = "../datafiles/resources/data/items";
    let sprite_dir = "../datafiles/resources/assets/sprites/item";

    let Ok(read_dir) = fs::read_dir(items_dir)
    else
    {
        warn!("could not read item data directory: {items_dir}");
        return;
    };

    for entry in read_dir.flatten()
    {
        let path = entry.path();

        if path.extension().and_then(|e| e.to_str()) != Some("json")
        {
            continue;
        }

        let Ok(contents) = fs::read_to_string(&path)
        else
        {
            continue;
        };

        let Ok(item): Result<ItemJson, _> = serde_json::from_str(&contents)
        else
        {
            continue;
        };

        let stem = path
            .file_stem()
            .and_then(|s| s.to_str())
            .unwrap_or("")
            .to_string();

        let full_id = format!("phantasia:{stem}");

        let sprite_key = item.sprite.clone().unwrap_or_default();

        /* derive the sprite filename from the sprite key
           e.g. "phantasia:item/stone" → "stone.png" */
        let sprite_filename = sprite_key
            .split('/')
            .last()
            .unwrap_or(&stem)
            .to_string();

        /* read sprite metadata to get frame count */
        let meta_path = format!("{sprite_dir}/{sprite_filename}.png.json");
        let frame_count = fs::read_to_string(&meta_path)
            .ok()
            .and_then(|s| serde_json::from_str::<SpriteMetaJson>(&s).ok())
            .map(|m| m.length)
            .unwrap_or(1);

        let props = item.properties.as_deref().unwrap_or(&[]);

        let is_tile        = props.iter().any(|p| p.contains("is_tile"));
        let is_transparent = !props.iter().any(|p| p.contains("is_solid"))
            && item.item_type.as_deref() != Some("solid");

        /* connected texture if it has the standard 5-frame layout */
        let is_connected = frame_count == crate::consts::CONNECTED_FRAMES;

        let is_solid = item.item_type.as_deref() == Some("solid");

        registry.entries.insert(
            full_id,
            TileInfo {
                sprite_key,
                frame_count,
                is_solid,
                is_tile,
                is_transparent,
                is_connected,
            },
        );
    }

    info!("loaded {} tile definitions", registry.entries.len());
}
