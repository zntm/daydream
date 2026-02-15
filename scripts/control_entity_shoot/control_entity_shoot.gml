function control_entity_shoot(_entity, _item_id, _x, _y, _angle, _inventory_target = global.inventory, _out_changed_slots = undefined, _power = 1.0)
{
    var _data = global.item_data[$ _item_id];
    
    if (_data == undefined) exit;
    
    var _projectile_id = _data.get_item_projectile();
    var _ammo_type = _data.get_item_ammo_requirement();
    var _damage_bonus = 0;
    
    // If we need ammo and this is a player
    if (_ammo_type != undefined) && (_entity.object_index == obj_Player)
    {
        var _ammo_found_index = -1;
        var _ammo_item = undefined;
        
        // Search inventory for matching ammo
        var _inventory_base = _inventory_target.base;
        var _inventory_length_base = array_length(_inventory_base);
        
        for (var i = 0; i < _inventory_length_base; ++i)
        {
            var _item = _inventory_base[i];
            
            if (_item == INVENTORY_EMPTY) continue;
            
            var _item_data = global.item_data[$ _item.get_id()];
            
            if (_item_data.get_item_ammo_type() == _ammo_type)
            {
                _ammo_found_index = i;
                _ammo_item = _item;
                
                // If the ammo itself has a projectile definition, use it!
                // This allows "bow" to shoot generic arrows, but the specific arrow item defines the projectile "arrow_fire"
                var _ammo_proj = _item_data.get_item_projectile();
                if (_ammo_proj != undefined)
                {
                    _projectile_id = _ammo_proj;
                }
                
                // Add ammo damage to weapon damage?
                _damage_bonus += _item_data.get_item_damage();
                
                break;
            }
        }
        
        if (_ammo_found_index == -1)
        {
            // No ammo found
            return false;
        }
        
        // Consume ammo
        inventory_item_decrement("base", _ammo_found_index, _inventory_target, _out_changed_slots);
    }
    
    // If we have a projectile to shoot
    if (_projectile_id != undefined)
    {
        var _p_data = global.projectile_data[$ _projectile_id];
        var _max_speed = smart_value(_p_data.get_xspeed());
        if (_max_speed == 0) _max_speed = 5;
        
        var _speed = _max_speed * _power;
        
        // Recalculate aim angle from spawn point to mouse for accuracy
        var _aim_angle = _angle;
        if (instance_exists(_entity) && _entity.object_index == obj_Player)
        {
            var _dx = mouse_x - _x;
            var _dy = mouse_y - _y;
            var _dist_sq = _dx*_dx + _dy*_dy;
            
            if (_dist_sq > 1)
            {
                var _dist = sqrt(_dist_sq);
                var _g = _p_data.get_gravity();
                
                // If there's gravity, solve for trajectory angle
                if (_g != 0)
                {
                    // A*tan^2 + B*tan + C = 0
                    // A = g*dx^2 / 2v^2, B = dx, C = A - dy
                    // Using abs(dx) to simplify and then adjusting sign
                    var _adx = abs(_dx);
                    var _v2 = _speed * _speed;
                    var _a = (_g * _adx * _adx) / (2 * _v2);
                    var _b = _adx;
                    var _c = _a - _dy;
                    
                    var _d = _b*_b - 4*_a*_c;
                    
                    if (_d >= 0)
                    {
                        // Use the solution that points "up" more (lower arc for y-down GML)
                        var _tan = (-_b + sqrt(_d)) / (2 * _a);
                        _aim_angle = radtodeg(arctan2(_tan, 1));
                        
                        // Flip if shooting left
                        if (_dx < 0) _aim_angle = 180 - _aim_angle;
                    }
                    else
                    {
                        // Target out of reach, fall back to direct aim
                        _aim_angle = point_direction(_x, _y, mouse_x, mouse_y);
                    }
                }
                else
                {
                    _aim_angle = point_direction(_x, _y, mouse_x, mouse_y);
                }
            }
        }
        
        // Velocity-based damage formula:
        // damage = max(min_damage, launcher_mult * ammo_damage * power(velocity / max_velocity, exp_curve))
        var _launcher_mult = _data.get_item_damage();
        var _ammo_damage = _damage_bonus;
        var _exp_curve = 1.5;
        var _min_damage = 1;
        var _velocity_ratio = clamp(_speed / _max_speed, 0, 1);
        
        var _damage = max(_min_damage, _launcher_mult * _ammo_damage * power(_velocity_ratio, _exp_curve));
        
        var _inst = spawn_projectile(_x, _y, _projectile_id, _damage, 1, 1, _entity);
        
        with (_inst)
        {
            physics_body.vel_x = lengthdir_x(_speed, _aim_angle);
            physics_body.vel_y = lengthdir_y(_speed, _aim_angle);
            
            image_angle = _aim_angle;
        }
        
        var _event = new EventDataProjectileShoot(_entity, _inst, _x, _y, _aim_angle, _damage);
        
        event_emit(_event);
        
        return true;
    }
    
    return false;
}
