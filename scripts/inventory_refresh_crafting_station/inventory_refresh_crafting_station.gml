global.crafting_stations_distance = {}

function inventory_refresh_crafting_station()
{
	var _crafting_stations = global.crafting_stations;
	var _crafting_stations_length = array_length(_crafting_stations);
	
	var _player_x = obj_Player.x;
	var _player_y = obj_Player.y;
	
    with (obj_Tile_Crafting_Station)
    {
        global.crafting_stations_distance[$ tile_id] = infinity;
    }
    
    with (obj_Tile_Crafting_Station)
    {
        global.crafting_stations_distance[$ tile_id] = min(global.crafting_stations_distance[$ tile_id], point_distance(_player_x, _player_y, x, y));
    }
}