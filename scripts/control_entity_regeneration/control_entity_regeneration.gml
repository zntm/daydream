function control_entity_regeneration(_dt)
{
    if (hp < hp_max)
    {
        var _regeneration_time = attribute.get_regeneration_time();
        
        if (_regeneration_time != undefined)
        {
            timer_regeneration -= _dt * (1 + min(0.68, saturation * 0.08));
            
            if (timer_regeneration <= 0)
            {
                timer_regeneration = _regeneration_time;
                
                hp += attribute.get_regeneration_amount();
                
                if (saturation > 0)
                {
                    --saturation;
                }
                
                return true;
            }
        }
    }
    
    return false;
}