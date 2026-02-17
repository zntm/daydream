/// @desc Fire a projectile from an entity, handling ammo consumption and damage calculation.
/// @param {Id.Instance} _entity          The shooting entity.
/// @param {String}      _item_id         The weapon item data ID.
/// @param {Real}        _x               Spawn X (world pixels).
/// @param {Real}        _y               Spawn Y (world pixels).
/// @param {Real}        _angle           Aim angle (degrees).
/// @param {Struct}      [_inventory_target] Inventory to consume ammo from.
/// @param {Array}       [_out_changed_slots] Output array of changed slot indices.
/// @param {Real}        [_power]         Charge power multiplier (0..1).
function control_entity_shoot(_entity, _item_id, _x, _y, _angle, _inventory_target = global.inventory, _out_changed_slots = undefined, _power = 1.0)
{
    var _data = global.item_data[$ _item_id];
    
    if (_data == undefined) exit;
    
    var _projectile_id = _data.get_item_projectile();
    var _ammo_requirement = _data.get_item_ammo_requirement();
    var _ammo_type = _data.get_item_ammo_type();
    var _damage_bonus  = 0;
    
    // Prevent throwing items that are strictly ammo (have an ammo_type)
    // dedication throwables (like grenades) usually have a projectile but NO ammo_type.
    if (_ammo_type != undefined)
    {
        // If we are not a launcher, we shouldn't be shooting this item because it IS ammo
        if (_data.get_hold_type() != ITEM_HOLD_TYPE.LAUNCHER)
        {
            return false;
        }
    }
    
    /* --- ammo consumption (player only) --- */
    if (_ammo_type != undefined) && (_entity.object_index == obj_Player)
    {
        var _ammo_found_index = -1;
        var _ammo_item = undefined;
        
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
                
                /* ammo can override the projectile type */
                var _ammo_proj = _item_data.get_item_projectile();
                if (_ammo_proj != undefined) _projectile_id = _ammo_proj;
                
                _damage_bonus += _item_data.get_item_damage();
                
                break;
            }
        }
        
        if (_ammo_found_index == -1) return false;
        
        inventory_item_decrement("base", _ammo_found_index, _inventory_target, _out_changed_slots);
    }
    
    /* --- spawn projectile --- */
    if (_projectile_id != undefined)
    {
        var _p_data    = global.projectile_data[$ _projectile_id];
        var _max_speed = smart_value(_p_data.get_speed());
        if (_max_speed == 0) _max_speed = 5;
        
        var _speed = _max_speed * _power;
        
        /* velocity-based damage formula */
        var _launcher_mult  = _data.get_item_damage();
        var _ammo_damage    = _damage_bonus;
        var _exp_curve      = 1.5;
        var _min_damage     = 1;
        var _velocity_ratio = clamp(_speed / _max_speed, 0, 1);
        
        var _damage = max(_min_damage, _launcher_mult * _ammo_damage * power(_velocity_ratio, _exp_curve));
        
        /* build aim target from the provided angle */
        var _range     = 1000;
        var _target_x  = _x + lengthdir_x(_range, _angle);
        var _target_y  = _y + lengthdir_y(_range, _angle);
        
        var _xscale = (cos(degtorad(_angle)) >= 0) ? 1 : -1;
        
        var _inst = spawn_projectile(_x, _y, _projectile_id, _damage, _xscale, 1, _entity, _target_x, _target_y, _power);
        
        var _event = new EventDataProjectileShoot(_entity, _inst, _x, _y, _inst.image_angle, _damage);
        
        event_emit(_event);
        
        return true;
    }
    
    return false;
}
