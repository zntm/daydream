function inventory_includes(_item, _amount, _inventory, _length)
{
	var _count = 0;
	
	for (var i = 0; i < _length; ++i)
	{
		var _slot = _inventory[i];
		
		if (_slot == INVENTORY_EMPTY) continue;
		
		var _item_id = _slot.get_item_id();
		
		if (is_array(_item) ? (!array_contains(_item, _item_id)) : (_item_id != _item)) continue;
		
		_count += _slot.get_amount();
        
        if (_count >= _amount)
        {
            return true;
        }
	}
	
	return (_count >= _amount);
}