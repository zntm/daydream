/// @desc Bridge functions to integrate new physics system with collision detection

/// @desc Run physics step on an entity instance
/// @param {Id.Instance} _inst
/// @param {Real} _dt
function entity_physics_step(_inst, _dt)
{
    with (_inst)
    {
        physics_body.sync_from_instance(id);
        entity_update_collision(physics_body);
        physics_step(physics_body, input_state, _dt);
        physics_body.sync_to_instance(id);
    }
}

/// @desc Update collision state by checking tiles (called from instance context)
/// @param {Struct.PhysicsBody} _body
function entity_update_collision(_body)
{
    // Ground check
    _body.collision.ground = tile_meeting(x, y + 1) != false;
    
    // Ceiling check  
    _body.collision.ceiling = tile_meeting(x, y - 1) != false;
    
    // Wall checks
    var _w = attribute.get_collision_box_width();
    _body.collision.wall_left = tile_meeting(x - _w/2 - 1, y) != false;
    _body.collision.wall_right = tile_meeting(x + _w/2 + 1, y) != false;
    
    // Liquid check
    var _tile_at = tile_get(floor(x / TILE_SIZE), floor((y - 8) / TILE_SIZE), CHUNK_DEPTH_DEFAULT);
    if (_tile_at != TILE_EMPTY)
    {
        var _data = global.item_data[$ _tile_at.get_id()];
        if (_data.is_liquid())
        {
            _body.collision.in_liquid = true;
            _body.collision.liquid_type = _tile_at.get_id();
            return;
        }
    }
    
    _body.collision.in_liquid = false;
    _body.collision.liquid_type = "";
}

/// @desc Apply knockback to an entity
/// @param {Id.Instance} _inst Target instance
/// @param {Id.Instance} _source Source of knockback
/// @param {Real} [_force] Knockback force
function entity_knockback(_inst, _source, _force = 4)
{
    var _dir = sign(_inst.x - _source.x);
    if (_dir == 0) _dir = choose(-1, 1);
    
    _inst.physics_body.vel_x = _dir * _force;
    _inst.physics_body.vel_y = -_force * 0.75;
}
