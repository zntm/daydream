#macro LIQUID_LEVEL_MAX 8
#macro LIQUID_FLOW_TICK_DELAY 8

/* complete liquid flow simulation — replaces flow.daydream */
function liquid_flow(_x, _y, _z, _parameter = {})
{
    var _tile = tile_get(_x, _y, _z);
    
    if (_tile == TILE_EMPTY) exit;
    
    var _id    = _tile.get_id();
    var _level = _tile.get_component("level") ?? LIQUID_LEVEL_MAX;
    var _flow_dir = _tile.get_component("flow_direction") ?? 0;
    
    var _tick_delay = _parameter[$ "tick_delay"] ?? LIQUID_FLOW_TICK_DELAY;
    
    /* resolve fluid collision table (water+lava=stone etc.) */
    var _fluid_collisions = _parameter[$ "fluid_collisions"];
    
    if (_fluid_collisions == undefined)
    {
        if (_id == "phantasia:water")
            _fluid_collisions = [{ result_id: "phantasia:stone", liquid_id: "phantasia:lava" }];
        else if (_id == "phantasia:lava")
            _fluid_collisions = [{ result_id: "phantasia:stone", liquid_id: "phantasia:water" }];
        else
            _fluid_collisions = [];
        
        _parameter[$ "fluid_collisions"] = _fluid_collisions;
        _parameter[$ "tick_delay"] = _tick_delay;
    }
    
    /* empty tile — remove */
    if (_level <= 0)
    {
        tile_place(_x, _y, _z, TILE_EMPTY);
        exit;
    }
    
    var _flowed = false;
    var _new_positions = [];
    
    /* --- phase 1: gravity (flow down) --- */
    
    var _solid_down = tile_get(_x, _y + 1, CHUNK_DEPTH_DEFAULT);
    
    if (_solid_down == TILE_EMPTY)
    {
        var _tile_down = tile_get(_x, _y + 1, _z);
        
        if (_tile_down == TILE_EMPTY)
        {
            /* empty below — move entire tile down */
            var _new_tile = new Tile(_id);
            _new_tile.set_component("level", _level);
            _new_tile.set_component("flow_direction", _flow_dir);
            tile_place(_x, _y + 1, _z, _new_tile);
            tile_place(_x, _y, _z, TILE_EMPTY);
            array_push(_new_positions, { x: _x, y: _y + 1, z: _z });
            _flowed = true;
            _level = 0;
        }
        else if (_tile_down.get_id() == _id)
        {
            /* same liquid below — transfer level */
            var _level_down = _tile_down.get_component("level") ?? 0;
            var _space_down = LIQUID_LEVEL_MAX - _level_down;
            
            if (_space_down > 0)
            {
                var _transfer = min(_level, _space_down);
                _level -= _transfer;
                _tile_down.set_component("level", _level_down + _transfer);
                
                if (_level <= 0)
                    tile_place(_x, _y, _z, TILE_EMPTY);
                else
                    _tile.set_component("level", _level);
                
                array_push(_new_positions, { x: _x, y: _y + 1, z: _z });
                _flowed = true;
            }
        }
        else
        {
            /* different liquid below — check fluid collision */
            var _interaction = liquid_flow_check_collision(_fluid_collisions, _tile_down.get_id());
            
            if (_interaction != undefined)
            {
                tile_place(_x, _y + 1, _z, new Tile(_interaction));
            }
        }
    }
    
    /* --- phase 2: diagonal flow (down-left / down-right) --- */
    
    if (!_flowed && _level > 0)
    {
        var _diag_dirs = (irandom(1) == 0) ? [-1, 1] : [1, -1];
        
        for (var i = 0; i < 2; ++i)
        {
            var _dx = _diag_dirs[i];
            var _diag_x = _x + _dx;
            var _diag_y = _y + 1;
            
            var _solid_side = tile_get(_diag_x, _y, CHUNK_DEPTH_DEFAULT);
            var _solid_diag = tile_get(_diag_x, _diag_y, CHUNK_DEPTH_DEFAULT);
            
            if (_solid_side != TILE_EMPTY) || (_solid_diag != TILE_EMPTY) continue;
            
            var _tile_diag = tile_get(_diag_x, _diag_y, _z);
            
            if (_tile_diag == TILE_EMPTY)
            {
                /* empty diagonal — move entire tile */
                var _new_tile = new Tile(_id);
                _new_tile.set_component("level", _level);
                _new_tile.set_component("flow_direction", _dx);
                tile_place(_diag_x, _diag_y, _z, _new_tile);
                tile_place(_x, _y, _z, TILE_EMPTY);
                array_push(_new_positions, { x: _diag_x, y: _diag_y, z: _z });
                _flowed = true;
                _level = 0;
                break;
            }
            else if (_tile_diag.get_id() == _id)
            {
                /* same liquid diagonal — transfer */
                var _level_diag = _tile_diag.get_component("level") ?? 0;
                var _space_diag = LIQUID_LEVEL_MAX - _level_diag;
                
                if (_space_diag > 0)
                {
                    var _transfer = min(_level, _space_diag);
                    _level -= _transfer;
                    _tile_diag.set_component("level", _level_diag + _transfer);
                    _tile.set_component("level", _level);
                    
                    if (_level <= 0)
                        tile_place(_x, _y, _z, TILE_EMPTY);
                    
                    array_push(_new_positions, { x: _diag_x, y: _diag_y, z: _z });
                    _flowed = true;
                    break;
                }
            }
            else
            {
                var _interaction = liquid_flow_check_collision(_fluid_collisions, _tile_diag.get_id());
                
                if (_interaction != undefined)
                    tile_place(_diag_x, _diag_y, _z, new Tile(_interaction));
            }
        }
    }
    
    /* --- phase 3: horizontal spreading --- */
    
    if (!_flowed && _level > 0)
    {
        var _dirs = (_flow_dir != 0)
            ? [_flow_dir]
            : ((irandom(1) == 0) ? [1, -1] : [-1, 1]);
        
        var _blocked = true;
        
        for (var i = array_length(_dirs) - 1; i >= 0; --i)
        {
            var _dx = _dirs[i];
            var _tx = _x + _dx;
            
            var _solid_target = tile_get(_tx, _y, CHUNK_DEPTH_DEFAULT);
            
            if (_solid_target != TILE_EMPTY) continue;
            
            var _target = tile_get(_tx, _y, _z);
            var _can_flow = false;
            var _target_level = 0;
            
            if (_target == TILE_EMPTY)
            {
                _can_flow = true;
            }
            else if (_target.get_id() == _id)
            {
                _target_level = _target.get_component("level") ?? 0;
                
                if (_target_level < _level - 1)
                    _can_flow = true;
            }
            else
            {
                var _interaction = liquid_flow_check_collision(_fluid_collisions, _target.get_id());
                
                if (_interaction != undefined)
                {
                    tile_place(_tx, _y, _z, new Tile(_interaction));
                    _blocked = true;
                    continue;
                }
            }
            
            if (_can_flow)
            {
                _blocked = false;
                var _total = _level + _target_level;
                var _new_level_target = _total div 2;
                var _transfer = _new_level_target - _target_level;
                
                if (_transfer > 0)
                {
                    _level -= _transfer;
                    _tile.set_component("level", _level);
                    
                    if (_level > 0) _tile.set_component("flow_direction", _dx);
                    
                    if (_target == TILE_EMPTY)
                    {
                        _target = new Tile(_id);
                        tile_place(_tx, _y, _z, _target);
                    }
                    
                    _target.set_component("level", _target_level + _transfer);
                    _target.set_component("flow_direction", _dx);
                    
                    array_push(_new_positions, { x: _tx, y: _y, z: _z });
                    _flowed = true;
                    
                    if (_level <= 0)
                        tile_place(_x, _y, _z, TILE_EMPTY);
                }
                
                break;
            }
        }
        
        /* reverse flow direction when blocked */
        if (_blocked && _level > 0 && _flow_dir != 0)
        {
            _tile.set_component("flow_direction", -_flow_dir);
        }
    }
    
    /* --- schedule follow-up ticks --- */
    
    for (var i = array_length(_new_positions) - 1; i >= 0; --i)
    {
        var _pos = _new_positions[i];
        liquid_flow_schedule(_pos.x, _pos.y, _pos.z, _parameter);
    }
    
    if (_level > 0)
    {
        liquid_flow_schedule(_x, _y, _z, _parameter);
    }
}

