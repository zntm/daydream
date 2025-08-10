function inventory_resize(_type, _value)
{
    var _inventory = global.inventory[$ _type];
    var _inventory_instance = global.inventory_instance[$ _type];
    
    var _length = array_length(_inventory);
    
    for (var i = _value; i < _length; ++i)
    {
        var _item = _inventory[i];
        
        if (_item != INVENTORY_EMPTY)
        {
            delete _item;
        }
        
        var _inst = _inventory_instance[i];
        
        if (instance_exists(_inst))
        {
            instance_destroy(_inst);
        }
    }
    
    array_resize(global.inventory[$ _type], _value);
    array_resize(global.inventory_instance[$ _type], _value);
    
    global.inventory_length[$ _type] = _value;
}