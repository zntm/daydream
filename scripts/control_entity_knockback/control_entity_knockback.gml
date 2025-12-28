/// @description Realistic physics-based knockback handler using new physics system
/// @param {Id.Instance} _victim The entity being knocked back
/// @param {Id.Instance} _attacker The entity applying knockback
/// @param {Real} _base_knockback_x Base horizontal knockback strength (default 5.2)
/// @param {Real} _base_knockback_y Base vertical knockback strength (default 0.6)
/// @param {Real} _velocity_multiplier How much attacker velocity affects knockback (default 0.5)

function control_entity_knockback(_victim, _attacker, _base_knockback_x = 5.2, _base_knockback_y = 0.6, _velocity_multiplier = 0.5)
{
    // Calculate knockback direction
    var _direction_x = sign(_victim.x - _attacker.x);
    var _direction_y = sign(_victim.y - _attacker.y);
    
    if (_direction_x == 0)
    {
        _direction_x = choose(-1, 1);
    }
    
    // Get attacker's velocity for realistic physics
    var _attacker_xvel = 0;
    var _attacker_yvel = 0;
    
    if (variable_instance_exists(_attacker, "physics_body"))
    {
        _attacker_xvel = _attacker.physics_body.vel_x;
        _attacker_yvel = _attacker.physics_body.vel_y;
    }
    
    // Calculate velocity-based knockback bonus
    var _velocity_bonus_x = abs(_attacker_xvel) * _velocity_multiplier;
    var _velocity_bonus_y = abs(_attacker_yvel) * _velocity_multiplier * 0.3;
    
    // Apply knockback to victim's physics body
    if (variable_instance_exists(_victim, "physics_body"))
    {
        _victim.physics_body.vel_x = (_base_knockback_x + _velocity_bonus_x) * _direction_x;
        _victim.physics_body.vel_y = -(_base_knockback_y + _velocity_bonus_y);
        
        if (_attacker_yvel > 0)
        {
            _victim.physics_body.vel_y += _attacker_yvel * _velocity_multiplier * 0.5;
        }
    }
}