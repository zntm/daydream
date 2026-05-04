use bevy::prelude::*;
use std::collections::HashMap;

use crate::data::TileRegistry;

/* ── per-tile texture entry ─────────────────────────────────────────────── */

#[derive(Debug, Clone)]
pub struct TileAtlasEntry
{
    pub image:       Handle<Image>,
    pub frame_count: u32,
    /* pixel width/height of a single frame (always 16×16 for tiles) */
    pub frame_w:     u32,
    pub frame_h:     u32,
}

impl TileAtlasEntry
{
    /* returns the pixel rect for a specific frame + corner quadrant.
       quadrant: 0=TL, 1=TR, 2=BL, 3=BR */
    pub fn quad_rect(&self, frame: u32, quadrant: u8) -> Rect
    {
        let x0 = (frame * self.frame_w) as f32;
        let y0 = 0.0_f32;
        let hw = (self.frame_w / 2) as f32;
        let hh = (self.frame_h / 2) as f32;

        let (ox, oy) = match quadrant
        {
            0 => (0.0, 0.0),    /* TL */
            1 => (hw,  0.0),    /* TR */
            2 => (0.0, hh),     /* BL */
            3 => (hw,  hh),     /* BR */
            _ => (0.0, 0.0),
        };

        Rect {
            min: Vec2::new(x0 + ox, y0 + oy),
            max: Vec2::new(x0 + ox + hw, y0 + oy + hh),
        }
    }

    /* rect for a full frame */
    pub fn full_rect(&self, frame: u32) -> Rect
    {
        let x0 = (frame * self.frame_w) as f32;
        Rect {
            min: Vec2::new(x0, 0.0),
            max: Vec2::new(x0 + self.frame_w as f32, self.frame_h as f32),
        }
    }
}

/* ── atlas resource ─────────────────────────────────────────────────────── */

#[derive(Resource, Default)]
pub struct TileAtlas
{
    /* "phantasia:item/stone" → entry */
    pub entries: HashMap<String, TileAtlasEntry>,
}

impl TileAtlas
{
    pub fn get(&self, sprite_key: &str) -> Option<&TileAtlasEntry>
    {
        self.entries.get(sprite_key)
    }
}

/* ── plugin ─────────────────────────────────────────────────────────────── */

pub struct AtlasPlugin;

impl Plugin for AtlasPlugin
{
    fn build(&self, app: &mut App)
    {
        app.init_resource::<TileAtlas>()
           .add_systems(Startup, build_atlas);
    }
}

fn build_atlas(
    mut atlas:    ResMut<TileAtlas>,
    registry:     Res<TileRegistry>,
    asset_server: Res<AssetServer>,
)
{
    let mut loaded = 0u32;
    let mut skipped = 0u32;

    for (_tile_id, info) in &registry.entries
    {
        if info.sprite_key.is_empty()
        {
            continue;
        }

        let asset_path = sprite_key_to_asset_path(&info.sprite_key);

        /* the asset root is ../datafiles/resources/assets relative to bevy/ */
        let fs_path = format!("../datafiles/resources/assets/{asset_path}");

        if !std::path::Path::new(&fs_path).exists()
        {
            skipped += 1;
            continue;
        }

        let image: Handle<Image> = asset_server.load(&asset_path);

        atlas.entries.insert(
            info.sprite_key.clone(),
            TileAtlasEntry {
                image,
                frame_count: info.frame_count,
                frame_w:     16,
                frame_h:     16,
            },
        );

        loaded += 1;
    }

    info!("atlas: loaded {loaded} tile textures, skipped {skipped} missing sprites");
}

fn sprite_key_to_asset_path(key: &str) -> String
{
    /* "phantasia:item/stone" → "sprites/item/stone.png" */
    let local = key.split(':').nth(1).unwrap_or(key);
    format!("sprites/{local}.png")
}
