use bevy::prelude::*;
use hashbrown::HashMap;

use crate::{
    atlas::TileAtlas,
    chunk::{Chunk, ChunkCoord, ChunkData, TileId, TILE_EMPTY},
    consts::*,
    data::TileRegistry,
    player::Player,
};

/* ── tile sprite marker ─────────────────────────────────────────────────── */

#[derive(Component)]
pub struct TileSprite;

/* ── world chunk map (rebuilt each frame) ───────────────────────────────── */

#[derive(Resource, Default)]
pub struct ChunkMap
{
    /* coord → cloned tile data, rebuilt every frame so neighbor checks work */
    pub map: HashMap<(i32, i32), ChunkData>,
}

/* ── rendered chunk tracking ────────────────────────────────────────────── */

#[derive(Resource, Default)]
pub struct RenderedChunks
{
    pub entities: HashMap<(i32, i32), Vec<Entity>>,
}

/* ── plugin ─────────────────────────────────────────────────────────────── */

pub struct RenderPlugin;

impl Plugin for RenderPlugin
{
    fn build(&self, app: &mut App)
    {
        app.init_resource::<ChunkMap>()
           .init_resource::<RenderedChunks>()
           .add_systems(Update, (
               load_chunks_around_player,
               cull_far_chunks,
               build_chunk_map,
               render_dirty_chunks,
           ).chain());
    }
}

/* ── neighbor bitmask ───────────────────────────────────────────────────── */

fn world_tile(
    map:     &ChunkMap,
    layer:   usize,
    world_x: i32,
    world_y: i32,
) -> TileId
{
    let cx = world_x.div_euclid(CHUNK_SIZE);
    let cy = world_y.div_euclid(CHUNK_SIZE);
    let lx = world_x.rem_euclid(CHUNK_SIZE);
    let ly = world_y.rem_euclid(CHUNK_SIZE);

    map.map
       .get(&(cx, cy))
       .map(|d| d.get(layer, lx, ly))
       .unwrap_or(TILE_EMPTY)
}

fn neighbor_mask(
    map:     &ChunkMap,
    layer:   usize,
    world_x: i32,
    world_y: i32,
    self_id: TileId,
) -> u8
{
    let check = |dx: i32, dy: i32| -> bool
    {
        world_tile(map, layer, world_x + dx, world_y + dy) == self_id
    };

    let tl = check(-1, -1);
    let t  = check( 0, -1);
    let tr = check( 1, -1);
    let l  = check(-1,  0);
    let r  = check( 1,  0);
    let bl = check(-1,  1);
    let b  = check( 0,  1);
    let br = check( 1,  1);

    ((tl as u8) << 7)
        | ((t  as u8) << 6)
        | ((tr as u8) << 5)
        | ((l  as u8) << 4)
        | ((r  as u8) << 3)
        | ((bl as u8) << 2)
        | ((b  as u8) << 1)
        | (br  as u8)
}

/* ── connected-texture corner index (mirrors GML __corner_index) ─────────
   Returns 0–4:
   0 = full outer corner (both cardinals + diagonal present)
   1 = edge: only bit_a direction
   2 = edge: only bit_b direction
   3 = inner corner (both cardinals, no diagonal)
   4 = isolated (neither cardinal)
────────────────────────────────────────────────────────────────────────── */

fn corner_index(mask: u8, bit_a: u8, bit_b: u8, bit_corner: u8) -> u32
{
    let both    = bit_a | bit_b;
    let present = mask & both;

    if present == 0
    {
        return 4;
    }

    if present == both
    {
        return if (mask & bit_corner) == 0 { 3 } else { 0 };
    }

    let inv = !mask;

    if inv & bit_a != 0 { return 2; }
    if inv & bit_b != 0 { return 1; }

    0
}

fn connected_frames(mask: u8) -> [u32; 4]
{
    [
        corner_index(mask, NEIGHBOR_T, NEIGHBOR_L, NEIGHBOR_TL), /* TL */
        corner_index(mask, NEIGHBOR_T, NEIGHBOR_R, NEIGHBOR_TR), /* TR */
        corner_index(mask, NEIGHBOR_B, NEIGHBOR_L, NEIGHBOR_BL), /* BL */
        corner_index(mask, NEIGHBOR_B, NEIGHBOR_R, NEIGHBOR_BR), /* BR */
    ]
}

/* ── spawn tile sprites for one chunk ───────────────────────────────────── */

