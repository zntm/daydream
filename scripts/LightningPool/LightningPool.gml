#macro LIGHTNING_CONDUCT_DELAY   2.0
#macro LIGHTNING_SEEK_RADIUS     128
#macro LIGHTNING_MAX_BOLTS       4
#macro LIGHTNING_DAMAGE          20

enum LIGHTNING_STATE {
    SEEKING,
    FOLLOWING,
    CONDUCTING
}

/// @desc Pool-based lightning bolt manager.
function LightningPool() : Pool() constructor
{
    active_bolts = [];
    active_count = 0;
    
    static create = function()
    {
        return {
            x:             0,
            y:             0,
            target_x:      0,
            target_y:      0,
            target_entity: noone,
            timer:         0,
            state:         LIGHTNING_STATE.SEEKING,
            active:        false
        }
    }
    
    /// @function spawn(_x, _y)
    /// @desc Acquire a bolt from the pool and activate it at the given position.
    static spawn = function(_x, _y)
    {
        if (active_count >= LIGHTNING_MAX_BOLTS) exit;
        
        var _bolt = get_free_item();
        
        _bolt.x             = _x;
        _bolt.y             = _y;
        _bolt.target_x      = _x;
        _bolt.target_y      = _y;
        _bolt.target_entity = noone;
        _bolt.timer         = 0;
        _bolt.state         = LIGHTNING_STATE.SEEKING;
        _bolt.active        = true;
        
        array_push(active_bolts, _bolt);
        
        ++active_count;
    }
    
    /// @function update(_dt)
    /// @desc Tick all active bolts through their state machine.
    static update = function(_dt)
    {
        var _item_data = global.item_data;
        
        for (var i = active_count - 1; i >= 0; --i)
        {
            var _bolt = active_bolts[i];
            
            _bolt.timer += _dt;
            
            switch (_bolt.state)
            {
                case LIGHTNING_STATE.SEEKING:
                {
                    /* scan for conductive tiles near bolt position */
                    var _tx = round(_bolt.x / TILE_SIZE);
                    var _ty = round(_bolt.y / TILE_SIZE);
                    var _radius = ceil(LIGHTNING_SEEK_RADIUS / TILE_SIZE);
                    var _found = false;
                    
                    for (var _dx = -_radius; _dx <= _radius; ++_dx)
                    {
                        for (var _dy = -_radius; _dy <= _radius; ++_dy)
                        {
                            for (var _z = CHUNK_DEPTH - 1; _z >= 0; --_z)
                            {
                                var _tile = tile_get(_tx + _dx, _ty + _dy, _z);
                                
                                if (_tile == TILE_EMPTY) continue;
                                
                                var _data = _item_data[$ _tile.get_id()];
                                
                                if (_data.is_conductive())
                                {
                                    _bolt.target_x = (_tx + _dx) * TILE_SIZE;
                                    _bolt.target_y = (_ty + _dy) * TILE_SIZE;
                                    _bolt.state    = LIGHTNING_STATE.CONDUCTING;
                                    _bolt.timer    = 0;
                                    _found         = true;
                                    
                                    break;
                                }
                            }
                            
                            if (_found) break;
                        }
                        
                        if (_found) break;
                    }
                    
                    /* fallback: scan for nearby entities */
                    if (!_found)
                    {
                        var _best      = noone;
                        var _best_dist = LIGHTNING_SEEK_RADIUS;
                        
                        with (obj_Player)
                        {
                            var _d = point_distance(x, y, _bolt.x, _bolt.y);
                            
                            if (_d < _best_dist)
                            {
                                _best_dist = _d;
                                _best      = id;
                            }
                        }
                        
                        with (obj_Creature)
                        {
                            var _d = point_distance(x, y, _bolt.x, _bolt.y);
                            
                            if (_d < _best_dist)
                            {
                                _best_dist = _d;
                                _best      = id;
                            }
                        }
                        
                        if (_best != noone)
                        {
                            _bolt.target_entity = _best;
                            _bolt.target_x      = _best.x;
                            _bolt.target_y      = _best.y;
                            _bolt.state         = LIGHTNING_STATE.FOLLOWING;
                            _bolt.timer         = 0;
                        }
                    }
                    
                    /* despawn if nothing found after a reasonable time */
                    if (!_found) && (_bolt.target_entity == noone) && (_bolt.timer > 1.0)
                    {
                        __release_bolt(i);
                    }
                    
                    break;
                }
                
                case LIGHTNING_STATE.FOLLOWING:
                {
                    var _ent = _bolt.target_entity;
                    
                    if (_ent == noone) || (!instance_exists(_ent))
                    {
                        __release_bolt(i);
                        
                        break;
                    }
                    
                    _bolt.target_x = _ent.x;
                    _bolt.target_y = _ent.y;
                    
                    /* check if entity is sheltered by a solid tile directly above */
                    var _tx = round(_ent.x / TILE_SIZE);
                    var _ty = round(_ent.y / TILE_SIZE) - 1;
                    var _sheltered = false;
                    
                    for (var _z = CHUNK_DEPTH - 1; _z >= 0; --_z)
                    {
                        var _tile = tile_get(_tx, _ty, _z);
                        
                        if (_tile == TILE_EMPTY) continue;
                        
                        var _data = _item_data[$ _tile.get_id()];
                        
                        if (_data.has_type(ITEM_TYPE_BIT.SOLID))
                        {
                            /* redirect bolt to the covering tile */
                            _bolt.target_entity = noone;
                            _bolt.target_x      = _tx * TILE_SIZE;
                            _bolt.target_y      = _ty * TILE_SIZE;
                            _bolt.state         = LIGHTNING_STATE.CONDUCTING;
                            _bolt.timer         = 0;
                            _sheltered          = true;
                            
                            break;
                        }
                    }
                    
                    if (!_sheltered) && (_bolt.timer >= LIGHTNING_CONDUCT_DELAY)
                    {
                        _bolt.state = LIGHTNING_STATE.CONDUCTING;
                        _bolt.timer = 0;
                    }
                    
                    break;
                }
                
                case LIGHTNING_STATE.CONDUCTING:
                {
                    if (_bolt.timer >= 0.2)
                    {
                        /* deal damage to entity if still targeted */
                        var _ent = _bolt.target_entity;
                        
                        if (_ent != noone) && (instance_exists(_ent))
                        {
                            control_entity_damage(_ent, noone, LIGHTNING_DAMAGE, 0.2, 0, 1);
                        }
                        
                        /* spawn critical particles at strike point */
                        repeat (irandom_range(6, 12))
                        {
                            spawn_particle(
                                _bolt.target_x + random_range(-8, 8),
                                _bolt.target_y + random_range(-8, 8),
                                "phantasia:particle/entity/damage_critical"
                            );
                        }
                        
                        __release_bolt(i);
                    }
                    
                    break;
                }
            }
        }
    }
    
    /// @function render()
    /// @desc Draw placeholder lightning visuals for active bolts.
    static render = function()
    {
        for (var i = active_count - 1; i >= 0; --i)
        {
            var _bolt = active_bolts[i];
            
            /* draw a jagged line from bolt origin to target */
            var _x1 = _bolt.x;
            var _y1 = _bolt.y;
            var _x2 = _bolt.target_x;
            var _y2 = _bolt.target_y;
            
            var _segments = 6;
            var _last_x   = _x1;
            var _last_y   = _y1;
            
            draw_set_colour(c_white);
            draw_set_alpha((_bolt.state == LIGHTNING_STATE.CONDUCTING) ? 1.0 : 0.5);
            
            for (var j = 1; j <= _segments; ++j)
            {
                var _t  = j / _segments;
                var _nx = lerp(_x1, _x2, _t) + ((j < _segments) ? random_range(-6, 6) : 0);
                var _ny = lerp(_y1, _y2, _t) + ((j < _segments) ? random_range(-4, 4) : 0);
                
                draw_line_width(_last_x, _last_y, _nx, _ny, (_bolt.state == LIGHTNING_STATE.CONDUCTING) ? 2 : 1);
                
                _last_x = _nx;
                _last_y = _ny;
            }
            
            draw_set_alpha(1);
        }
    }
    
    /// @function __release_bolt(_index)
    /// @desc Internal: release bolt at index back to pool.
    static __release_bolt = function(_index)
    {
        var _bolt = active_bolts[_index];
        
        _bolt.active = false;
        
        release(_bolt);
        
        array_delete(active_bolts, _index, 1);
        
        --active_count;
    }
}

global.lightning_pool = new LightningPool();
