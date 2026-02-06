function control_entity_suffocation(_entity)
{
    // Skip if entity is dead or doesn't exist
    if (!instance_exists(_entity) || _entity.hp <= 0) exit;
    
    // Define suffocation points (head/center)
    var _attribute = _entity.attribute;
    
    var _x = _entity.x;
    var _y = _entity.y - ((_attribute.get_collision_box_height() - _attribute.get_eye_level()) * _entity.entity_yscale);
    
    // Check if we are inside a solid block
    // We check the default layer (ground) and wall layer
    if (!tile_rectangle_meeting(bbox_left, bbox_top, bbox_right, _y))
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
    }
}
