function ItemTileCondition() : ItemCondition() constructor
{
    static set_level = function(_level)
    {
        if (_level != undefined)
        {
            ___level = _level;
        }
        
        return self;
    }
    
    static get_level = function()
    {
        return self[$ "___level"];
    }
}