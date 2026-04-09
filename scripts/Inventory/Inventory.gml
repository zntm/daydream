function Inventory(_item, _amount = 1) constructor
{
    ___id = _item;
    
    static get_id = function()
    {
        return ___id;
    }
    
    ___amount = _amount;
    
    static set_amount = function(_amount)
    {
        ___amount = _amount;
        
        return self;
    }
    
    static add_amount = function(_amount)
    {
        ___amount += _amount;
        
        return self;
    }
    
    static get_amount = function()
    {
        return self[$ "___amount"];
    }
    
    var _data = global.item_data[$ _item];
    
    if (_data != undefined)
    {
        var _durability = _data.get_item_durability();
        
        if (_durability != undefined)
        {
            ___durability = _durability.get_amount();
        }
    }
    
    static set_durability = function(_durability)
    {
        ___durability = _durability;
        
        return self;
    }
    
    static add_durability = function(_durability)
    {
        ___durability += _durability;
        
        return self;
    }
    
    static get_item_durability = function()
    {
        return self[$ "___durability"];
    }
    
    static set_component = function(_name, _value)
    {
        self[$ "___component"] ??= {}
        
        if (!struct_exists(___component, _name))
        {
            self[$ "___component_length"] = (self[$ "___component_length"] ?? 0) + 1;
        }
        
        ___component[$ _name] = _value;
        
        return self;
    }
    
    static get_component = function(_name)
    {
        var _component = self[$ "___component"];
        
        if (_component == undefined)
        {
            return undefined;
        }
        
        return _component[$ _name];
    }
    
    static get_item_component = function(_name)
    {
        return get_component(_name);
    }
    
    static has_component = function(_name)
    {
        var _component = self[$ "___component"];
        
        return (_component != undefined) && struct_exists(_component, _name);
    }
    
    static remove_component = function(_name)
    {
        var _component = self[$ "___component"];
        
        if (_component == undefined) return self;
        if (!struct_exists(_component, _name)) return self;
        
        struct_remove(_component, _name);
        self[$ "___component_length"] = max(0, (self[$ "___component_length"] ?? 0) - 1);
        
        return self;
    }
    
    static get_components_names = function(_name)
    {
        var _component = self[$ "___component"];
        
        if (_component == undefined)
        {
            return undefined;
        }
        
        return struct_get_names(_component);
    }
    
    static get_component_names = function()
    {
        return get_components_names();
    }
    
    static get_components = function()
    {
        return self[$ "___component"];
    }
    
    static get_item_components = function()
    {
        return get_components();
    }
    
    static get_components_length = function()
    {
        return self[$ "___component_length"] ?? 0;
    }
    
    static get_item_components_length = function()
    {
        return get_components_length();
    }
    
    var _inventory_length = (_data != undefined) ? _data.get_item_inventory_length() : 0;
    
    if (_inventory_length > 0)
    {
        ___inventory = array_create(_inventory_length, INVENTORY_EMPTY);
    }
    
    static set_inventory = function(_inventory)
    {
        ___inventory = _inventory;
        
        return self;
    }
    
    static get_inventory = function()
    {
        return self[$ "___inventory"];
    }
    
    static has_inventory = function()
    {
        var _inventory = self[$ "___inventory"];
        
        return is_array(_inventory) && (array_length(_inventory) > 0);
    }
    
    static get_enchantments = function()
    {
        return get_component("enchantments") ?? [];
    }
    
    static set_enchantments = function(_enchantments)
    {
        set_component("enchantments", _enchantments ?? []);
        
        return self;
    }
    
    static add_enchantment = function(_enchantment)
    {
        var _enchantments = get_enchantments();
        
        array_push(_enchantments, _enchantment);
        set_enchantments(_enchantments);
        
        return self;
    }
    
    static get_enchantment_count = function()
    {
        return array_length(get_enchantments());
    }
}


function inventory_item_get_max_stack(_item)
{
    if (_item == INVENTORY_EMPTY) return 0;
    
    var _data = global.item_data[$ _item.get_id()];
    
    return (_data != undefined) ? max(1, _data.get_inventory_max()) : 1;
}


function inventory_item_has_nested_inventory(_item)
{
    if (_item == INVENTORY_EMPTY) return false;
    
    var _inventory = _item.get_inventory();
    
    return is_array(_inventory) && (array_length(_inventory) > 0);
}


