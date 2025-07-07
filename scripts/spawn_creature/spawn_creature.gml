function spawn_creature(_x, _y, _id, _variant)
{
    randomize();
    
    var _data = global.creature_data[$ _id];
    
    var _hp = _data.get_hp();
    
    with (instance_create_layer(_x, _y, "Instances", obj_Creature))
    {
        id._id = _id;
        
        if (_variant != undefined)
        {
            variant = smart_value(_variant);
        }
        
        init_entity(_hp, _hp, _data.get_attribute());
        
        uuid = uuid_generate(random_get_seed());
    }
}