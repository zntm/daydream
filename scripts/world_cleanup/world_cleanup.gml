/// @function world_cleanup()
/// @desc Cleanup all world state when exiting a world or changing dimensions
/// Call this before transitioning away from rm_World or when reconnecting with a new seed
function world_cleanup()
{
    show_debug_message("[WORLD_CLEANUP] Starting world cleanup...");
    
    // 1. Flush any pending chunk saves
    if (variable_global_exists("chunk_save_queue"))
    {
        chunk_save_queue_flush();
        chunk_save_queue_clear();
    }
    
    // 2. Clear chunk generation queue
    if (variable_global_exists("chunk_gen_queue"))
    {
        chunk_queue_clear();
    }
    global.chunk_tile_process_queue = [];
    
    // 3. Clear all chunks - this releases vertex buffers and surfaces
    var _chunks = chunk_map_get_all();
    var _chunk_count = array_length(_chunks);
    
    for (var i = 0; i < _chunk_count; ++i)
    {
        var _chunk = _chunks[i];
        global.chunk_pool.on_release(_chunk);
    }
    
    show_debug_message($"[WORLD_CLEANUP] Released {_chunk_count} chunks");
    
    // 4. Clear chunk map
    chunk_map_clear();
    
    // 5. Clear chunk pool completely
    global.chunk_pool.pool = [];
    global.chunk_pool.fading_chunks = [];
    
    // 6. Clear structure pool
    var _structure_count = array_length(global.structure_pool.active_structures);
    global.structure_pool.active_structures = [];
    global.structure_pool.pool = [];
    
    show_debug_message($"[WORLD_CLEANUP] Cleared {_structure_count} active structures");
    
    // 7. Invalidate worldgen context (will be recreated on next chunk gen)
    if (variable_global_exists("worldgen_context"))
    {
        global.worldgen_context = undefined;
    }
    
    // 8. Reset chunk_in_view array on Game Control if it exists
    if (instance_exists(obj_Game_Control))
    {
        obj_Game_Control.chunk_in_view_length = 0;
    }
    
    // 9. Clear structure spawn tracking map (ds_map of ds_maps)
    if (variable_global_exists("worldgen_structure"))
    {
        // Destroy nested ds_maps first
        var _key = ds_map_find_first(global.worldgen_structure);
        while (_key != undefined)
        {
            var _nested = global.worldgen_structure[? _key];
            if (ds_exists(_nested, ds_type_map))
            {
                ds_map_destroy(_nested);
            }
            _key = ds_map_find_next(global.worldgen_structure, _key);
        }
        ds_map_clear(global.worldgen_structure);
    }
    
    show_debug_message("[WORLD_CLEANUP] World cleanup complete");
}
