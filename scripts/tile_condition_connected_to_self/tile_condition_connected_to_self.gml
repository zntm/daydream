function tile_condition_connected_to_self(_x, _y, _z, _id, _data, _item_data, _world_height)
{
	var _tile = tile_get(_x, _y, _z);
	
    return (_tile != TILE_EMPTY) && (_id == _tile.get_id());
}