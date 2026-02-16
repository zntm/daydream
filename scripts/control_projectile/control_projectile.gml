/// @desc Projectile control using new physics system
/// @param {Real} _dt Delta time

function control_projectile(_dt = 1.0)
{
    // --- REMOTE PROJECTILES ON CLIENT (INTERPOLATION) ---
    if (global.network_role == RELAY_ROLE.CLIENT)
    {
        if (variable_instance_exists(self, "interp_start_x"))
        {
            interp_timer += _dt / GAME_TICK;
            var _t = clamp(interp_timer / interp_duration, 0, 1);
            
            x = lerp(interp_start_x, interp_target_x, _t);
            y = lerp(interp_start_y, interp_target_y, _t);
            
            // Auto-rotate towards movement
            if (interp_target_x != interp_start_x || interp_target_y != interp_start_y)
            {
                image_angle = point_direction(interp_start_x, interp_start_y, interp_target_x, interp_target_y);
            }
        }
        exit;
    }
    
    timer_life -= _dt / GAME_TICK;
    
    if (timer_life <= 0)
    {
        instance_destroy();
        exit;
    }
    
    var _data = global.projectile_data[$ _id];
    
    // --- Particles ---
    var _particles = _data.get_particles();
    if (_particles != undefined)
    {
        for (var i = array_length(_particles) - 1; i >= 0; i--)
        {
            var _p = _particles[i];
            if (chance((_p[$ "frequency"] ?? 0.1) * _dt))
            {
                spawn_particle(x + (_p[$ "offset_x"] ?? 0), y + (_p[$ "offset_y"] ?? 0), _p.id);
            }
        }
    }
    
    // --- Entity Collision ---
    if (damage > 0)
    {
        var _inst = instance_place(x, y, obj_Creature);
        
        if (instance_exists(_inst) && _inst.hp > 0)
        {
            control_entity_damage(_inst, (owner != undefined) ? owner : id, damage);
            
            event_emit(new EventDataProjectileLand(id, x, y, _inst, "entity"));
            
            // Proglang Hooks
            var _on_hit_entity = _data.get_on_hit_entity();
            if (_on_hit_entity != undefined)
            {
                for (var i = array_length(_on_hit_entity) - 1; i >= 0; i--)
                {
                    function_execute(_on_hit_entity[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id, _inst);
                }
            }
            
            var _on_land = _data.get_on_land();
            if (_on_land != undefined)
            {
                for (var i = array_length(_on_land) - 1; i >= 0; i--)
                {
                    function_execute(_on_land[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id, _inst);
                }
            }
            
            if (_data.can_destroy_on_entity_collision())
            {
                instance_destroy();
                exit;
            }
        }
    }
    
    // --- Physics ---
    if (physics_body != undefined && attribute != undefined)
    {
        physics_body.sync_from_instance(id);
        physics_body.reset_collision();
        
        // Apply gravity (Verlet integration part 1)
        var _gravity = attribute.get_gravity();
        if (_gravity != 0)
        {
            physics_body.vel_y += (_gravity * _dt) / 2;
        }
        
        // Resolve collisions
        physics_move_contact_x(physics_body);
        physics_move_contact_y(physics_body);
        
        // Apply gravity (Verlet integration part 2)
        if (_gravity != 0)
        {
            physics_body.vel_y += (_gravity * _dt) / 2;
        }
        
        physics_body.sync_to_instance(id);
        
        // Tile collision behavior
        if (attribute.has_collision_box() && (tile_meeting(x, y - 1) || tile_meeting(x + 1, y) || tile_meeting(x, y + 1) || tile_meeting(x - 1, y)))
        {
            event_emit(new EventDataProjectileLand(id, x, y, undefined, "tile"));
            
            // Proglang Hooks
            var _on_hit_tile = _data.get_on_hit_tile();
            if (_on_hit_tile != undefined)
            {
                for (var i = array_length(_on_hit_tile) - 1; i >= 0; i--)
                {
                    function_execute(_on_hit_tile[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id, undefined);
                }
            }
            
            var _on_land = _data.get_on_land();
            if (_on_land != undefined)
            {
                for (var i = array_length(_on_land) - 1; i >= 0; i--)
                {
                    function_execute(_on_land[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id, undefined);
                }
            }
            
            if (_data.can_destroy_on_tile_collision())
            {
                instance_destroy();
                exit;
            }
            
            if (_data.get_on_collision_xspeed_type() == PROJECTILE_MOVEMENT_TYPE.REFERENCE)
            {
                var _xspeed = world_get_reference(_data.get_on_collision_xspeed());
                physics_body.vel_x = (smart_value(_xspeed) + smart_value(_data.get_on_collision_xspeed_offset())) * smart_value(_data.get_on_collision_xspeed_multiplier());
            }
            else
            {
                physics_body.vel_x = smart_value(_data.get_on_collision_xspeed());
            }
            
            if (_data.get_on_collision_yspeed_type() == PROJECTILE_MOVEMENT_TYPE.REFERENCE)
            {
                var _yspeed = world_get_reference(_data.get_on_collision_yspeed());
                physics_body.vel_y = (smart_value(_yspeed) + smart_value(_data.get_on_collision_yspeed_offset())) * smart_value(_data.get_on_collision_yspeed_multiplier());
            }
            else
            {
                physics_body.vel_y = smart_value(_data.get_on_collision_yspeed());
            }
        }
    }
}