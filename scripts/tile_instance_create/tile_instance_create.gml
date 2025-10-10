function tile_instance_create(_x, _y, _z, _tile)
{
    var _item_data = global.item_data;
    
    var _id   = _tile.get_id();
    var _data = _item_data[$ _id];
    
    if (_data.is_crafting_station())
    {
        with (instance_create_layer((_x * TILE_SIZE) + _tile.get_xoffset(), (_y * TILE_SIZE) + _tile.get_yoffset(), "Instances", obj_Tile_Crafting_Station))
        {
            sprite_index = _data.get_sprite();
            
            image_index = _tile.get_index() + _tile.get_index_offset();
            image_angle = _tile.get_rotation();
            
            tile_x = _x;
            tile_y = _y;
            tile_z = _z;
            
            tile_id = _id;
            
            _tile.set_instance_crafting_station(id);
        }
    }
    
    if (_data.get_container_length() > 0)
    {
        with (instance_create_layer((_x * TILE_SIZE) + _tile.get_xoffset(), (_y * TILE_SIZE) + _tile.get_yoffset(), "Instances", obj_Tile_Container))
        {
            sprite_index = _data.get_sprite();
            
            image_index = _tile.get_index() + _tile.get_index_offset();
            image_angle = _tile.get_rotation();
            
            tile_x = _x;
            tile_y = _y;
            tile_z = _z;
            
            tile_id = _id;
            
            _tile.set_instance_container(id);
        }
    }
    
    if (_data.has_light())
    {
        with (instance_create_layer((_x * TILE_SIZE) + _tile.get_xoffset(), (_y * TILE_SIZE) + _tile.get_yoffset(), "Instances", obj_Tile_Light))
        {
            sprite_index = _data.get_sprite();
            
            image_index = _tile.get_index() + _tile.get_index_offset();
            image_angle = _tile.get_rotation();
            
            image_blend = _data.get_light();
            
            tile_x = _x;
            tile_y = _y;
            tile_z = _z;
            
            tile_id = _id;
            
            _tile.set_instance_light(id);
        }
    }
}