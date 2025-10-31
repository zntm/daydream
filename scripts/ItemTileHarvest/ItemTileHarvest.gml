function ItemTileParticle(_colours, _frequency) constructor 
{
    ___colours = _colours;
    ___frequency = _frequency;
    
    static get_colours = function()
    {
        return ___colours;
    }
    
    static get_frequency = function()
    {
        return ___frequency;
    }
}

function ItemTileHarvest(_hardness, _level, _particle, _condition = undefined) : ItemHarvest(_hardness, _level) constructor
{
    ___particle = new ItemTileParticle(_particle.colour, _particle.frequency);
    
    if (_condition != undefined)
    {
        ___condition = new ItemCondition()
            .set_id(_condition[$ "id"])
            .set_index(_condition[$ "index"]);
    }
    
    static get_particle = function()
    {
        return ___particle;
    }
    
    static get_condition = function()
    {
        return self[$ "___condition"];
    }
}