/// @desc Chunk pooling system to reduce memory allocation overhead
/// Recycles chunks instead of creating/destroying them

global.chunk_pool = [];
global.chunk_pool_max = 32;

/// @function chunk_pool_init()
/// @desc Initialize chunk pool
function chunk_pool_init()
{
    global.chunk_pool = [];
}

/// @function chunk_pool_acquire(_x, _y)
/// @desc Get a chunk from pool or create new
/// @param {real} _x World X position (aligned to chunk grid)
/// @param {real} _y World Y position (aligned to chunk grid)
/// @returns {Id.Instance} Chunk instance
function chunk_pool_acquire(_x, _y)
{
    var _pool = global.chunk_pool;
    
    if (array_length(_pool) > 0)
    {
        var _inst = array_pop(_pool);
        
        // Reactivate and reset the chunk
        instance_activate_object(_inst);
        chunk_reset(_inst, _x, _y);
        
        return _inst;
    }
    
    // Create new chunk if pool is empty
    return instance_create_layer(_x, _y, "Instances", obj_Chunk);
}

/// @function chunk_pool_release(_inst)
/// @desc Return chunk to pool instead of destroying
/// @param {Id.Instance} _inst Chunk instance
function chunk_pool_release(_inst)
{
    if (!instance_exists(_inst)) exit;
    
    // Unregister from map
    chunk_map_unregister(_inst);
    
    if (array_length(global.chunk_pool) < global.chunk_pool_max)
    {
        // Clear vertex buffers before pooling
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if (vertex_buffer_exists(_inst.chunk_vertex_buffer[i]))
            {
                vertex_delete_buffer(_inst.chunk_vertex_buffer[i]);
            }
            _inst.chunk_vertex_buffer[@ i] = -1;
        }
        
        // Free surfaces
        if (surface_exists(_inst.surface_lighting))
        {
            surface_free(_inst.surface_lighting);
            _inst.surface_lighting = -1;
        }
        if (surface_exists(_inst.chunk_covered_surface))
        {
            surface_free(_inst.chunk_covered_surface);
            _inst.chunk_covered_surface = -1;
        }
        
        // Deactivate and pool
        instance_deactivate_object(_inst);
        array_push(global.chunk_pool, _inst);
    }
    else
    {
        // Pool full - destroy the chunk
        instance_destroy(_inst);
    }
}

/// @function chunk_reset(_inst, _x, _y)
/// @desc Reset chunk for reuse at new position
/// @param {Id.Instance} _inst Chunk instance
/// @param {real} _x New X position
/// @param {real} _y New Y position
function chunk_reset(_inst, _x, _y)
{
    with (_inst)
    {
        // Reset position
        x = _x;
        y = _y;
        chunk_xstart = floor(_x / CHUNK_SIZE);
        chunk_ystart = floor(_y / CHUNK_SIZE);
        xcenter = _x - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
        ycenter = _y - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
        
        // Clear tile data
        var _chunk_size = CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH;
        for (var i = 0; i < _chunk_size; ++i)
        {
            var _tile = chunk[i];
            if (_tile != TILE_EMPTY)
            {
                delete _tile;
            }
            chunk[@ i] = TILE_EMPTY;
        }
        
        // Clear chunk covered
        for (var i = 0; i < CHUNK_SIZE; ++i)
        {
            chunk_covered[@ i] = 0;
        }
        
        // Clear count array
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            chunk_count[@ i] = 0;
        }
        
        // Clear skew arrays (16x16 = 256)
        var _skew_size = CHUNK_SIZE * CHUNK_SIZE;
        for (var i = 0; i < _skew_size; ++i)
        {
            chunk_skew_back[@ i] = 0;
            chunk_skew_back_to[@ i] = 0;
            chunk_skew_front[@ i] = 0;
            chunk_skew_front_to[@ i] = 0;
        }
        
        chunk_display = 0;
        boolean = CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
        chunk_covered_surface_refresh = true;
        
        array_resize(chunk_render_state, 0);
        
        // Register at new position
        chunk_map_register(id);
        
        // Regenerate structures and generate chunk
        control_structure(chunk_xstart, chunk_ystart);
        
        var _is_loaded = file_load_world_chunk(global.world_save_data, id);
        
        if (!_is_loaded)
        {
            chunk_generate();
            boolean |= CHUNK_BOOLEAN.GENERATED;
        }
        else
        {
            boolean |= CHUNK_BOOLEAN.GENERATED;
        }
        
        // Trigger lighting refresh
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
    
    // Defer tile processing to the queue for smooth loading
    array_push(global.chunk_tile_process_queue, _inst);
}

/// @function chunk_pool_clear()
/// @desc Destroy all pooled chunks
function chunk_pool_clear()
{
    var _pool = global.chunk_pool;
    var _length = array_length(_pool);
    
    for (var i = 0; i < _length; ++i)
    {
        var _inst = _pool[i];
        if (instance_exists(_inst))
        {
            instance_activate_object(_inst);
            instance_destroy(_inst);
        }
    }
    
    global.chunk_pool = [];
}

/// @function chunk_pool_get_size()
/// @returns {real} Number of chunks in pool
function chunk_pool_get_size()
{
    return array_length(global.chunk_pool);
}
