/// @desc Applies structure terrain modifiers to surface height
/// @param {Real} _x World X position
/// @param {Real} _surface_height Base surface height
/// @param {Struct.obj_Structure[]} _structures Array of structure instances at this position
/// @returns {Real} Modified surface height
function worldgen_apply_structure_terrain_modifier(_x, _surface_height, _structures, _structure_data)
{
    var _modified_height = _surface_height;
    var _structures_length = array_length(_structures);
    
    for (var i = 0; i < _structures_length; ++i)
    {
        var _inst = _structures[i];
        var _data = _structure_data[$ _inst.structure_id];
        
        if (_data == undefined) || (!_data.has_terrain_modifier())
        {
            continue;
        }
        
        var _type = _data.get_terrain_modifier_type();
        var _depth = _data.get_terrain_modifier_depth();
        var _radius = _data.get_terrain_modifier_radius();
        var _blend = _data.get_terrain_modifier_blend();
        
        // Get structure bounds
        var _struct_x = _inst.x / TILE_SIZE;
        var _struct_width = _inst.image_xscale;
        var _struct_center = _struct_x + (_struct_width / 2);
        
        // Calculate horizontal distance from structure center
        var _dx = abs(_x - _struct_center);
        
        // Check if we're in the affected range
        var _affect_range = (_struct_width / 2);
        if (_radius != undefined)
        {
            _affect_range += _radius;
        }
        
        if (_dx > _affect_range)
        {
            continue;
        }
        
        // Calculate blend factor (1.0 at center, 0.0 at edge if blending)
        var _blend_factor = 1.0;
        if (_blend) && (_dx > _struct_width / 2)
        {
            var _blend_distance = _dx - (_struct_width / 2);
            var _blend_range = _radius ?? 0;
            _blend_factor = 1.0 - (_blend_distance / max(_blend_range, 1));
            _blend_factor = clamp(_blend_factor, 0, 1);
        }
        
        // Apply modification based on type
        switch (_type)
        {
            case STRUCTURE_TERRAIN_MODIFIER_TYPE.CLEAR:
                // Lower terrain to create flat surface above structure
                var _target_height = _inst.y / TILE_SIZE - _depth;
                _modified_height = max(_modified_height, _target_height + ((_surface_height - _target_height) * (1 - _blend_factor)));
                break;
                
            case STRUCTURE_TERRAIN_MODIFIER_TYPE.CARVE:
                // Raise terrain surface above structure (structure is buried)
                var _carve_height = _surface_height + (_depth * _blend_factor);
                _modified_height = max(_modified_height, _carve_height);
                break;
                
            case STRUCTURE_TERRAIN_MODIFIER_TYPE.ELEVATE:
                // Lower the surface number (= raise terrain) to elevate around structure
                var _elevate_height = _surface_height - (_depth * _blend_factor);
                _modified_height = min(_modified_height, _elevate_height);
                break;
        }
    }
    
    return _modified_height;
}
