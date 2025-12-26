function control_entity_suffocation(_entity)
{
    // Skip if entity is dead or doesn't exist
    if (!instance_exists(_entity) || _entity.hp <= 0) exit;
    
    // Define suffocation points (head/center)
    var _x = _entity.x;
    var _y = _entity.y - (_entity.sprite_height / 2); // Roughly center/head area
    
    // Check if we are inside a solid block
    // We check the default layer (ground) and wall layer
    if (!tile_meeting(_x, _y))
    {
        _entity.timer_suffocation = 0;
        
        exit;
    }
    
    _entity.timer_suffocation += 1;
    
    // Damage every 1 second (approx 60 frames)
    if (_entity.timer_suffocation % 60 == 0)
    {
        // Apply damage
        var _damage = 2; // Fixed damage amount?
        
        spawn_floating_text(_x, _y - 12, _damage, 0, -2, 0.5, 0.5, 0, c_red);
        
        // Visual feedback
        spawn_floating_text(_x, _y - 12, _damage, 0, -2, c_red);
    }
}
