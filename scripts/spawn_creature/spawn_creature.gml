function spawn_creature(_x, _y, _id, _variant)
{
    randomize();
    
    var _data = global.creature_data[$ _id];
    
    var _hp = _data.get_hp();
    
    var _inst = instance_create_layer(_x, _y, "Instances", obj_Creature);
    
    with (_inst)
    {
        id._id = _id;
        
        if (_variant != undefined)
        {
            variant = smart_value(_variant);
        }
        
        init_entity(_hp, _hp, _data.get_attribute());
        
        var _interval = _data.get_sfx_interval();
        
        if (_interval != undefined)
        {
            timer_sfx_idle = smart_value(_interval);
        }
        
        inst_predator = noone;
        timer_panic = 0;
    }
    
    return _inst;
}