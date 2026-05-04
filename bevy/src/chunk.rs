use bevy::prelude::*;
use noise::{NoiseFn, SuperSimplex};
use std::sync::{Arc, Mutex};
use std::collections::HashMap;

use crate::consts::*;
use crate::proglang::lexer::Lexer;
use crate::proglang::parser::Parser;
use crate::proglang::compiler::{Compiler, Bytecode};
use crate::proglang::vm::{VM, Value};

/* ── tile ID ────────────────────────────────────────────────────────────── */

pub type TileId = u16;

pub const TILE_EMPTY:       TileId = 0;
pub const TILE_GRASS_BLOCK: TileId = 1;
pub const TILE_DIRT:        TileId = 2;
pub const TILE_STONE:       TileId = 3;

pub const TILE_ID_STRINGS: &[(TileId, &str)] = &[
    (TILE_GRASS_BLOCK, "phantasia:grass_block"),
    (TILE_DIRT,        "phantasia:dirt"),
    (TILE_STONE,       "phantasia:stone"),
];

pub fn tile_id_str(id: TileId) -> Option<&'static str>
{
    TILE_ID_STRINGS.iter().find(|(t, _)| *t == id).map(|(_, s)| *s)
}

/* ── chunk data ─────────────────────────────────────────────────────────── */

pub const CHUNK_TILE_COUNT: usize = (CHUNK_SIZE * CHUNK_SIZE) as usize;
pub const CHUNK_LAYER_COUNT: usize = CHUNK_DEPTH;

#[derive(Clone)]
pub struct ChunkData
{
    pub tiles: Vec<TileId>,
}

impl ChunkData
{
    pub fn empty() -> Self
    {
        Self {
            tiles: vec![TILE_EMPTY; CHUNK_LAYER_COUNT * CHUNK_TILE_COUNT],
        }
    }

    #[inline]
    pub fn idx(layer: usize, x: i32, y: i32) -> usize
    {
        layer * CHUNK_TILE_COUNT + (y * CHUNK_SIZE + x) as usize
    }

    pub fn get(&self, layer: usize, x: i32, y: i32) -> TileId
    {
        let i = Self::idx(layer, x, y);
        self.tiles[i]
    }

    pub fn set(&mut self, layer: usize, x: i32, y: i32, id: TileId)
    {
        let i = Self::idx(layer, x, y);
        if i < self.tiles.len() {
            self.tiles[i] = id;
        }
    }
}

/* ── chunk coordinate component ─────────────────────────────────────────── */

#[derive(Component, Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct ChunkCoord
{
    pub cx: i32,
    pub cy: i32,
}

impl ChunkCoord
{
    pub fn world_origin(self) -> Vec2
    {
        Vec2::new(
            self.cx as f32 * CHUNK_SIZE_F32 * TILE_SIZE,
            self.cy as f32 * CHUNK_SIZE_F32 * TILE_SIZE,
        )
    }

    pub fn tile_start(self) -> (i32, i32)
    {
        (self.cx * CHUNK_SIZE, self.cy * CHUNK_SIZE)
    }
}

/* ── chunk entity marker ────────────────────────────────────────────────── */

#[derive(Component)]
pub struct Chunk
{
    pub data:  ChunkData,
    pub dirty: bool,
}

/* ── world-gen noise state ──────────────────────────────────────────────── */

#[derive(Resource)]
pub struct WorldGen
{
    pub seed:      u32,
    noise:         SuperSimplex,
    pub bytecode:  Option<Bytecode>,
    pub globals:   HashMap<String, Value>,
}

impl WorldGen
{
    pub fn new(seed: u32) -> Self
    {
        Self {
            seed,
            noise: SuperSimplex::new(seed),
            bytecode: None,
            globals: HashMap::new(),
        }
    }
}

/* ── chunk generation ───────────────────────────────────────────────────── */

