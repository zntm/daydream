/// @function inventory_transfer(_source_name, _source_index, _target_name, _amount = -1)
/// @desc Transfers an item from one inventory slot to a target inventory pool
function inventory_transfer(_source_name, _source_index, _target_name, _amount = -1)
{
    var _inv = global.inventory;
    var _source_list = _inv[$ _source_name];
    var _target_list = _inv[$ _target_name];
    
    if (_source_list == undefined || _target_list == undefined) return false;
    
    var _item = _source_list[_source_index];
    if (_item == INVENTORY_EMPTY) return false;
    
    var _item_id_src = _item.get_id();
    var _item_max_stack = 64; // Default, should get from item data
    var _item_data = global.item_data[$ _item_id_src];
    if (_item_data != undefined) _item_max_stack = _item_data.get_inventory_max();
    
    // Logic:
    // 1. Try to stack with existing items in target
    // 2. Try to fill empty slots in target
    
    var _transferred = false;
    var _length = array_length(_target_list);
    
    // 1. Stack
    for (var i = 0; i < _length; ++i)
    {
        var _target_item = _target_list[i];
        if (_target_item == INVENTORY_EMPTY) continue;
        
        if (inventory_item_can_stack(_target_item, _item))
        {
            var _current_amount = _target_item.get_amount();
            if (_current_amount < _item_max_stack)
            {
                var _transfer_amount = min(_item.get_amount(), _item_max_stack - _current_amount);
                
                _target_item.set_amount(_current_amount + _transfer_amount);
                _item.set_amount(_item.get_amount() - _transfer_amount);
                
                _transferred = true;
                
                if (_item.get_amount() <= 0) break;
            }
        }
    }
    
    // 2. Fill Empty
    if (_item.get_amount() > 0)
    {
        for (var i = 0; i < _length; ++i)
        {
            if (_target_list[i] == INVENTORY_EMPTY)
            {
                _target_list[@ i] = _item; // Move reference
                _source_list[@ _source_index] = INVENTORY_EMPTY; // Clear source
                _transferred = true;
                break;
            }
        }
    }
    else
    {
        _source_list[@ _source_index] = INVENTORY_EMPTY;
    }
    
    return _transferred;
}
