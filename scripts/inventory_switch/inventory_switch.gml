function inventory_switch(_a_type, _a_index, _b_type, _b_index)
{
    if (_a_type == _b_type) && (_a_index == _b_index) exit;
    
    var _item_data = global.item_data;
    
    var _inventory = global.inventory;
    
    var _item_a = _inventory[$ _a_type][_a_index];
    var _item_b = _inventory[$ _b_type][_b_index];
    
    if (_item_a == INVENTORY_EMPTY) || (_item_b == INVENTORY_EMPTY)
    {
        global.inventory[$ _a_type][@ _a_index] = _item_b;
        global.inventory[$ _b_type][@ _b_index] = _item_a;
        
        exit;
    }
    
    var _item_id_a = _item_a.get_item_id();
    var _item_id_b = _item_b.get_item_id();
    
    if (_item_id_a != _item_id_b)
    {
        global.inventory[$ _a_type][@ _a_index] = _item_b;
        global.inventory[$ _b_type][@ _b_index] = _item_a;
        
        exit;
    }
    
    var _data = _item_data[$ _item_id_a];
    
    var _inventory_max = _data.get_inventory_max();
    
    var _amount_a = _item_a.get_amount();
    var _amount_b = _item_b.get_amount();
    
    if (_amount_a + _amount_b <= _inventory_max)
    {
        delete _item_a;
        
        global.inventory[$ _a_type][@ _a_index] = INVENTORY_EMPTY;
        global.inventory[$ _b_type][@ _b_index].add_amount(_amount_a);
        
        exit;
    }
    
    global.inventory[$ _a_type][@ _a_index].set_amount(_inventory_max - _amount_b);
    global.inventory[$ _b_type][@ _b_index].set_amount(_inventory_max);
}