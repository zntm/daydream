function tile_instance_create(_x, _y, _z, _tile, _chunk = undefined)
{
    if (_chunk == undefined)
    {
        _chunk = chunk_map_get_by_tile(_x, _y);
        
        if (_chunk == undefined) exit;
    }
    
    var _item_data = global.item_data;
    
    var _id   = _tile.get_id();
    var _data = _item_data[$ _id];
    
    // Common properties for all pooled objects
    // We create a new struct for each type to emulate the old object behavior
    // These behave like lightweight objects
    
    if (_data.is_crafting_station())
    {
        var _struct = {
            sprite_index: global.sprite_asset[$ _data.get_sprite()].get_sprite(),
            image_index: _tile.get_index() + _tile.get_index_offset(),
            image_angle: _tile.get_rotation(),
            
            x: (_x * TILE_SIZE) + _tile.get_xoffset(), 
            y: (_y * TILE_SIZE) + _tile.get_yoffset(),
            
            tile_x: _x,
            tile_y: _y,
            tile_z: _z,
            
            tile_id: _id
        }
        
        array_push(_chunk.chunk_crafting_stations, _struct);
        _tile.set_instance_crafting_station(_struct);
    }
    
    if (_data.get_container_length() > 0)
    {
        var _struct = {
            sprite_index: global.sprite_asset[$ _data.get_sprite()].get_sprite(),
            image_index: _tile.get_index() + _tile.get_index_offset(),
            image_angle: _tile.get_rotation(),
            
            x: (_x * TILE_SIZE) + _tile.get_xoffset(), 
            y: (_y * TILE_SIZE) + _tile.get_yoffset(),
            
            tile_x: _x,
            tile_y: _y,
            tile_z: _z,
            
            tile_id: _id
        }
        
        array_push(_chunk.chunk_containers, _struct);
        _tile.set_instance_container(_struct);
    }
    
    if (_data.has_light())
    {
        var _struct = {
            sprite_index: global.sprite_asset[$ _data.get_sprite()].get_sprite(),
            image_index: _tile.get_index() + _tile.get_index_offset(),
            image_angle: _tile.get_rotation(),
            image_blend: _data.get_light(),
            
            x: (_x * TILE_SIZE) + _tile.get_xoffset(), 
            y: (_y * TILE_SIZE) + _tile.get_yoffset(),
            
            tile_x: _x,
            tile_y: _y,
            tile_z: _z,
            
            tile_id: _id
        }
        
        array_push(_chunk.chunk_lights, _struct);
        _tile.set_instance_light(_struct);
    }
}