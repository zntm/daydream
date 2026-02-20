function tile_update(_x, _y, _z)
{
    var _world_height = global.world_data[$ global.current_world.dimension].get_world_height();
    
    if (_y < 0) || (_y >= _world_height) exit;
    
    var _chunk = chunk_map_get_by_tile(_x, _y);
    
    if (_chunk == undefined) exit;
    
    var _index = tile_index_xyz(_x, _y, _z);
    
    var _tile = _chunk.chunk[_index];
    
    if (_tile == TILE_EMPTY) exit;
    
    if (!tile_update_placement_condition(_x, _y, _z, _tile))
    {
        var _data = global.item_data[$ _tile.get_id()];
        
        sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _data.get_tile_sfx().get_harvest().get_id(), global.settings.audio_tile);
        
        tile_harvest_drop(_x, _y, _z, _tile);
        
        tile_place(_x, _y, _z, TILE_EMPTY);
        
        tile_update_surrounding(_x, _y, _z);
        
        tile_update_liquid(_x, _y, _z);
        
        var _tile_harvest = _data.get_tile_harvest().get_particle();
        
        var _particle_colour = _tile_harvest.get_colours();
        
        repeat (smart_value(_tile_harvest.get_frequency()))
        {
            spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, "phantasia:tile/harvest", is_array_choose(_particle_colour));
        }
        
        exit;
    }
    
    tile_connect(_x, _y, _z, _tile);
}