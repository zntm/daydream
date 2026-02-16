function control_entity_regeneration(_dt = 1)
{
    if (hp >= hp_max) && (attribute.get_regeneration_amount() > 0)
    {
        return false;
    }
    
    var _regeneration_time = attribute.get_regeneration_time();
    
    if (_regeneration_time == undefined)
    {
        return false;
    }
    
    timer_regeneration -= _dt * (1 + min(0.68, saturation * 0.08));
    
    if (timer_regeneration > 0)
    {
        return false;
    }
    
    timer_regeneration = _regeneration_time;
    
    var _amount = attribute.get_regeneration_amount();
    
    if (_amount != 0)
    {
        control_entity_heal(id, _amount, id);
        
        if (saturation > 0)
        {
            --saturation;
        }
    }
    
    return true;
}