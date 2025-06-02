function Inventory(_item, _amount = 1) constructor
{
    ___item_id = _item;
    
    static get_item_id = function()
    {
        return ___item_id;
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
    
    var _data = global.item_data[$ get_item_id()];
    
    var _durability = round(_data.get_durability_amount() / 2);
    
    if (_durability > 0)
    {
        ___durability = _durability;
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
    
    static get_durability = function()
    {
        return self[$ "___durability"];
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