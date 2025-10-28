function ItemCondition() constructor
{
    static set_id = function(_id)
    {
        if (_id != undefined)
        {
            ___id = _id;
        }
        
        return self;
    }
    
    static get_id = function()
    {
        return self[$ "___id"];
    }
    
    static set_index = function(_index)
    {
        if (_index != undefined)
        {
            ___index = _index;
        }
        
        return self;
    }
    
    static get_index = function()
    {
        return self[$ "___index"];
    }
}