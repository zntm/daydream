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
    
    var _data = global.item_data[$ get_id()];
    
    var _durability = _data.get_item_durability();
    
    if (_durability != undefined)
    {
        ___durability = _durability.get_amount();
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
        self[$ "___component_length"] ??= 0;
        
        ___component[$ _name] = _name;
        
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
    
    static get_components_names = function(_name)
    {
        var _component = self[$ "___component"];
        
        if (_component == undefined)
        {
            return undefined;
        }
        
        return struct_get_names(_component);
    }
    
    static get_components_length = function()
    {
        return self[$ "___component_length"] ?? 0;
    }
    
    var _inventory_length = _data.get_item_inventory_length();
    
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
}