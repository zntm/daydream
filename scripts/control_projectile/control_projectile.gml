/// @desc Projectile step - physics, collisions, particles, and script hooks.
/// @param {Real} [_dt] Delta time (defaults to 1.0).
function control_projectile(_dt = 1.0)
{
    /* client interpolation (networking) */
    if (global.network_role == RELAY_ROLE.CLIENT)
    {
        if (variable_instance_exists(self, "interp_start_x"))
        {
            interp_timer += _dt / GAME_TICK;
            var _t = clamp(interp_timer / interp_duration, 0, 1);
            
            x = lerp(interp_start_x, interp_target_x, _t);
            y = lerp(interp_start_y, interp_target_y, _t);
            
            if (interp_target_x != interp_start_x || interp_target_y != interp_start_y)
            {
                image_angle = point_direction(interp_start_x, interp_start_y, interp_target_x, interp_target_y);
            }
        }
        exit;
    }
    
    /* lifetime */
    timer_life -= _dt / GAME_TICK;
    
    if (timer_life <= 0)
    {
        instance_destroy();
        exit;
    }
    
    var _data = global.projectile_data[$ _id];
    var _boolean = _data.get_boolean();
    var _gravity = (attribute != undefined) ? attribute.get_gravity() : 0;
    
    /* tick particles (mode == TICK) */
    var _particles = _data.get_particles();
    
    if (_particles != undefined)
    {
        for (var i = array_length(_particles) - 1; i >= 0; --i)
        {
            var _p = _particles[i];
            
            if (_p.mode == PROJECTILE_PARTICLE_MODE.TICK && chance(_p.frequency * _dt))
            {
                spawn_particle(x + _p.offset_x, y + _p.offset_y, _p.id);
            }
        }
    }
    
    /* tick proglang hooks */
    var _on_tick = _data.get_on_tick();
    
    if (_on_tick != undefined)
    {
        for (var i = array_length(_on_tick) - 1; i >= 0; --i)
        {
            function_execute(_on_tick[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id);
        }
    }
    
    /* entity collision */
    if (damage > 0)
    {
        var _inst = instance_place(x, y, obj_Creature);
        
        if (instance_exists(_inst) && _inst.hp > 0)
        {
            control_entity_damage(_inst, (owner != undefined) ? owner : id, damage);
            
            event_emit(new EventDataProjectileLand(id, x, y, _inst, "entity"));
            
            /* on-entity-land particles */
            projectile_emit_land_particles(_data, x, y);
            
            /* on_hit_entity hooks */
            var _on_hit_entity = _data.get_on_hit_entity();
            
            if (_on_hit_entity != undefined)
            {
                for (var i = array_length(_on_hit_entity) - 1; i >= 0; --i)
                {
                    function_execute(_on_hit_entity[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id, _inst);
                }
            }
            
            /* on_land hooks (fires for both entity and tile) */
            var _on_land = _data.get_on_land();
            
            if (_on_land != undefined)
            {
                for (var i = array_length(_on_land) - 1; i >= 0; --i)
                {
                    function_execute(_on_land[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id, _inst);
                }
            }
            
            if (_boolean & PROJECTILE_BOOL.DESTROY_ON_ENTITY)
            {
                instance_destroy();
                exit;
            }
        }
    }
    
    /* physics */
    if (physics_body != undefined && attribute != undefined)
    {
        physics_body.sync_from_instance(id);
        physics_body.reset_collision();
        
        /* verlet integration part 1 */
        if (_gravity != 0)
        {
            physics_body.vel_y += (_gravity * _dt) / 2;
        }
        
        /* collision resolution */
        physics_move_contact_x(physics_body);
        physics_move_contact_y(physics_body);
        
        /* verlet integration part 2 */
        if (_gravity != 0)
        {
            physics_body.vel_y += (_gravity * _dt) / 2;
        }
        
        physics_body.sync_to_instance(id);
        
        /* tile collision */
        if (attribute.has_collision_box() && (tile_meeting(x, y - 1) || tile_meeting(x + 1, y) || tile_meeting(x, y + 1) || tile_meeting(x - 1, y)))
        {
            event_emit(new EventDataProjectileLand(id, x, y, undefined, "tile"));
            
            /* on-tile-land particles */
            projectile_emit_land_particles(_data, x, y);
            
            /* on_hit_tile hooks */
            var _on_hit_tile = _data.get_on_hit_tile();
            
            if (_on_hit_tile != undefined)
            {
                for (var i = array_length(_on_hit_tile) - 1; i >= 0; --i)
                {
                    function_execute(_on_hit_tile[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id, undefined);
                }
            }
            
            /* on_land hooks */
            var _on_land = _data.get_on_land();
            
            if (_on_land != undefined)
            {
                for (var i = array_length(_on_land) - 1; i >= 0; --i)
                {
                    function_execute(_on_land[i], x, y, CHUNK_DEPTH_DEFAULT, image_xscale, image_yscale, id, undefined);
                }
            }
            
            if (_boolean & PROJECTILE_BOOL.DESTROY_ON_TILE)
            {
                instance_destroy();
                exit;
            }
            
            /* on-collision speed overrides */
            var _coll_vx = _data.get_on_collision_speed_x();
            var _coll_vy = _data.get_on_collision_speed_y();
            
            if (_coll_vx != undefined)
                physics_body.vel_x = smart_value(_coll_vx);
            
            if (_coll_vy != undefined)
                physics_body.vel_y = smart_value(_coll_vy);
        }
    }
    
    /* rotation */
    if (rotation_increment != 0)
    {
        image_angle += rotation_increment * _dt;
    }
    else if (_gravity != 0)
    {
        image_angle = point_direction(0, 0, physics_body.vel_x, physics_body.vel_y);
    }
}

/// @desc Emit all particles with mode LAND for a projectile.
/// @param {Struct} _data  The ProjectileData struct.
/// @param {Real} _x       World X.
/// @param {Real} _y       World Y.
function projectile_emit_land_particles(_data, _x, _y)
{
    var _particles = _data.get_particles();
    
    if (_particles == undefined) exit;
    
    for (var i = array_length(_particles) - 1; i >= 0; --i)
    {
        var _p = _particles[i];
        
        if (_p.mode == PROJECTILE_PARTICLE_MODE.LAND)
        {
            spawn_particle(_x + _p.offset_x, _y + _p.offset_y, _p.id);
        }
    }
}