function inventory_delete(_type, _index, _inventory_target = global.inventory, _out_changed_slots = undefined)
{
    delete _inventory_target[$ _type][_index];
    
    _inventory_target[$ _type][@ _index] = INVENTORY_EMPTY;
    
    if (is_array(_out_changed_slots)) array_push(_out_changed_slots, _index);
}