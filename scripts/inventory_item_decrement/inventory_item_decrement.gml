function inventory_item_decrement(_type, _index, _inventory_target = global.inventory, _out_changed_slots = undefined)
{
    _inventory_target[$ _type][_index].add_amount(-1);
    
    if (is_array(_out_changed_slots)) array_push(_out_changed_slots, _index);
    
    if (_inventory_target[$ _type][_index].get_amount() <= 0)
    {
        inventory_delete(_type, _index, _inventory_target, _out_changed_slots);
    }
}