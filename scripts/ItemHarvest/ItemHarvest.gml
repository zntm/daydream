function ItemHarvest(_hardness, _level) constructor
{
    ___hardness = _hardness;
    ___level = _level;
    
    static get_hardness = function()
    {
        return ___hardness;
    }
    
    static get_level = function()
    {
        return ___level;
    }
}