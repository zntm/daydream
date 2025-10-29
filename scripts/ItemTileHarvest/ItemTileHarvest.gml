function ItemTileParticle(_id, _frequency) constructor 
{
    ___id = _id;
    ___frequency = _frequency;
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_frequency = function()
    {
        return ___id;
    }
}

function ItemTileHarvest(_hardness, _level, _particle, _condition = undefined) : ItemHarvest(_hardness, _level) constructor
{
    ___particle = _particle;
    
    static get_particle = function()
    {
        return ___particle;
    }
    
    ___condition = _condition;
    
    static get_condition = function()
    {
        return ___condition;
    }
}