/// @desc Spawn a projectile instance.
/// @param {Real} _x            X position (world pixels).
/// @param {Real} _y            Y position (world pixels).
/// @param {String} _id         Projectile data ID (e.g. "phantasia:arrow").
/// @param {Real} _damage       Damage value.
/// @param {Real} [_xscale]     Horizontal direction scale.
/// @param {Real} [_yscale]     Vertical direction scale.
/// @param {Id.Instance} [_owner]   Owner instance.
/// @param {Real} [_target_x]   Optional aim target X (world pixels). Enables trajectory solving.
/// @param {Real} [_target_y]   Optional aim target Y (world pixels).
/// @param {Real} [_power]      Speed multiplier (0..1 from charge).
function spawn_projectile(_x, _y, _id, _damage, _xscale = 1, _yscale = 1, _owner = noone, _target_x = undefined, _target_y = undefined, _power = 1.0)
{
    var _data = global.projectile_data[$ _id];
    
    with (instance_create_layer(_x, _y, "Instances", obj_Projectile))
    {
        id._id = _id;
        damage = _damage;
        owner  = _owner;
        
        entity_xscale = 1;
        entity_yscale = 1;
        
        /* attribute & physics body */
        attribute    = _data.get_attribute();
        physics_body = new PhysicsBody(attribute);
        
        physics_body.pos_x = x;
        physics_body.pos_y = y;
        
        var _s = smart_value(_data.get_scale());
        physics_body.scale_x = _s * _xscale;
        physics_body.scale_y = _s * _yscale;
        
        image_xscale = physics_body.scale_x;
        image_yscale = physics_body.scale_y;
        
        var _max_speed = smart_value(_data.get_speed());
        
        var _speed = _max_speed * _power;
        
        var _aim_angle = (_xscale >= 0) ? 0 : 180;
        
        if (_target_x != undefined) && (_target_y != undefined)
        {
            var _dx = _target_x - _x;
            var _dy = _target_y - _y;
            
            var _g = _data.get_gravity();
            
            /*
            * ballistic arc: solve for launch angle so the trajectory
            * passes through (_target_x, _target_y).
            *
            * a * tan^2(θ) + b * tan(θ) + c = 0
            * a = g * dx^2 / (2 * v^2)
            * b = dx
            * c = a - dy
            */
            var _adx = abs(_dx);
            var _v2  = _speed * _speed;
            var _a   = (_g * _adx * _adx) / (2 * _v2);
            var _b   = _adx;
            var _c   = _a - _dy;
            var _d   = _b * _b - 4 * _a * _c;
            
            if (_d >= 0)
            {
                /* pick the low-arc solution */
                var _tan = (-_b + sqrt(_d)) / (2 * _a);
                _aim_angle = radtodeg(arctan2(_tan, 1));
                
                if (_dx < 0)
                {
                    _aim_angle = 180 - _aim_angle;
                }
            }
            else
            {
                /* target out of range, fall back to direct aim */
                _aim_angle = point_direction(_x, _y, _target_x, _target_y);
            }
        }
        
        physics_body.vel_x = lengthdir_x(_speed, _aim_angle);
        physics_body.vel_y = lengthdir_y(_speed, _aim_angle);
        
        /* rotation */
        rotation_increment = smart_value(_data.get_rotation_increment());
        image_angle        = _aim_angle;
        
        /* lifetime */
        timer_life     = smart_value(_data.get_lifetime());
        timer_life_max = timer_life;
        
        /* interpolation state (networking) */
        interp_start_x  = x;
        interp_start_y  = y;
        interp_target_x = x;
        interp_target_y = y;
        interp_timer    = 0;
        interp_duration = 0.05;
        
        /* on-shoot particles */
        var _particles = _data.get_particles();
        
        if (_particles != undefined)
        {
            for (var i = array_length(_particles) - 1; i >= 0; --i)
            {
                var _p = _particles[i];
                
                if (_p.mode == PROJECTILE_PARTICLE_MODE.SHOOT)
                {
                    spawn_particle(x + _p.offset_x, y + _p.offset_y, _p.id);
                }
            }
        }
        
        /* on-shoot proglang hooks */
        var _on_shoot = _data.get_on_shoot();
        
        if (_on_shoot != undefined)
        {
            for (var i = array_length(_on_shoot) - 1; i >= 0; --i)
            {
                function_execute(_on_shoot[i], x, y, CHUNK_DEPTH_DEFAULT, _xscale, _yscale, id, _owner);
            }
        }
        
        return id;
    }
}