function inventory_item_can_stack(_target_item, _incoming_item)
{
    if (_target_item == INVENTORY_EMPTY) || (_incoming_item == INVENTORY_EMPTY) return false;
    if (_target_item.get_id() != _incoming_item.get_id()) return false;
    
    var _data = global.item_data[$ _target_item.get_id()];
    
    if (_data == undefined) return false;
    if (_data.get_inventory_max() <= 1) return false;
    if (_data.get_item_durability() != undefined) return false;
    if (_target_item.get_components_length() > 0) || (_incoming_item.get_components_length() > 0) return false;
    if (inventory_item_has_nested_inventory(_target_item)) || (inventory_item_has_nested_inventory(_incoming_item)) return false;
    
    return true;
}


function inventory_item_clone(_item, _amount = undefined)
{
    if (_item == INVENTORY_EMPTY) return INVENTORY_EMPTY;
    
    var _clone_amount = (_amount == undefined) ? _item.get_amount() : _amount;
    var _clone = new Inventory(_item.get_id(), _clone_amount);
    
    var _durability = _item.get_item_durability();
    
    if (_durability != undefined)
    {
        _clone.set_durability(_durability);
    }
    
    var _component_names = _item.get_components_names();
    
    if (is_array(_component_names))
    {
        var _component_count = array_length(_component_names);
        
        for (var i = 0; i < _component_count; ++i)
        {
            var _name = _component_names[i];
            _clone.set_component(_name, variable_clone(_item.get_component(_name)));
        }
    }
    
    var _inventory = _item.get_inventory();
    
    if (is_array(_inventory))
    {
        var _inventory_length = array_length(_inventory);
        var _inventory_clone = array_create(_inventory_length, INVENTORY_EMPTY);
        
        for (var i = 0; i < _inventory_length; ++i)
        {
            var _nested = _inventory[i];
            
            if (_nested != INVENTORY_EMPTY)
            {
                _inventory_clone[@ i] = inventory_item_clone(_nested);
            }
        }
        
        _clone.set_inventory(_inventory_clone);
    }
    
    return _clone;
}


function inventory_item_try_insert_into_item(_container_item, _incoming_item)
{
    if (_container_item == INVENTORY_EMPTY) || (_incoming_item == INVENTORY_EMPTY) return false;
    
    var _nested = _container_item.get_inventory();
    
    if (!is_array(_nested)) return false;
    
    var _nested_length = array_length(_nested);
    
    if (_nested_length <= 0) return false;
    
    for (var i = 0; i < _nested_length; ++i)
    {
        var _nested_item = _nested[i];
        
        if (!inventory_item_can_stack(_nested_item, _incoming_item)) continue;
        
        var _max_stack = inventory_item_get_max_stack(_nested_item);
        var _space = _max_stack - _nested_item.get_amount();
        
        if (_space <= 0) continue;
        
        var _move_amount = min(_space, _incoming_item.get_amount());
        
        _nested_item.add_amount(_move_amount);
        _incoming_item.add_amount(-_move_amount);
        
        if (_incoming_item.get_amount() <= 0)
        {
            return true;
        }
    }
    
    for (var i = 0; i < _nested_length; ++i)
    {
        if (_nested[i] != INVENTORY_EMPTY) continue;
        
        var _move_amount = min(_incoming_item.get_amount(), inventory_item_get_max_stack(_incoming_item));
        
        _nested[@ i] = inventory_item_clone(_incoming_item, _move_amount);
        _incoming_item.add_amount(-_move_amount);
        
        if (_incoming_item.get_amount() <= 0)
        {
            return true;
        }
    }
    
    return false;
}


function inventory_mouse_apply_to_slot(_type, _index)
{
    var _mouse_item = global.inventory.mouse.item;
    
    if (_mouse_item == INVENTORY_EMPTY) return false;
    
    var _target_item = global.inventory[$ _type][_index];
    
    if (_target_item == INVENTORY_EMPTY)
    {
        global.inventory[$ _type][@ _index] = _mouse_item;
        global.inventory.mouse.item = INVENTORY_EMPTY;
        
        return true;
    }
    
    if (inventory_item_can_stack(_target_item, _mouse_item))
    {
        var _max_stack = inventory_item_get_max_stack(_target_item);
        var _move_amount = min(_mouse_item.get_amount(), _max_stack - _target_item.get_amount());
        
        if (_move_amount > 0)
        {
            _target_item.add_amount(_move_amount);
            _mouse_item.add_amount(-_move_amount);
            
            if (_mouse_item.get_amount() <= 0)
            {
                global.inventory.mouse.item = INVENTORY_EMPTY;
                
                return true;
            }
        }
    }
    
    if (inventory_item_try_insert_into_item(_target_item, _mouse_item))
    {
        if (_mouse_item.get_amount() <= 0)
        {
            global.inventory.mouse.item = INVENTORY_EMPTY;
        }
        
        return true;
    }
    
    return false;
}
