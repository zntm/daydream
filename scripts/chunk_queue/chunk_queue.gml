/// @desc Chunk generation queue system for time-sliced worldgen
/// Spreads chunk generation across multiple frames to prevent stuttering

#macro CHUNK_GEN_BUDGET_MS 2  // Max milliseconds per frame for chunk generation (reduced from 4)
#macro CHUNK_GEN_MAX_PER_FRAME 1  // Max chunks to generate per frame (reduced from 2)

// Queue for deferred tile processing (tile_connect calls)
global.chunk_tile_process_queue = [];
#macro CHUNK_TILE_PROCESS_BUDGET_MS 2  // Time budget for tile processing

/// @function chunk_queue_init()
/// @desc Initialize the chunk generation queue
function chunk_queue_init()
{
    global.chunk_gen_queue = ds_priority_create();
    global.chunk_gen_processing = false;
    global.chunk_tile_process_queue = [];
}

/// @function chunk_queue_add(_inst, _priority)
/// @desc Add a chunk to the generation queue
/// @param {Id.Instance} _inst Chunk instance to generate
/// @param {real} _priority Priority (lower = higher priority, typically distance to player)
function chunk_queue_add(_inst, _priority)
{
    if (!instance_exists(_inst)) exit;
    if (_inst.boolean & CHUNK_BOOLEAN.GENERATED) exit;
    if (_inst.boolean & CHUNK_BOOLEAN.QUEUED) exit;
    
    _inst.boolean |= CHUNK_BOOLEAN.QUEUED;
    ds_priority_add(global.chunk_gen_queue, _inst, _priority);
}

/// @function chunk_queue_process(_player_x, _player_y)
/// @desc Process queued chunks within time budget
/// @param {real} _player_x Player X position for priority calculation
/// @param {real} _player_y Player Y position for priority calculation
function chunk_queue_process(_player_x, _player_y)
{
    var _queue = global.chunk_gen_queue;
    
    // First, process any pending tile work from previous generations
    chunk_tile_process_queue_process();
    
    if (ds_priority_empty(_queue)) exit;
    
    var _start_time = get_timer();
    var _budget_us = CHUNK_GEN_BUDGET_MS * 1000; // Convert ms to microseconds
    var _chunks_generated = 0;
    
    while (!ds_priority_empty(_queue))
    {
        // Check time budget
        if ((get_timer() - _start_time) > _budget_us) break;
        
        // Check max chunks per frame
        if (_chunks_generated >= CHUNK_GEN_MAX_PER_FRAME) break;
        
        var _inst = ds_priority_delete_min(_queue);
        
        if (!instance_exists(_inst)) continue;
        
        // Clear queued flag
        _inst.boolean &= ~CHUNK_BOOLEAN.QUEUED;
        
        // Skip if already generated
        if (_inst.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        
        // Generate the chunk (just creates tile data, doesn't connect)
        with (_inst)
        {
            chunk_generate();
            
            boolean |= CHUNK_BOOLEAN.GENERATED | CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
            
            // Trigger global lighting refresh
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        }
        
        // Queue for deferred tile processing
        array_push(global.chunk_tile_process_queue, _inst);
        
        _chunks_generated++;
    }
}

/// @function chunk_tile_process_queue_process()
/// @desc Process deferred tile instance creation and connection
function chunk_tile_process_queue_process()
{
    var _queue = global.chunk_tile_process_queue;
    
    if (array_length(_queue) == 0) exit;
    
    var _start_time = get_timer();
    var _budget_us = CHUNK_TILE_PROCESS_BUDGET_MS * 1000;
    var _item_data = global.item_data;
    
    while (array_length(_queue) > 0)
    {
        // Check time budget
        if ((get_timer() - _start_time) > _budget_us) break;
        
        var _inst = _queue[0];
        
        if (!instance_exists(_inst))
        {
            array_delete(_queue, 0, 1);
            continue;
        }
        
        // Process tile instances for this chunk
        with (_inst)
        {
            var _chunk = chunk;
            
            for (var _tile_z = 0; _tile_z < CHUNK_DEPTH; ++_tile_z)
            {
                if !(chunk_display & (1 << _tile_z)) continue;
                
                for (var _tile_y = 0; _tile_y < CHUNK_SIZE; ++_tile_y)
                {
                    for (var _tile_x = 0; _tile_x < CHUNK_SIZE; ++_tile_x)
                    {
                        var _world_x = chunk_xstart + _tile_x;
                        var _world_y = chunk_ystart + _tile_y;
                        
                        var _tile = _chunk[tile_index_xyz(_tile_x, _tile_y, _tile_z)];
                        
                        if (_tile == TILE_EMPTY) continue;
                        
                        tile_instance_create(_world_x, _world_y, _tile_z, _tile);
                        tile_connect(_world_x, _world_y, _tile_z, _tile);
                    }
                }
            }
        }
        
        // Mark chunk as ready for rendering
        _inst.boolean |= CHUNK_BOOLEAN.TILE_PROCESSED;
        
        array_delete(_queue, 0, 1);
    }
}

/// @function chunk_queue_clear()
/// @desc Clear the chunk generation queue
function chunk_queue_clear()
{
    // Clear queued flags from all chunks in queue
    while (!ds_priority_empty(global.chunk_gen_queue))
    {
        var _inst = ds_priority_delete_min(global.chunk_gen_queue);
        
        if (instance_exists(_inst))
        {
            _inst.boolean &= ~CHUNK_BOOLEAN.QUEUED;
        }
    }
}

/// @function chunk_queue_destroy()
/// @desc Destroy the chunk generation queue
function chunk_queue_destroy()
{
    chunk_queue_clear();
    ds_priority_destroy(global.chunk_gen_queue);
}
