/// @desc Chunk pooling system using constructor-based structs
/// Replaces obj_Chunk instances with lightweight struct management

// Note: Ensure Pool script is loaded before this or in same group

/// Chunk state flags
enum CHUNK_BOOLEAN {
    GENERATED                = 1 << 0,
    SURFACE_LIGHTING_REFRESH = 1 << 1,
    QUEUED                   = 1 << 2,
    DIRTY                    = 1 << 3,
    TILE_PROCESSED           = 1 << 4
}

/// @function Chunk(_x, _y)
/// @desc Constructor for chunk data struct - replaces obj_Chunk
/// @param {real} _x Pixel X position
/// @param {real} _y Pixel Y position
function Chunk(_x, _y) constructor
{
    // Position (replaces instance x/y)
    x = _x;
    y = _y;
    chunk_xstart = floor(_x / CHUNK_SIZE);
    chunk_ystart = floor(_y / CHUNK_SIZE);
    xcenter = _x - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
    ycenter = _y - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
    
    // Tile data
    chunk = array_create(CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH, TILE_EMPTY);
    chunk_covered = array_create(CHUNK_SIZE);
    chunk_covered_surface = -1;
    chunk_covered_surface_refresh = true;
    chunk_render_state = [];
    chunk_occluded = array_create(CHUNK_SIZE * CHUNK_SIZE, 0); // Bitwise occlusion flags per layer
    
    // Pooled objects (structs)
    chunk_crafting_stations = [];
    chunk_containers = [];
    chunk_lights = [];
    
    // Skew arrays for foliage animation
    chunk_skew_back = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
    chunk_skew_back_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
    chunk_skew_front = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
    chunk_skew_front_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
    
    // Liquid wave arrays
    chunk_wave = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
    chunk_wave_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
    
    // Rendering
    chunk_vertex_buffer = array_create(CHUNK_DEPTH, -1);
    chunk_count = array_create(CHUNK_DEPTH, 0);
    chunk_display = 0;
    surface_lighting = -1;
    
    // State flags
    boolean = CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
    
    // Fade in timer (0 to 1)
    timer_fade = 0;
}

