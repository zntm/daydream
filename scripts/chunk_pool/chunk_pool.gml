/// @desc Chunk pooling system to reduce memory allocation overhead
/// Recycles chunks instead of creating/destroying them

// Note: Ensure Pool script is loaded before this or in same group
function ChunkPool() : Pool() constructor
{
    max_size = 32;
    
    static create = function()
    {
        // Must be created at 0,0 initially, will be moved
        return instance_create_layer(0, 0, "Instances", obj_Chunk);
    }
    
    static reset = function(_inst, _x, _y)
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
            
            global.render_state_pool.clear_list(chunk_render_state);
            
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

    static acquire = function(_x, _y)
    {
        var _inst = get_free_item();
        
        // Reactivate and reset the chunk
        instance_activate_object(_inst);
        reset(_inst, _x, _y);
        
        return _inst;
    }
    
    static on_release = function(_inst)
    {
        if (!instance_exists(_inst)) return;
        
        // Unregister from map
        chunk_map_unregister(_inst);
        
        // Clean render states
        if (variable_instance_exists(_inst, "chunk_render_state") && is_array(_inst.chunk_render_state))
        {
            global.render_state_pool.clear_list(_inst.chunk_render_state);
        }
        
        // Clear vertex buffers
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
        
        // Deactivate
        instance_deactivate_object(_inst);
    }
    
    static destroy = function(_inst)
    {
        if (instance_exists(_inst))
        {
            instance_destroy(_inst);
        }
    }
    
    // Override release to check capacity
    static release = function(_inst)
    {
        if (!instance_exists(_inst)) return;
        
        if (array_length(pool) < max_size)
        {
            on_release(_inst);
            array_push(pool, _inst);
        }
        else
        {
            // Pool full - proper cleanup is still needed inside on_release logic?
            // Actually, if we destroy it, standard Destroy Event might handle some things?
            // But checking manual cleanup:
            chunk_map_unregister(_inst); // Ensure map is clean
            // Render state pool cleanup might be needed if not done in Destroy event
             if (variable_instance_exists(_inst, "chunk_render_state") && is_array(_inst.chunk_render_state))
            {
                global.render_state_pool.clear_list(_inst.chunk_render_state);
            }
            
            instance_destroy(_inst);
        }
    }
}

global.chunk_pool = new ChunkPool();


