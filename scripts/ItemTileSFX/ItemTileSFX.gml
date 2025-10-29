function ItemTileSFX(_build, _harvest, _step) constructor
{
    ___build = _build;
    
    static get_build = function()
    {
        return ___build;
    }
    
    ___harvest = _harvest;
    
    static get_harvest = function()
    {
        return ___harvest;
    }
    
    ___step = _step;
    
    static get_step = function()
    {
        return ___step;
    }
}