/// @function ChunkPool()
/// @desc Pool manager for chunk structs
function ChunkPool() : Pool() constructor
{
    max_size = 32;
    
    // Valid list of chunks currently fading in
    fading_chunks = [];
    
    static create = function()
    {
        return new Chunk(0, 0);
    }
    
    /// @function reset(_chunk, _x, _y)
    /// @desc Reset and reinitialize a chunk at new position
    static reset = function(_chunk, _x, _y)
    {
        // Reset position
        _chunk.x = _x;
        _chunk.y = _y;
        _chunk.chunk_xstart = floor(_x / CHUNK_SIZE);
        _chunk.chunk_ystart = floor(_y / CHUNK_SIZE);
        _chunk.xcenter = _x - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
        _chunk.ycenter = _y - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
        
        // Clear tile data
        var _chunk_size = CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH;
        for (var i = 0; i < _chunk_size; ++i)
        {
            var _tile = _chunk.chunk[i];
            if (_tile != TILE_EMPTY)
            {
                delete _tile;
            }
            _chunk.chunk[@ i] = TILE_EMPTY;
        }
        
        // Clear chunk covered
        for (var i = 0; i < CHUNK_SIZE; ++i)
        {
            _chunk.chunk_covered[@ i] = 0;
        }
        
        // Clear occlusion flags
        var _occluded_size = CHUNK_SIZE * CHUNK_SIZE;
        for (var i = 0; i < _occluded_size; ++i)
        {
            _chunk.chunk_occluded[@ i] = 0;
        }
        
        // Clear count array
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            _chunk.chunk_count[@ i] = 0;
        }
        
        // Clear skew arrays (16x16 = 256)
        var _skew_size = CHUNK_SIZE * CHUNK_SIZE;
        for (var i = 0; i < _skew_size; ++i)
        {
            _chunk.chunk_skew_back[@ i] = 0;
            _chunk.chunk_skew_back_to[@ i] = 0;
            _chunk.chunk_skew_front[@ i] = 0;
            _chunk.chunk_skew_front_to[@ i] = 0;
        }
        
        _chunk.chunk_display = 0;
        _chunk.boolean = CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
        _chunk.chunk_covered_surface_refresh = true;
        
        // Reset fade timer and add to fading list
        _chunk.timer_fade = 0;
        array_push(fading_chunks, _chunk);
        
        global.render_state_pool.clear_list(_chunk.chunk_render_state);
        
        // Clear pooled objects
        _chunk.chunk_crafting_stations = [];
        _chunk.chunk_containers = [];
        _chunk.chunk_lights = [];
        
        // Register at new position
        chunk_map_register(_chunk);
        
        // Regenerate structures and generate chunk
        control_structure(_chunk.chunk_xstart, _chunk.chunk_ystart);
        
        var _is_loaded = file_load_world_chunk(global.world_save_data, _chunk);
        
        if (!_is_loaded)
        {
            // Cache worldgen context for performance (hoisted lookups)
            if (variable_global_exists("worldgen_context") == false)
            {
                var _wsd = global.world_save_data;
                var _wd = global.world_data[$ _wsd.dimension];
                var _sky_id = _wd.get_sky_biome_id();
                global.worldgen_context = {
                    item_data: global.item_data,
                    natural_structure_data: global.natural_structure_data,
                    structure_data: global.structure_data,
                    world_save_data: _wsd,
                    world_data: _wd,
                    biome_data: global.biome_data,
                    world_height: _wd.get_world_height(),
                    world_seed: _wsd.seed,
                    sky_threshold: _wd.get_sky_biome_threshold(),
                    sky_enabled: _wd.is_sky_biome_enabled(),
                    sky_biome_id: _sky_id,
                    sky_biome_data: global.biome_data[$ _sky_id],
                    surface_start: _wd.get_surface_start(),
                    blend_range: _wd.get_biome_blend_range()
                };
            }
            
            chunk_generate(_chunk, global.worldgen_context);
            _chunk.boolean |= CHUNK_BOOLEAN.GENERATED;
        }
        else
        {
            _chunk.boolean |= CHUNK_BOOLEAN.GENERATED;
        }
        
        // Trigger lighting refresh
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        // Defer tile processing to the queue for smooth loading
        array_push(global.chunk_tile_process_queue, _chunk);
    }

    static acquire = function(_x, _y)
    {
        var _chunk = get_free_item();
        
        // Reset the chunk at new position
        reset(_chunk, _x, _y);
        
        return _chunk;
    }
    
    static on_release = function(_chunk)
    {
        // Unregister from map
        chunk_map_unregister(_chunk);
        
        // Clean render states
        if (is_array(_chunk.chunk_render_state))
        {
            global.render_state_pool.clear_list(_chunk.chunk_render_state);
        }
        
        // Clear pooled objects
        _chunk.chunk_crafting_stations = [];
        _chunk.chunk_containers = [];
        _chunk.chunk_lights = [];
        
        // Clear vertex buffers
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if (vertex_buffer_exists(_chunk.chunk_vertex_buffer[i]))
            {
                vertex_delete_buffer(_chunk.chunk_vertex_buffer[i]);
            }
            _chunk.chunk_vertex_buffer[@ i] = -1;
        }
        
        // Free surfaces
        if (surface_exists(_chunk.surface_lighting))
        {
            surface_free(_chunk.surface_lighting);
            _chunk.surface_lighting = -1;
        }
        if (surface_exists(_chunk.chunk_covered_surface))
        {
            surface_free(_chunk.chunk_covered_surface);
            _chunk.chunk_covered_surface = -1;
        }
        
        // Remove from fading list if present
        var _index = array_get_index(fading_chunks, _chunk);
        if (_index != -1)
        {
            array_delete(fading_chunks, _index, 1);
        }
    }
    
    static destroy = function(_chunk)
    {
        // Cleanup resources before GC
        on_release(_chunk);
    }
    
    /// @function clear_all()
    /// @desc Clear all chunks and free resources
    static clear_all = function()
    {
        // Clean up all pooled chunks
        for (var i = 0; i < array_length(pool); ++i)
        {
            on_release(pool[i]);
        }
        pool = [];
        fading_chunks = [];
    }
    
    // Override release to check capacity
    static release = function(_chunk)
    {
        if (array_length(pool) < max_size)
        {
            on_release(_chunk);
            array_push(pool, _chunk);
        }
        else
        {
            // Pool full - cleanup and let GC handle
            chunk_map_unregister(_chunk);
            
            if (is_array(_chunk.chunk_render_state))
            {
                global.render_state_pool.clear_list(_chunk.chunk_render_state);
            }
        
            // Clear pooled objects
            _chunk.chunk_crafting_stations = [];
            _chunk.chunk_containers = [];
            _chunk.chunk_lights = [];
            
            // Clean vertex buffers and surfaces
            on_release(_chunk);
        }
    }
}

global.chunk_pool = new ChunkPool();
