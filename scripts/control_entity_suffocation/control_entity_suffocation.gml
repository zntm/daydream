function control_entity_suffocation(_entity)
{
    if (!instance_exists(_entity) || _entity.hp <= 0) exit;
    
    var _attribute = _entity.attribute;
    
    var _x = _entity.x;
    var _y = _entity.y - ((_attribute.get_collision_box_height() - _attribute.get_eye_level()) * _entity.entity_yscale);
    
    if (!tile_rectangle_meeting(bbox_left, bbox_top, bbox_right, _y))
    {
        _entity.timer_suffocation = 0;
        
        exit;
    }
    
    _entity.timer_suffocation += 1;
    
    if (_entity.timer_suffocation % 60 == 0)
    {
        var _damage = 2;
        
        spawn_floating_text(_x, _y - 12, _damage, 0, -2, 0.5, 0.5, 0, c_red);
    }
}