/* check fluid collision table — returns result tile id or undefined */
function liquid_flow_check_collision(_collisions, _other_id)
{
    for (var i = array_length(_collisions) - 1; i >= 0; --i)
    {
        if (_collisions[i].liquid_id == _other_id)
            return _collisions[i].result_id;
    }
    
    return undefined;
}

/* thin wrapper called from tile_update.gml on block break */
function tile_update_liquid(_x, _y, _z)
{
    var _item_data = global.item_data;
    
    /* check neighbours for liquid that should flow into this position */
    
    /* above */
    var _above = tile_get(_x, _y - 1, CHUNK_DEPTH_LIQUID);
    if (_above != TILE_EMPTY && _item_data[$ _above.get_id()].is_liquid())
    {
        liquid_flow_schedule(_x, _y - 1, CHUNK_DEPTH_LIQUID);
    }
    
    /* left */
    var _left = tile_get(_x - 1, _y, CHUNK_DEPTH_LIQUID);
    if (_left != TILE_EMPTY && _item_data[$ _left.get_id()].is_liquid())
    {
        liquid_flow_schedule(_x - 1, _y, CHUNK_DEPTH_LIQUID);
    }
    
    /* right */
    var _right = tile_get(_x + 1, _y, CHUNK_DEPTH_LIQUID);
    if (_right != TILE_EMPTY && _item_data[$ _right.get_id()].is_liquid())
    {
        liquid_flow_schedule(_x + 1, _y, CHUNK_DEPTH_LIQUID);
    }
    
    /* below */
    var _below = tile_get(_x, _y + 1, CHUNK_DEPTH_LIQUID);
    if (_below != TILE_EMPTY && _item_data[$ _below.get_id()].is_liquid())
    {
        liquid_flow_schedule(_x, _y + 1, CHUNK_DEPTH_LIQUID);
    }
}