fn spawn_chunk_sprites(
    commands:  &mut Commands,
    coord:     ChunkCoord,
    chunk:     &Chunk,
    map:       &ChunkMap,
    registry:  &TileRegistry,
    atlas:     &TileAtlas,
    rendered:  &mut RenderedChunks,
)
{
    let (tx0, ty0) = coord.tile_start();
    let origin     = coord.world_origin();
    let layer      = LAYER_DEFAULT;
    let mut spawned: Vec<Entity> = Vec::new();
    let hw = TILE_SIZE / 2.0;

    for ly in 0..CHUNK_SIZE
    {
        for lx in 0..CHUNK_SIZE
        {
            let id = chunk.data.get(layer, lx, ly);

            if id == TILE_EMPTY { continue; }

            let tile_str = match crate::chunk::tile_id_str(id)
            {
                Some(s) => s,
                None    => continue,
            };

            let info = match registry.get(tile_str)
            {
                Some(i) => i,
                None    => continue,
            };

            let entry = match atlas.get(&info.sprite_key)
            {
                Some(e) => e,
                None    => continue,
            };

            /* world pixel top-left; Bevy Y is up so we negate tile-space Y */
            let wx = origin.x + lx as f32 * TILE_SIZE;
            let wy = -(origin.y + ly as f32 * TILE_SIZE);
            let z  = LAYER_DEFAULT as f32 * 2.0;

            let world_x = tx0 + lx;
            let world_y = ty0 + ly;

            if info.is_connected
            {
                let mask   = neighbor_mask(map, layer, world_x, world_y, id);
                let frames = connected_frames(mask);

                /* (world_offset, frame, quadrant_idx 0=TL 1=TR 2=BL 3=BR) */
                let quads: [(Vec2, u32, u8); 4] = [
                    (Vec2::new(0.0, 0.0 ), frames[0], 0),
                    (Vec2::new(hw,  0.0 ), frames[1], 1),
                    (Vec2::new(0.0, -hw ), frames[2], 2),
                    (Vec2::new(hw,  -hw ), frames[3], 3),
                ];

                for (offset, frame, quadrant) in quads
                {
                    let rect = entry.quad_rect(frame, quadrant);

                    let e = commands.spawn((
                        TileSprite,
                        Sprite {
                            image:       entry.image.clone(),
                            rect:        Some(rect),
                            custom_size: Some(Vec2::splat(hw)),
                            ..default()
                        },
                        Transform::from_xyz(
                            wx + offset.x + hw / 2.0,
                            wy + offset.y - hw / 2.0,
                            z,
                        ),
                    )).id();

                    spawned.push(e);
                }
            }
            else
            {
                let rect = entry.full_rect(0);

                let e = commands.spawn((
                    TileSprite,
                    Sprite {
                        image:       entry.image.clone(),
                        rect:        Some(rect),
                        custom_size: Some(Vec2::splat(TILE_SIZE)),
                        ..default()
                    },
                    Transform::from_xyz(
                        wx + TILE_SIZE / 2.0,
                        wy - TILE_SIZE / 2.0,
                        z,
                    ),
                )).id();

                spawned.push(e);
            }
        }
    }

    rendered.entities.insert((coord.cx, coord.cy), spawned);
}

/* ── systems ────────────────────────────────────────────────────────────── */

/* rebuild ChunkMap each frame before rendering */
fn build_chunk_map(
    mut map:    ResMut<ChunkMap>,
    chunks:     Query<(&ChunkCoord, &Chunk)>,
)
{
    map.map.clear();

    for (coord, chunk) in chunks.iter()
    {
        map.map.insert((coord.cx, coord.cy), chunk.data.clone());
    }
}

fn render_dirty_chunks(
    mut commands: Commands,
    map:          Res<ChunkMap>,
    mut chunks:   Query<(&ChunkCoord, &mut Chunk)>,
    registry:     Res<TileRegistry>,
    atlas:        Res<TileAtlas>,
    mut rendered: ResMut<RenderedChunks>,
)
{
    for (coord, mut chunk) in chunks.iter_mut()
    {
        if !chunk.dirty { continue; }

        chunk.dirty = false;

        /* despawn old sprites */
        if let Some(old) = rendered.entities.remove(&(coord.cx, coord.cy))
        {
            for e in old { commands.entity(e).despawn(); }
        }

        spawn_chunk_sprites(
            &mut commands,
            *coord,
            &chunk,
            &map,
            &registry,
            &atlas,
            &mut rendered,
        );
    }
}

fn load_chunks_around_player(
    mut commands: Commands,
    players:      Query<&Transform, With<Player>>,
    existing:     Query<&ChunkCoord>,
    wgen:         Res<crate::chunk::WorldGen>,
)
{
    let Ok(player_t) = players.get_single() else { return; };

    let chunk_w = CHUNK_SIZE_F32 * TILE_SIZE;
    let pcx     = (player_t.translation.x / chunk_w).floor() as i32;
    let pcy     = ((-player_t.translation.y) / chunk_w).floor() as i32;

    let loaded: hashbrown::HashSet<(i32, i32)> = existing
        .iter()
        .map(|c| (c.cx, c.cy))
        .collect();

    for dy in -CHUNK_VIEW_RADIUS..=CHUNK_VIEW_RADIUS
    {
        for dx in -CHUNK_VIEW_RADIUS..=CHUNK_VIEW_RADIUS
        {
            let (cx, cy) = (pcx + dx, pcy + dy);

            if loaded.contains(&(cx, cy)) { continue; }

            let coord = ChunkCoord { cx, cy };
            let data  = crate::chunk::generate_chunk(coord, &wgen);

            commands.spawn((
                coord,
                Chunk { data, dirty: true },
                Transform::default(),
                Visibility::default(),
            ));
        }
    }
}

fn cull_far_chunks(
    mut commands: Commands,
    players:      Query<&Transform, With<Player>>,
    chunks:       Query<(Entity, &ChunkCoord)>,
    mut rendered: ResMut<RenderedChunks>,
)
{
    let Ok(player_t) = players.get_single() else { return; };

    let chunk_w     = CHUNK_SIZE_F32 * TILE_SIZE;
    let pcx         = (player_t.translation.x / chunk_w).floor() as i32;
    let pcy         = ((-player_t.translation.y) / chunk_w).floor() as i32;
    let cull_radius = CHUNK_VIEW_RADIUS + 2;

    for (entity, coord) in chunks.iter()
    {
        if (coord.cx - pcx).abs() > cull_radius || (coord.cy - pcy).abs() > cull_radius
        {
            if let Some(sprites) = rendered.entities.remove(&(coord.cx, coord.cy))
            {
                for e in sprites { commands.entity(e).despawn(); }
            }

            commands.entity(entity).despawn();
        }
    }
}
