function tile_condition_connected(_x, _y, _z, _id, _data, _item_data, _world_height)
{
	var _tile = tile_get(_x, _y, _z);
	
	if (_tile == TILE_EMPTY)
	{
		return 0;
	}
    
	if (_id == _tile.get_id())
	{
		return 1;
	}
    
    var _data2 = _item_data[$ _id];
	
	return _data.has_type(_data2.get_type());
	// return (_data.has_type(_data2.get_type())) && (_data2.boolean & ITEM_BOOLEAN.CAN_CONNECT);
}