pub fn generate_chunk(coord: ChunkCoord, wgen: &WorldGen) -> ChunkData
{
    let mut data = ChunkData::empty();

    if let Some(bytecode) = &wgen.bytecode {
        let mut vm = VM::new(bytecode.clone());
        vm.globals = wgen.globals.clone();

        // Register noise function
        let noise = wgen.noise.clone();
        vm.set_global("surface_y", Value::NativeFunction(Arc::new(move |args| {
            if let Some(Value::Number(x)) = args.get(0) {
                let nx = *x * 0.025;
                let h = noise.get([nx, 0.0]) * 6.0
                      + noise.get([nx * 3.0, 1.0]) * 2.0;
                Value::Number((WORLD_SURFACE_Y as f64 + h.round()).floor())
            } else {
                Value::Undefined
            }
        })));

        // Use a Mutex-protected buffer to receive tiles from the script
        let buffer = Arc::new(Mutex::new(vec![0u16; CHUNK_TILE_COUNT]));
        let buffer_clone = Arc::clone(&buffer);

        vm.set_global("set_chunk_tile", Value::NativeFunction(Arc::new(move |args| {
            if let (Some(Value::Number(lx)), Some(Value::Number(ly)), Some(Value::Number(t))) = (args.get(0), args.get(1), args.get(2)) {
                let mut b = buffer_clone.lock().unwrap();
                let idx = (*ly as usize * CHUNK_SIZE as usize) + (*lx as usize);
                if idx < b.len() {
                    b[idx] = *t as u16;
                }
            }
            Value::Undefined
        })));

        // Call the entry point
        let _ = vm.call_function("generate_chunk_script", vec![
            Value::Number(coord.cx as f64),
            Value::Number(coord.cy as f64)
        ]);

        // Copy buffer to ChunkData
        let final_tiles = buffer.lock().unwrap();
        for i in 0..CHUNK_TILE_COUNT {
            data.tiles[i] = final_tiles[i];
        }

        return data;
    }

    // Default logic (if script fails or is not loaded)
    let (tx0, ty0) = coord.tile_start();
    for lx in 0..CHUNK_SIZE {
        let world_x = tx0 + lx;
        let nx = world_x as f64 * 0.025;
        let h = wgen.noise.get([nx, 0.0]) * 6.0 + wgen.noise.get([nx * 3.0, 1.0]) * 2.0;
        let surf_y = WORLD_SURFACE_Y + h.round() as i32;
        for ly in 0..CHUNK_SIZE {
            let world_y = ty0 + ly;
            if world_y >= surf_y {
                let tile = if world_y == surf_y { TILE_GRASS_BLOCK }
                           else if world_y < surf_y + WORLD_DIRT_DEPTH { TILE_DIRT }
                           else { TILE_STONE };
                data.set(LAYER_DEFAULT, lx, ly, tile);
            }
        }
    }
    data
}

/* ── plugin ─────────────────────────────────────────────────────────────── */

pub struct ChunkPlugin;

impl Plugin for ChunkPlugin
{
    fn build(&self, app: &mut App)
    {
        app.insert_resource(WorldGen::new(12345))
           .add_systems(Startup, init_worldgen_script)
           .add_systems(PostStartup, spawn_initial_chunks)
           .add_systems(Update, mark_adjacent_dirty);
    }
}

fn init_worldgen_script(mut wgen: ResMut<WorldGen>) {
    let script_path = "../datafiles/scripts/worldgen.daydream";
    if let Ok(source) = std::fs::read_to_string(script_path) {
        let mut lexer = Lexer::new(&source);
        let tokens = lexer.tokenize();
        let mut parser = Parser::new(tokens);
        if let Ok(ast) = parser.parse() {
            let compiler = Compiler::new();
            if let Ok(bytecode) = compiler.compile(&ast) {
                let mut vm = VM::new(bytecode.clone());
                // Pre-run to register functions in globals
                let _ = vm.run();
                wgen.bytecode = Some(bytecode);
                wgen.globals = vm.globals;
                info!("Worldgen script initialized successfully.");
            }
        }
    }
}

fn spawn_initial_chunks(
    mut commands: Commands,
    wgen:         Res<WorldGen>,
)
{
    let surface_cy = WORLD_SURFACE_Y / CHUNK_SIZE;
    for dy in -1..=2_i32 {
        for dx in -CHUNK_VIEW_RADIUS..=CHUNK_VIEW_RADIUS {
            let coord = ChunkCoord { cx: dx, cy: surface_cy + dy };
            let data  = generate_chunk(coord, &wgen);
            commands.spawn((
                coord,
                Chunk { data, dirty: true },
                Transform::default(),
                Visibility::default(),
            ));
        }
    }
}

fn mark_adjacent_dirty(
    mut param_set: ParamSet<(
        Query<&ChunkCoord, Added<Chunk>>,
        Query<(&ChunkCoord, &mut Chunk)>,
    )>,
)
{
    let new_coords: Vec<(i32, i32)> = param_set.p0().iter().map(|c| (c.cx, c.cy)).collect();
    if new_coords.is_empty() { return; }
    for (coord, mut chunk) in param_set.p1().iter_mut() {
        let is_neighbour = new_coords.iter().any(|(nx, ny)| (coord.cx - nx).abs() + (coord.cy - ny).abs() == 1);
        if is_neighbour { chunk.dirty = true; }
    }
}
