function ItemTileParticle(_colours, _frequency) constructor 
{
    ___colours = [];
    
    if (_colours != undefined)
    {
        var _length = array_length(_colours);
        
        for (var i = 0; i < _length; ++i)
        {
            array_push(___colours, hex_parse(_colours[i]));
        }
    }
    
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
    var _colours = _particle[$ "id"] ?? _particle[$ "colour"];
    ___particle = new ItemTileParticle(_colours, smart_value_parse(_particle.frequency));
    
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