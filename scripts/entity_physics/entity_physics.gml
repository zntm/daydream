/// @desc Bridge functions to integrate new physics system with collision detection

/// @desc Run physics step on an entity instance
/// @param {Id.Instance} _inst
/// @param {Real} _dt
function entity_physics_step(_inst)
{
    with (_inst)
    {
        physics_body.sync_from_instance(id);
        entity_update_collision(physics_body);
        physics_step(physics_body, input_state);
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
    var _tile_x = floor(x / TILE_SIZE);
    var _tile_y = floor((y - 8) / TILE_SIZE);
    var _tile_at = tile_get(_tile_x, _tile_y, CHUNK_DEPTH_LIQUID);
    if (_tile_at != TILE_EMPTY)
    {
        var _data = global.item_data[$ _tile_at.get_id()];
        if (_data.is_liquid())
        {
            var _was_in_liquid = _body.collision.in_liquid;
            var _tile_changed = !_was_in_liquid
                || (_body.collision.liquid_tile_x != _tile_x)
                || (_body.collision.liquid_tile_y != _tile_y);

            _body.collision.in_liquid = true;
            _body.collision.liquid_type = _tile_at.get_id();
            _body.collision.liquid_tile_x = _tile_x;
            _body.collision.liquid_tile_y = _tile_y;

            if (_tile_changed)
            {
                var _speed = abs(_body.vel_x) + abs(_body.vel_y);
                var _disturb = clamp(0.45 + (_speed * 0.12) + (!_was_in_liquid ? 0.5 : 0), 0.45, 1.8);
                control_chunk_liquid_disturb(_tile_x, _tile_y, _disturb, 1, _tile_at.get_id());
            }

            exit;
        }
    }

    if (_body.collision.in_liquid)
    {
        control_chunk_liquid_disturb(
            _body.collision.liquid_tile_x,
            _body.collision.liquid_tile_y,
            0.7,
            1,
            _body.collision.liquid_type
        );
    }
    
    _body.collision.in_liquid = false;
    _body.collision.liquid_type = "";
    _body.collision.liquid_tile_x = 0;
    _body.collision.liquid_tile_y = 0;
    
    // Trigger on_stay events
    var _w = attribute.get_collision_box_width();
    var _h = attribute.get_collision_box_height();
    
    var _tx1 = floor((x - _w/2) / TILE_SIZE);
    var _tx2 = floor((x + _w/2) / TILE_SIZE);
    var _ty1 = floor((y - _h) / TILE_SIZE);
    var _ty2 = floor(y / TILE_SIZE);
    
    for (var _tx = _tx1; _tx <= _tx2; ++_tx)
    {
        for (var _ty = _ty1; _ty <= _ty2; ++_ty)
        {
            var _tile = tile_get(_tx, _ty, CHUNK_DEPTH_DEFAULT);
            if (_tile != TILE_EMPTY)
            {
                var _data = global.item_data[$ _tile.get_id()];
                if (_data != undefined && _data.get_on_stay_length() > 0)
                {
                    function_execute(_data.get_on_stay(), _tx, _ty, CHUNK_DEPTH_DEFAULT, 1, 1, id);
                }
            }
        }
    }
}

/// @desc Apply knockback to an entity
/// @param {Id.Instance} _inst Target instance
/// @param {Id.Instance} _source Source of knockback
/// @param {Real} [_force] Knockback force
function entity_knockback(_inst, _source, _force = PHYSICS_KNOCKBACK_FORCE)
{
    var _dir = sign(_inst.x - _source.x);
    if (_dir == 0) _dir = choose(-1, 1);
    
    _inst.physics_body.vel_x = _dir * _force;
    _inst.physics_body.vel_y = -_force * PHYSICS_KNOCKBACK_Y_RATIO;
}
