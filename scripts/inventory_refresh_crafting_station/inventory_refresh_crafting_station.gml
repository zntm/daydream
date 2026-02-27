global.crafting_stations_distance = {}

function inventory_refresh_crafting_station(_refresh = false)
{
    var _crafting_stations = global.crafting_stations;
    var _crafting_stations_length = array_length(_crafting_stations);
    
    var _previously_available = {}
    
    for (var i = 0; i < _crafting_stations_length; ++i)
    {
        var _station = _crafting_stations[i];
        
        _previously_available[$ _station] = ((global.crafting_stations_distance[$ _station] ?? infinity) <= TILE_SIZE * 4);
        
        // Reset distance
        global.crafting_stations_distance[$ _station] = infinity;
    }
    
    var _player_x = obj_Player.x;
    var _player_y = obj_Player.y;
    
    var _chunks = chunk_map_get_all();
    var _chunks_length = array_length(_chunks);
    
    for (var i = 0; i < _chunks_length; ++i)
    {
        var _chunk = _chunks[i];
        
        // We can check if chunk is generated but usually pooled chunks are.
        // if !(_chunk.boolean & CHUNK_BOOL.GENERATED) continue; 
        
        var _stations = _chunk.chunk_crafting_stations;
        var _stations_length = array_length(_stations);
        
        for (var j = 0; j < _stations_length; ++j)
        {
            var _station_struct = _stations[j];
            var _id = _station_struct.tile_id;
            
            var _dist = point_distance(_player_x, _player_y, _station_struct.x, _station_struct.y);
            
            if (global.crafting_stations_distance[$ _id] > _dist)
            {
                global.crafting_stations_distance[$ _id] = _dist;
            }
        }
    }
    
    for (var i = 0; i < _crafting_stations_length; ++i)
    {
        var _station = _crafting_stations[i];
        
        var _available_previous = _previously_available[$ _station];
        var _available_current  = (global.crafting_stations_distance[$ _station] <= TILE_SIZE * 4);
        
        if (_available_previous != _available_current)
        {
            _refresh = true;
        }
    }
    
    if (_refresh)
    {
        inventory_refresh_craftable();
    }
}