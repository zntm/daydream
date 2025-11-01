function ItemArmor(_type, _defense) constructor
{
    static __type = global.item_armor_type;
    
    ___type = __type[$ _type];
    ___defense = _defense;
    
    static get_type = function()
    {
        return ___type;
    }
    
    static get_defense = function()
    {
        return ___defense;
    }
    
    static set_attributes = function(_attributes)
    {
        ___attributes = _attributes;
        
        return self;
    }
    
    static get_attributes = function()
    {
        return self[$ "___attributes"];
    }
}