function proglang_function_register(_name, _func)
{
    global.proglang_functions[$ _name] = {
        name: _name,
        "function": _func
    }
}

#region Game API
// Events
proglang_function_register("event_emit", function(_args)
{
    event_emit(_args[0], (array_length(_args) > 1) ? _args[1] : undefined);
});

proglang_function_register("event_subscribe", function(_args, _vm) {
    var _event = _args[0];
    var _func = _args[1];

    // Create a bridge method that will be called by GML
    var _bridge = method({ 
        func: _func, 
        base_vm_gref: _vm[PROG_VM.GLOBAL_REF] // Capture global ref from registrar
    }, function(_event_data) {
        
        // Prepare VM for execution
        var _exec_vm = proglang_vm_create();
        
        // Restore global context
        _exec_vm[@ PROG_VM.GLOBAL_REF] = base_vm_gref;
        
        // Execute the Proglang function/closure
        if (is_array(func) && array_length(func) >= PROG_CLOSURE.SIZE && func[PROG_CLOSURE.TYPE] == "closure")
        {
            // Set parent scope to closure environment
            _exec_vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = func[PROG_CLOSURE.ENV];
            
            var _params = func[PROG_CLOSURE.PARAM_COUNT];
            
            // Push arguments
            if (_params > 0)
            {
                // We only have 1 argument: _event_data
                _exec_vm[@ PROG_VM.STACK][@ 0] = _event_data;
                _exec_vm[@ PROG_VM.SP] = 1;
                
                // Pad rest with undefined if needed
                for (var i = 1; i < _params; i++)
                {
                    _exec_vm[@ PROG_VM.STACK][@ i] = undefined;
                    _exec_vm[@ PROG_VM.SP]++;
                }
            }
            
            proglang_vm_run(_exec_vm, func[PROG_CLOSURE.BYTECODE]);
        }
        else if (is_struct(func) && struct_exists(func, "function"))
        {
            // Native function wrapper
            func[$ "function"]([_event_data], _exec_vm);
        }
        
        proglang_vm_free(_exec_vm);
    });

    return event_subscribe(_event, _bridge);
});

proglang_function_register("event_unsubscribe", function(_args)
{
    event_unsubscribe(_args[0]);
});

#endregion

#region Math

proglang_function_register("floor", function(_args)
{
    return floor(_args[0]);
});

proglang_function_register("ceil", function(_args)
{
    return ceil(_args[0]);
});

proglang_function_register("round", function(_args)
{
    return round(_args[0]);
});

proglang_function_register("abs", function(_args)
{
    return abs(_args[0]);
});

proglang_function_register("sign", function(_args)
{
    return sign(_args[0]);
});

proglang_function_register("min", function(_args) {
    if (array_length(_args) == 0) return 0;
    var _min = _args[0];
    for (var i = 1; i < array_length(_args); i++) _min = min(_min, _args[i]);
    return _min;
});

proglang_function_register("max", function(_args) {
    if (array_length(_args) == 0) return 0;
    var _max = _args[0];
    for (var i = 1; i < array_length(_args); i++) _max = max(_max, _args[i]);
    return _max;
});

proglang_function_register("clamp", function(_args) {
    return clamp(_args[0], _args[1], _args[2]);
});

proglang_function_register("lerp", function(_args) {
    return lerp(_args[0], _args[1], _args[2]);
});

proglang_function_register("point_distance", function(_args) {
    return point_distance(_args[0], _args[1], _args[2], _args[3]);
});

proglang_function_register("point_direction", function(_args) {
    return point_direction(_args[0], _args[1], _args[2], _args[3]);
});

proglang_function_register("power", function(_args) {
    return power(_args[0], _args[1]);
});

proglang_function_register("sqrt", function(_args) {
    return sqrt(_args[0]);
});

proglang_function_register("sqr", function(_args) {
    return sqr(_args[0]);
});

proglang_function_register("frac", function(_args) {
    return frac(_args[0]);
});

proglang_function_register("sin", function(_args) {
    return sin(_args[0]);
});

proglang_function_register("cos", function(_args) {
    return cos(_args[0]);
});

proglang_function_register("tan", function(_args) {
    return tan(_args[0]);
});

proglang_function_register("dsin", function(_args) {
    return dsin(_args[0]);
});

proglang_function_register("dcos", function(_args) {
    return dcos(_args[0]);
});

proglang_function_register("dtan", function(_args) {
    return dtan(_args[0]);
});

proglang_function_register("degtorad", function(_args) {
    return degtorad(_args[0]);
});

proglang_function_register("radtodeg", function(_args) {
    return radtodeg(_args[0]);
});



proglang_function_register("exp", function(_args) {
    return exp(_args[0]);
});

proglang_function_register("ln", function(_args) {
    return ln(_args[0]);
});

proglang_function_register("log2", function(_args) {
    return log2(_args[0]);
});

proglang_function_register("log10", function(_args) {
    return log10(_args[0]);
});

proglang_function_register("arcsin", function(_args) {
    return arcsin(_args[0]);
});

proglang_function_register("arccos", function(_args) {
    return arccos(_args[0]);
});

proglang_function_register("arctan", function(_args) {
    return arctan(_args[0]);
});

proglang_function_register("arctan2", function(_args) {
    return arctan2(_args[0], _args[1]);
});


proglang_function_register("randomize", function(_args) {
    randomize();
});

proglang_function_register("random", function(_args) {
    return random(_args[0]);
});

proglang_function_register("irandom", function(_args) {
    return irandom(_args[0]);
});

proglang_function_register("random_range", function(_args) {
    return random_range(_args[0], _args[1]);
});

proglang_function_register("chance", function(_args) {
    return chance(_args[0]);
});

proglang_function_register("choose", function(_args) {
    if (!is_array(_args[0]) || array_length(_args[0]) == 0) {
        return undefined;
    }

    return array_choose(_args[0]);
});

proglang_function_register("string", function(_args) {
    return string(_args[0]);
});

proglang_function_register("real", function(_args) {
    return real(_args[0]);
});

#endregion

proglang_function_register("lengthdir_x", function(_args) {
    return lengthdir_x(_args[0], _args[1]);
});

proglang_function_register("lengthdir_y", function(_args) {
    return lengthdir_y(_args[0], _args[1]);
});

#endregion
proglang_function_register("worldgen_get_heat", function(_args)
{
    var _x = _args[0] / TILE_SIZE;
    var _y = _args[1] / TILE_SIZE;
    var _seed = _args[2];
    
    return worldgen_get_heat(_x, _y, _seed);
});

proglang_function_register("worldgen_get_humidity", function(_args)
{
    var _x = _args[0] / TILE_SIZE;
    var _y = _args[1] / TILE_SIZE;
    var _seed = _args[2];
    
    return worldgen_get_humidity(_x, _y, _seed);
});



proglang_function_register("string_char_at", function(_args)
{
    return string_char_at(_args[0], _args[1]);
});

proglang_function_register("string_length", function(_args)
{
    return string_length(_args[0]);
});

proglang_function_register("string_pos", function(_args)
{
    return string_pos(_args[0], _args[1]);
});

proglang_function_register("string_delete", function(_args)
{
    return string_delete(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_insert", function(_args)
{
    return string_insert(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_replace", function(_args)
{
    return string_replace(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_replace_all", function(_args)
{
    return string_replace_all(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_upper", function(_args)
{
    return string_upper(_args[0]);
});

proglang_function_register("string_lower", function(_args)
{
    return string_lower(_args[0]);
});

proglang_function_register("string_width", function(_args)
{
    return string_width(_args[0]);
});

proglang_function_register("string_height", function(_args)
{
    return string_height(_args[0]);
});

proglang_function_register("chr", function(_args)
{
    return chr(_args[0]);
});

proglang_function_register("ord", function(_args)
{
    return ord(_args[0]);
});

// Data Structures
proglang_function_register("array_length", function(_args)
{
    return array_length(_args[0]);
});

proglang_function_register("array_push", function(_args)
{ 
    var _arr = _args[0];
    for(var i=1; i<array_length(_args); i++) array_push(_arr, _args[i]);
});

proglang_function_register("array_pop", function(_args)
{
    return array_pop(_args[0]);
});

proglang_function_register("array_resize", function(_args)
{
    array_resize(_args[0], _args[1]);
});



proglang_function_register("array_copy", function(_args)
{
    array_copy(_args[0], _args[1], _args[2], _args[3], _args[4]);
});

proglang_function_register("struct_get_names", function(_args)
{
    return struct_get_names(_args[0]);
});

proglang_function_register("struct_get", function(_args)
{
    return struct_get(_args[0], _args[1]);
});



proglang_function_register("struct_names_count", function(_args)
{
    return struct_names_count(_args[0]);
});

proglang_function_register("struct_stringify", function(_args)
{
    return json_stringify(_args[0]);
});

proglang_function_register("struct_parse", function(_args)
{
    return json_parse(_args[0]);
});

// GAME
// proglang_

proglang_function_register("tile_get", function(_args) {
    var _tile = tile_get(_args[0], _args[1], _args[2]);
    
    return ((_tile != TILE_EMPTY) ? _tile : undefined);
});

proglang_function_register("tile_place", function(_args) {
    var _x = _args[1];
    var _y = _args[2];
    var _z = _args[3];
    
    tile_place(_x, _y, _z, _args[0] ?? TILE_EMPTY);
    tile_update_surrounding(_x, _y, _z);
});

proglang_function_register("tile_harvest_drop", function(_args) {
    var _x = _args[0];
    var _y = _args[1];
    var _z = _args[2];
    var _tile = _args[3] ?? tile_get(_x, _y, _z);
    
    if (_tile != TILE_EMPTY)
    {
        tile_harvest_drop(_x, _y, _z, _tile);
    }
});

proglang_function_register("get_item", function(_args) {
    return global.item_data[$ _args[0]];
});

proglang_function_register("global_get", function(_args) {
    var _key = _args[0];
    if (_key == "world_data") return global.world_data[$ global.world_save_data.dimension];
    if (_key == "world") return global.world_save_data;  
    if (_key == "item_data") return global.item_data;
    return undefined;
});

proglang_function_register("camera_shake", function(_args) {
    global.camera_shake = _args[0];
});

proglang_function_register("spawn_particle", function(_args) {
    show_debug_message(_args)
    var _x = _args[1];
    
    if (_x == undefined) exit;
    
    var _y = _args[2];
    
    if (_y == undefined) exit;
    
    show_debug_message($"{_x} {_y}")
    
    spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, _args[0]);
});

proglang_function_register("tag_get", function(_args) {
    return global.tag_data[$ $"#{_args[0]}"];
});

proglang_function_register("smart_value", function(_args) {
    return smart_value(_args[0]);
});

proglang_function_register("sfx_diegetic_play", function(_args) {
    var _emitter = _args[0];
    var _x = _args[1];
    var _y = _args[2];
    var _id = _args[3];
    var _volume = (array_length(_args) > 4) ? _args[4] : 1;
    var _pitch = (array_length(_args) > 5) ? _args[5] : 1;
    
    return sfx_diegetic_play(_emitter, _x, _y, _id, _volume, _pitch);
});

proglang_function_register("control_entity_damage", function(_args) {
    return control_entity_damage(_args[0], _args[1], _args[2]);
});

proglang_function_register("control_entity_heal", function(_args) {
    return control_entity_heal(_args[0], _args[1], _args[2]);
});

proglang_function_register("wait", function(_args, _vm) {
    if (array_length(_args) < 3) return;
    
    var _callback = _args[0];
    var _params = _args[1];
    var _seconds = _args[2];
    
    if (!is_array(_params)) _params = [_params];

    // If _callback is a Proglang closure, we need to handle its execution
    if (is_array(_callback) && array_length(_callback) >= PROG_CLOSURE.SIZE && _callback[PROG_CLOSURE.TYPE] == "closure") {
        call_later(_seconds, time_source_units_seconds, function(_data) {
            var _vm = proglang_vm_create();
            _vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _data.env;
            proglang_vm_run(_vm, _data.bytecode, _data.args);
            proglang_vm_free(_vm);
        }, false, { bytecode: _callback[PROG_CLOSURE.BYTECODE], env: _callback[PROG_CLOSURE.ENV], args: _params });
    } else {
        call_later(_seconds, time_source_units_seconds, function(_data) {
            _data.func(_data.args);
        }, false, { func: _callback, args: _params });
    }
});

proglang_function_register("tile_audio_emitter", function(_args) {
    return tile_audio_emitter(_args[0], _args[1]);
});

proglang_function_register("loca_translate", function(_args) {
    return loca_translate(_args[0]);
});

proglang_function_register("spawn_projectile", function(_args) {
    return spawn_projectile(_args[0], _args[1], _args[2], _args[3], _args[4] ?? 1, _args[5] ?? 1);
});

proglang_function_register("inventory_item_create", function(_args) {
    return new Inventory(_args[0], _args[1] ?? 1);
});

proglang_function_register("spawn_item_drop", function(_args) {
    var _x = _args[0] * TILE_SIZE;
    var _y = _args[1] * TILE_SIZE;
    var _item = _args[2];
    
    spawn_item_drop(_x, _y, _item);
});

proglang_function_register("menu_popup_create", function(_args) {
    return menu_popup_create(_args[0]);
});

proglang_function_register("instance_create_layer", function(_args) {
    var _x = _args[0];
    var _y = _args[1];
    var _layer = _args[2];
    var _obj_name = _args[3];
    
    var _obj = asset_get_index(_obj_name);
    if (_obj == -1) return noone;
    
    return instance_create_layer(_x, _y, _layer, _obj);
});

proglang_function_register("tile_update_surrounding", function(_args) {
    tile_update_surrounding(_args[0], _args[1], _args[2]);
});

proglang_function_register("asset_get_index", function(_args) {
    return asset_get_index(_args[0]);
});

proglang_function_register("entity_query_circle", function(_args) {
    var _x = _args[0];
    var _y = _args[1];
    var _r = _args[2];
    
    var _list = ds_list_create();
    var _count = collision_circle_list(_x, _y, _r, obj_Entity, false, true, _list, false);
    
    var _res = [];
    for (var i = 0; i < _count; i++) {
        array_push(_res, _list[| i]);
    }
    
    ds_list_destroy(_list);
    return _res;
});

proglang_function_register("entity_get_x", function(_args) {
    var _id = _args[0];
    if (!instance_exists(_id)) return 0;
    return _id.x;
});

proglang_function_register("entity_get_y", function(_args) {
    var _id = _args[0];
    if (!instance_exists(_id)) return 0;
    return _id.y;
});

proglang_function_register("entity_get_stamina", function(_args) {
    var _id = _args[0];
    if (!instance_exists(_id)) return 0;
    if (variable_instance_exists(_id, "stamina")) return _id.stamina;
    return 0;
});

proglang_function_register("entity_set_stamina", function(_args) {
    var _id = _args[0];
    var _val = _args[1];
    if (!instance_exists(_id)) return;
    if (variable_instance_exists(_id, "stamina")) _id.stamina = _val;
});

proglang_function_register("entity_set_velocity", function(_args) {
    var _id = _args[0];
    var _vx = _args[1];
    var _vy = _args[2];
    
    if (!instance_exists(_id)) return;
    
    if (variable_instance_exists(_id, "physics_body"))
    {
        _id.physics_body.vel_x = _vx;
        _id.physics_body.vel_y = _vy;
    }
});

proglang_function_register("entity_set_dash_timer", function(_args) {
    var _id = _args[0];
    var _val = _args[1];
    if (instance_exists(_id)) _id.timer_dash = _val;
});

proglang_function_register("file_exists", function(_args) {
    return file_exists(_args[0]);
});

proglang_function_register("callback", function(_args) {
    var _closure = _args[0];
    var _cb_args = (array_length(_args) > 1) ? _args[1] : [];
    
    var _wrapper = function() {
        var _c = self.___closure;
        var _a = self.___args;
        var _vm = proglang_vm_create();
        _vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _c[PROG_CLOSURE.ENV];
        _vm[@ PROG_VM.CURRENT_THIS] = self;
        proglang_vm_run(_vm, _c[PROG_CLOSURE.BYTECODE], _a);
        proglang_vm_free(_vm);
    }
    
    var _inst = { ___closure: _closure, ___args: _cb_args }
    return method(_inst, _wrapper);
});

proglang_function_register("liquid_flow_start", function(_args) {
    liquid_flow_start(_args[0], _args[1], _args[2], (array_length(_args) > 3) ? _args[3] : {});
});

proglang_function_register("render_text", function(_args) {
    render_text(_args[0], _args[1], _args[2], _args[3], _args[4]);
});

proglang_function_register("draw_get_halign", function(_args) {
    return draw_get_halign();
});

proglang_function_register("draw_get_valign", function(_args) {
    return draw_get_valign();
});

proglang_function_register("draw_set_halign", function(_args) {
    draw_set_halign(_args[0]);
});

proglang_function_register("draw_set_valign", function(_args) {
    draw_set_valign(_args[0]);
});

proglang_function_register("menu_popup_destroy", function(_args) {
    menu_popup_destroy();
});

proglang_function_register("buffer_create", function(_args) {
    return buffer_create(_args[0], _args[1], _args[2]);
});

proglang_function_register("buffer_write", function(_args) {
    buffer_write(_args[0], _args[1], _args[2]);
});

proglang_function_register("buffer_save_compressed", function(_args) {
    buffer_save_compressed(_args[0], _args[1]);
});

proglang_function_register("buffer_delete", function(_args) {
    buffer_delete(_args[0]);
});

proglang_function_register("file_save_snippet_tile", function(_args) {
    file_save_snippet_tile(_args[0], _args[1], global.item_data, _args[2]);
});

proglang_function_register("inventory_get", function(_args) {
    var _uuid = _args[0];
    var _type = _args[1];
    var _index = _args[2];
    
    var _inv = undefined;
    if (_uuid == "player") {
        _inv = global.inventory[$ _type];
    } else {
        _inv = global.inventory[$ _type];
    }
    
    if (_inv == undefined) return undefined;
    
    var _item = undefined;
    if (is_array(_inv)) {
        if (_index < 0 || _index >= array_length(_inv)) return undefined;
        _item = _inv[_index];
    } else if (is_struct(_inv)) {
        if (struct_exists(_inv, "item")) _item = _inv.item;
        else _item = _inv;
    }
    
    return (_item == INVENTORY_EMPTY) ? undefined : _item;
});

proglang_function_register("inventory_set", function(_args) {
    var _uuid = _args[0];
    var _type = _args[1];
    var _index = _args[2];
    var _item = _args[3];
    
    var _set_item = (_item == undefined) ? INVENTORY_EMPTY : _item;
    
    if (_uuid == "player") {
        var _inv = global.inventory[$ _type];
        if (_inv == undefined) return;
        
        if (is_array(_inv)) {
            if (_index >= 0 && _index < array_length(_inv)) {
                _inv[@ _index] = _set_item;
            }
        } else if (is_struct(_inv)) {
            if (struct_exists(_inv, "item")) _inv.item = _set_item;
        }
    }
    
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
});

proglang_function_register("instance_exists", function(_args) {
    return instance_exists(_args[0]);
});

proglang_function_register("instance_destroy", function(_args) {
    instance_destroy(_args[0]);
});

// Old inventory and depth functions removed

proglang_function_register("layer_get_id", function(_args) {
    return layer_get_id(_args[0]);
});

proglang_function_register("tag_value_parse", function(_args) {
	return tag_value_parse(_args[0]);
});




// Print
proglang_function_register("print", function(_args)
{
    var _length = array_length(_args);
    
    var _string = "";
    
    for (var i = 0; i < _length; i++)
    {
        if (i > 0)
        {
            _string += " ";
        }
        
        _string += string(_args[i]);
    }
    
    show_debug_message(_string);
});

// Type checking
proglang_function_register("typeof", function(_args)
{
    var _val = _args[0];
    
    if (is_undefined(_val))
    {
        return "undefined";
    }
    
    if (is_bool(_val))
    {
        return "boolean";
    }
    
    if (is_real(_val))
    {
        return "number";
    }
    
    if (is_string(_val))
    {
        return "string";
    }
    
    // Check for closures/functions BEFORE generic array check
    if (is_array(_val))
    {
        // Check if it's a Proglang closure
        if (array_length(_val) >= PROG_CLOSURE.SIZE && _val[PROG_CLOSURE.TYPE] == "closure")
        {
            return "function";
        }
        // Check if it's a Proglang function
        if (array_length(_val) >= PROG_FUNC.SIZE && _val[PROG_FUNC.TYPE] == "function")
        {
            return "function";
        }
        // Otherwise it's a regular array
        return "array";
    }
    
    if (is_struct(_val))
    {
        if (struct_exists(_val, "function"))
        {
            return "function";
        }

        // Check for Regex instance or struct with __type__ == "regex"
        if ((is_instanceof(_val, Regex)) || (_val[$ "__type__"] == "regex"))
        {
            return "regex";
        }
        
        // Class instance (has __class__)
        if (_val[$ "__class__"] != undefined)
        {
            return "object";
        }
        
        // Class definition (has __type__ == "class")
        if (_val[$ "__type__"] == "class")
        {
            return "object";
        }
        
        // Plain struct
        return "struct";
    }
    
    if (is_method(_val))
    {
        return "function";
    }
    
    return "unknown";
});

proglang_function_register("is_string", function(_args) { return is_string(_args[0]); });
proglang_function_register("is_real", function(_args) { return is_real(_args[0]); });
proglang_function_register("is_numeric", function(_args) { return is_numeric(_args[0]); });
proglang_function_register("is_bool", function(_args) { return is_bool(_args[0]); });
proglang_function_register("is_array", function(_args) { return is_array(_args[0]); });
proglang_function_register("is_struct", function(_args) { return is_struct(_args[0]); });
proglang_function_register("is_undefined", function(_args) { return is_undefined(_args[0]); });

proglang_function_register("is_regex", function(_args)
{
    var _val = _args[0];
    return (is_instanceof(_val, Regex)) || (is_struct(_val) && struct_exists(_val, "__type__") && _val.__type__ == "regex");
});

// Runtime error function (throws an error that can be caught)
proglang_function_register("runtime_error", function(_args)
{
    var _type = (array_length(_args) > 0) ? _args[0] : PROGLANG_ERROR_TYPE.RUNTIME;
    var _msg = (array_length(_args) > 1) ? _args[1] : "Runtime error";
    throw { type: _type, message: _msg }
});

// Debug & Utils
proglang_function_register("assert", function(_args)
{
    if (!_args[0])
    {
        var _msg = (array_length(_args) > 1) ? _args[1] : "Assertion failed";
        throw { type: PROGLANG_ERROR_TYPE.RUNTIME, message: _msg }
    }
});

proglang_function_register("time_start", function(_args)
{
    var _name = _args[0];
    if (!variable_global_exists("proglang_timers")) global.proglang_timers = {}
    global.proglang_timers[$ _name] = get_timer();
});

proglang_function_register("time_end", function(_args)
{
    var _name = _args[0];
    if (!variable_global_exists("proglang_timers") || !struct_exists(global.proglang_timers, _name))
    {
        throw { type: PROGLANG_ERROR_TYPE.RUNTIME, message: $"Timer '{_name}' does not exist." }
    }
    var _start = global.proglang_timers[$ _name];
    var _time = (get_timer() - _start) / 1000; // ms
    struct_remove(global.proglang_timers, _name);
    return _time;
});

// Regex
proglang_function_register("regex_parse", function(_args) { return new Regex(_args[0], array_length(_args)>1 ? _args[1] : ""); });
proglang_function_register("regex_test", function(_args)
{ 
    if (!is_struct(_args[1]) || !struct_exists(_args[1], "test"))
    {
            throw { type: PROGLANG_ERROR_TYPE.TYPE, message: "Expected regex object." }
    }
    return _args[1].test(_args[0]); 
});
proglang_function_register("regex_match", function(_args) { return _args[1].match(_args[0]); });
proglang_function_register("regex_match_index", function(_args) { return _args[1].match_index(_args[0]); });
proglang_function_register("regex_replace", function(_args) { return _args[1].replace(_args[0], _args[2]); });
proglang_function_register("regex_replace_all", function(_args) { return _args[1].replace(_args[0], _args[2]); });
proglang_function_register("regex_split", function(_args) { return _args[1].split(_args[0]); });


#region Rendering

proglang_function_register("render_rectangle", function(_args)
{
    var _x1 = _args[0];
    var _y1 = _args[1];
    var _x2 = _args[2];
    var _y2 = _args[3];
    var _outline = (array_length(_args) > 4) ? _args[4] : false;
    
    draw_rectangle(_x1, _y1, _x2, _y2, _outline);
});

proglang_function_register("render_circle", function(_args)
{
    var _x = _args[0];
    var _y = _args[1];
    var _r = _args[2];
    var _outline = (array_length(_args) > 3) ? _args[3] : false;
    
    draw_circle(_x, _y, _r, _outline);
});

proglang_function_register("render_text", function(_args)
{
    var _text = string(_args[0]);
    var _x = _args[1];
    var _y = _args[2];
    
    draw_text(_x, _y, _text);
});

proglang_function_register("render_sprite", function(_args)
{
    var _name = _args[0];
    var _x = _args[1];
    var _y = _args[2];
    var _frame = (array_length(_args) > 3) ? _args[3] : 0;
    
    var _asset = asset_get_index(_name);
    if (_asset != -1 && asset_get_type(_name) == asset_sprite)
    {
        draw_sprite(_asset, _frame, _x, _y);
    }
});

#endregion

global.proglang_test_state = {
    current_failures: [],
    current_assertions: 0,
    in_test: false
}

proglang_function_register("test_expect", function(_args, _vm = undefined)
{
    // Guard: test_expect must be called inside a test
    if (!global.proglang_test_state.in_test)
    {
        throw { type: PROGLANG_ERROR_TYPE.RUNTIME, message: "test_expect() can only be called inside a test or test_group." }
    }
    
    var _actual = _args[0];
    var _expected = _args[1];
    
    // Execute actual if it's a closure/function
    if (is_array(_actual) && array_length(_actual) >= PROG_CLOSURE.SIZE && _actual[PROG_CLOSURE.TYPE] == "closure")
    {
        var _eval_vm = proglang_vm_create();
        // Propagate global_ref from calling VM
        if (_vm != undefined) _eval_vm[@ PROG_VM.GLOBAL_REF] = _vm[PROG_VM.GLOBAL_REF];
        _eval_vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _actual[PROG_CLOSURE.ENV];
        _actual = proglang_vm_run(_eval_vm, _actual[PROG_CLOSURE.BYTECODE]);
        proglang_vm_free(_eval_vm);
    }
    else if (is_struct(_actual) && struct_exists(_actual, "function"))
    {
        _actual = _actual[$ "function"]([]);
    }
    
    // Execute expected if it's a closure/function
    if (is_array(_expected) && array_length(_expected) >= PROG_CLOSURE.SIZE && _expected[PROG_CLOSURE.TYPE] == "closure")
    {
        var _eval_vm = proglang_vm_create();
        // Propagate global_ref from calling VM
        if (_vm != undefined) _eval_vm[@ PROG_VM.GLOBAL_REF] = _vm[PROG_VM.GLOBAL_REF];
        _eval_vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _expected[PROG_CLOSURE.ENV];
        _expected = proglang_vm_run(_eval_vm, _expected[PROG_CLOSURE.BYTECODE]);
        proglang_vm_free(_eval_vm);
    }
    else if (is_struct(_expected) && struct_exists(_expected, "function"))
    {
        _expected = _expected[$ "function"]([]);
    }
    
    ++global.proglang_test_state.current_assertions;
    
    if (_actual != _expected)
    {
        var _msg = $"Expected {_expected}, got {_actual}";
        array_push(global.proglang_test_state.current_failures, _msg);
        return false;
    }
    return true;
});

/// test(name, fn, stop_on_failure) - Runs a test function, measures time, prints summary on completion
/// Returns { passed: bool, time_ms: number, failures: array }
global.proglang_pending_tests = [];

function proglang_reset_pending()
{
    global.proglang_pending_tests = [];
}

function proglang_run_pending()
{
    var _tests = global.proglang_pending_tests;
    for (var i = 0; i < array_length(_tests); i++)
    {
        var _test = _tests[i];
        
        // Skip handled tests (ones that were inside a group)
        if (is_struct(_test) && struct_exists(_test, "handled") && _test.handled) continue;
        
        if (struct_exists(_test, "__type__") && _test.__type__ == "Group")
        {
            // Execute Group
            var _group_name = _test.name;
            var _group_tests = _test.tests;
            
            var _start = get_timer();
            var _total = array_length(_group_tests);
            var _passed = 0;
            var _failed = 0;
            
            show_debug_message($"━━━ {_group_name} ━━━");
            
            for (var j = 0; j < _total; j++)
            {
                var _t_res = _proglang_run_test_internal(_group_tests[j], $"Test {j + 1}");
                
                var _t_time = _t_res.time_ms;
                var _t_name = _t_res.name;
                
                if (_t_res.passed)
                {
                    ++_passed;
                    
                    show_debug_message($"  ✓ {_t_name} ({_t_time}ms)");
                }
                else
                {
                    ++_failed;
                    
                    show_debug_message($"  ✗ {_t_name} ({_t_time}ms)");
                    
                    for (var k = 0; k < array_length(_t_res.failures); k++)
                    {
                        show_debug_message($"    - {_t_res.failures[k]}");
                    }
                    
                    if (_t_res.error != undefined)
                    {
                        var _err_msg = is_struct(_t_res.error) && struct_exists(_t_res.error, "message") ? _t_res.error.message : string(_t_res.error);
                        
                        show_debug_message($"    - Error: {_err_msg}");
                    }
                }
            }
            
            var _total_time = (get_timer() - _start) / 1000;
            if (_failed == 0) show_debug_message($"━━━ {_passed}/{_total} passed ({_total_time}ms) ━━━");
            else show_debug_message($"━━━ {_passed}/{_total} passed, {_failed} failed ({_total_time}ms) ━━━");
        }
        else if (struct_exists(_test, "__type__") && _test.__type__ == "Test")
        {
            // Execute Single Test
            var _t_res = _proglang_run_test_internal(_test, _test.name);
            var _t_time = _t_res.time_ms;
            
            if (_t_res.passed)
            {
                show_debug_message($"✓ {_test.name} ({_t_time}ms)");
            }
            else
            {
                show_debug_message($"✗ {_test.name} ({_t_time}ms)");
                for (var k = 0; k < array_length(_t_res.failures); k++)
                {
                    show_debug_message($"  - {_t_res.failures[k]}");
                }
                if (_t_res.error != undefined)
                {
                    var _err_msg = is_struct(_t_res.error) && struct_exists(_t_res.error, "message") ? _t_res.error.message : string(_t_res.error);
                    show_debug_message($"  - Error: {_err_msg}");
                }
            }
        }
    }
}

function _proglang_run_test_internal(_test_struct, _default_name)
{
    var _name = _default_name;
    var _fn = undefined;
    
    if (is_struct(_test_struct)) && (_test_struct[$ "__type__"] == "Test")
    {
        _name = _test_struct.name;
        _fn = _test_struct.fn;
    }
    else if (is_struct(_test_struct) && struct_exists(_test_struct, "fn"))
    {
        _name = struct_exists(_test_struct, "name") ? _test_struct.name : _default_name;
        _fn = _test_struct.fn;
    }
    else
    {
        _fn = _test_struct;
    }
    
    // Support Test N: 'name' format if we have a real name
    if (_name != _default_name && string_pos(_default_name, "Test") == 1)
    {
         _name = $"{_default_name}: '{_name}'";
    }

    // Reset test state
    global.proglang_test_state.current_failures = [];
    global.proglang_test_state.current_assertions = 0;
    global.proglang_test_state.in_test = true;
    
    var _start = get_timer();
    var _error = undefined;
    
    try
    {
        // Execute the test function
        if (is_array(_fn) && array_length(_fn) >= PROG_CLOSURE.SIZE && _fn[PROG_CLOSURE.TYPE] == "closure")
        {
            var _vm = proglang_vm_create();
            // Use captured global_ref if available
            if (is_struct(_test_struct) && struct_exists(_test_struct, "global_ref") && _test_struct.global_ref != undefined)
            {
                _vm[@ PROG_VM.GLOBAL_REF] = _test_struct.global_ref;
            }
            _vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _fn[PROG_CLOSURE.ENV];
            
            // Propagate __filename for import resolution
            if (is_struct(_test_struct) && struct_exists(_test_struct, "__filename") && _test_struct.__filename != undefined)
            {
                _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _test_struct.__filename;
                _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = proglang_get_directory(_test_struct.__filename);
            }
            
            proglang_vm_run(_vm, _fn[PROG_CLOSURE.BYTECODE]);
            proglang_vm_free(_vm);
        }
        else if (is_struct(_fn)) && (struct_exists(_fn, "function"))
        {
            _fn[$ "function"]([]);
        }
    }
    catch (_e)
    {
        _error = _e;
    }
    
    var _time_ms = (get_timer() - _start) / 1000;
    var _failures = global.proglang_test_state.current_failures;
    var _passed = array_length(_failures) == 0 && _error == undefined;
    
    // Reset in_test flag after test completes
    global.proglang_test_state.in_test = false;
    
    return { passed: _passed, time_ms: _time_ms, failures: _failures, error: _error, name: _name }
}

proglang_function_register("test", function(_args, _vm = undefined)
{
    var _name = _args[0];
    var _function = _args[1];
    
    var _stop_on_fail = ((array_length(_args) > 2) ? _args[2] : false);
    
    var _test_struct = {
        __type__: "Test",
        name: _name,
        fn: _function,
        stop_on_fail: _stop_on_fail,
        handled: false,
        global_ref: (_vm != undefined) ? _vm[PROG_VM.GLOBAL_REF] : undefined,
        __filename: undefined
    }
    
    if (_vm != undefined)
    {
        var _s = proglang_vm_find_var_scope(_vm, "__filename");
        if (_s != undefined)
        {
            _test_struct.__filename = _s[PROG_SCOPE.VARS][$ "__filename"];
            // show_debug_message($"[Test] Captured filename: {_test_struct.__filename}");
        }
        else
        {
             if (IS_DEVELOPER_MODE) show_debug_message($"[Test] Warning: __filename not found in scope for test '{_name}'");
        }
    }
    else
    {
         if (IS_DEVELOPER_MODE) show_debug_message($"[Test] Warning: VM undefined for test '{_name}'");
    }
    
    array_push(global.proglang_pending_tests, _test_struct);
    
    return _test_struct;
});

/// test_group(name, tests) - Registers a test group
proglang_function_register("test_group", function(_args, _vm = undefined)
{
    var _group_name = _args[0];
    var _tests = _args[1];
    
    for (var i = 0; i < array_length(_tests); i++)
    {
        var _t = _tests[i];
        
        if (is_struct(_t)) && (_t[$ "__type__"] == "Test")
        {
            _t.handled = true;
            // Propagate global_ref if not already set
            if (!struct_exists(_t, "global_ref") || _t.global_ref == undefined)
            {
                _t.global_ref = (_vm != undefined) ? _vm[PROG_VM.GLOBAL_REF] : undefined;
            }
        }
    }
    
    var _group_struct = {
        __type__: "Group",
        name: _group_name,
        tests: _tests,
        global_ref: (_vm != undefined) ? _vm[PROG_VM.GLOBAL_REF] : undefined
    }
    
    array_push(global.proglang_pending_tests, _group_struct);
    
    return _group_struct;
});

#region RAII Resources

proglang_function_register("ds_list_create", function(_args, _vm) {
    var _list = ds_list_create();
    // Auto-track with current scope
    proglang_scope_track_resource(_vm[PROG_VM.SCOPE], "__ds_list__", _list);
    return _list;
});

proglang_function_register("ds_list_destroy", function(_args) {
    if (ds_exists(_args[0], ds_type_list)) ds_list_destroy(_args[0]);
});

proglang_function_register("ds_list_add", function(_args) {
    ds_list_add(_args[0], _args[1]);
});

proglang_function_register("ds_list_size", function(_args) {
    return ds_list_size(_args[0]);
});

proglang_function_register("buffer_create", function(_args, _vm) {
    var _size = _args[0];
    var _type = _args[1]; // buffer_fixed, etc. need macros exposed?
    var _alignment = _args[2];
    var _buf = buffer_create(_size, _type, _alignment);
    
    proglang_scope_track_resource(_vm[PROG_VM.SCOPE], "__buffer__", _buf);
    return _buf;
});

proglang_function_register("buffer_delete", function(_args) {
    if (buffer_exists(_args[0])) buffer_delete(_args[0]);
});

#endregion

#region UI System

proglang_function_register("ui_load", function(_args) {
    var _path = _args[0];
    return ui_load(_path);
});

proglang_function_register("ui_spawn", function(_args) {
    var _definitions = _args[0];
    var _config = (array_length(_args) > 1) ? _args[1] : {};
    var _events = (array_length(_args) > 2) ? _args[2] : undefined;
    return ui_spawn(_definitions, _config, _events);
});

proglang_function_register("ui_destroy", function(_args) {
    ui_destroy(_args[0]);
});

proglang_function_register("ui_get", function(_args) {
    var _instance = _args[0];
    var _name = _args[1];
    return ui_get(_instance, _name);
});

proglang_function_register("ui_set", function(_args) {
    var _instance = _args[0];
    var _name = _args[1];
    var _property = _args[2];
    var _value = _args[3];
    ui_set(_instance, _name, _property, _value);
});

proglang_function_register("ui_refresh", function(_args) {
    ui_refresh(_args[0]);
});

proglang_function_register("ui_update", function(_args) {
    ui_update(_args[0]);
});

proglang_function_register("ui_draw", function(_args) {
    ui_draw(_args[0]);
});

proglang_function_register("ui_event", function(_args) {
    ui_event(_args[0]);
});

proglang_function_register("ui_mark_dirty", function(_args) {
    ui_mark_dirty(_args[0]);
});

proglang_function_register("ui_clear_events", function(_args) {
    ui_clear_events();
});

#endregion

#region Cloud System

proglang_function_register("cloud_spawn", function(_args) {
    var _sprite_id = _args[0];
    var _x = _args[1];
    var _y = _args[2];
    var _scale = (array_length(_args) > 3) ? _args[3] : 1;
    var _alpha = (array_length(_args) > 4) ? _args[4] : 1;
    var _speed = (array_length(_args) > 5) ? _args[5] : 8;
    
    return cloud_spawn(_sprite_id, _x, _y, _scale, _alpha, _speed);
});

proglang_function_register("cloud_clear", function(_args) {
    cloud_clear();
});

proglang_function_register("cloud_set_tint", function(_args) {
    cloud_set_tint(_args[0]);
});

proglang_function_register("cloud_set_wind_factor", function(_args) {
    cloud_set_wind_factor(_args[0]);
});

proglang_function_register("cloud_set_sprites", function(_args) {
    cloud_set_sprites(_args[0]);
});

proglang_function_register("cloud_set_speed", function(_args) {
    cloud_set_speed(_args[0]);
});

proglang_function_register("cloud_get_wind", function(_args) {
    return global.world_save_data.weather_wind;
});

proglang_function_register("cloud_get_time", function(_args) {
    return global.world_save_data.time;
});

#endregion

#region Drawing

proglang_function_register("draw_sprite", function(_args) {
    if (array_length(_args) < 4) return;
    
    var _id = _args[0];
    var _subimg = _args[1];
    var _x = _args[2];
    var _y = _args[3];
    
    if (is_string(_id)) {
        var _asset = global.sprite_asset[$ _id];
        if (_asset != undefined) {
             var _spr = _asset.get_sprite();
             if (_spr != -1) draw_sprite(_spr, _subimg, _x, _y);
        }
    } else {
        draw_sprite(_id, _subimg, _x, _y);
    }
});

proglang_function_register("draw_sprite_ext", function(_args) {
    if (array_length(_args) < 9) return;
    
    var _id = _args[0];
    var _subimg = _args[1];
    var _x = _args[2];
    var _y = _args[3];
    var _xscale = _args[4];
    var _yscale = _args[5];
    var _rot = _args[6];
    var _col = _args[7];
    var _alpha = _args[8];
    
    if (is_string(_col)) _col = hex_parse(_col);
    
    if (is_string(_id)) {
        var _asset = global.sprite_asset[$ _id];
        if (_asset != undefined) {
             var _spr = _asset.get_sprite();
             if (_spr != -1) draw_sprite_ext(_spr, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha);
        }
    } else {
        draw_sprite_ext(_id, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha);
    }
});

proglang_function_register("draw_set_color", function(_args) {
    if (array_length(_args) < 1) return;
    var _col = _args[0];
    if (is_string(_col)) _col = hex_parse(_col);
    draw_set_color(_col);
});

proglang_function_register("draw_set_alpha", function(_args) {
    if (array_length(_args) < 1) return;
    draw_set_alpha(_args[0]);
});

proglang_function_register("draw_rectangle", function(_args) {
    if (array_length(_args) < 5) return;
    draw_rectangle(_args[0], _args[1], _args[2], _args[3], _args[4]);
});

proglang_function_register("gui_get_width", function(_args) {
    return display_get_gui_width();
});

proglang_function_register("gui_get_height", function(_args) {
    return display_get_gui_height();
});

proglang_function_register("celestial_get_active", function(_args) {
    return celestial_get_active(_args[0]);
});

proglang_function_register("array_length", function(_args) {
    if (!is_array(_args[0])) return 0;
    return array_length(_args[0]);
});

proglang_function_register("debug_log", function(_args) {
    var _str = "";
    if (array_length(_args) > 0) _str = string(_args[0]);
    for (var i = 1; i < array_length(_args); i++) {
        _str += " " + string(_args[i]);
    }
    show_debug_message("[Daydream Script] " + _str);
});

proglang_function_register("sprite_get_width", function(_args) {
    var _id = _args[0];
    if (is_string(_id)) {
        var _asset = global.sprite_asset[$ _id];
         if (_asset != undefined) {
             var _spr = _asset.get_sprite();
             if (_spr != -1) return sprite_get_width(_spr);
        }
        return 0;
    }
    return sprite_get_width(_id);
});

proglang_function_register("sprite_get_height", function(_args) {
    var _id = _args[0];
    if (is_string(_id)) {
        var _asset = global.sprite_asset[$ _id];
         if (_asset != undefined) {
             var _spr = _asset.get_sprite();
             if (_spr != -1) return sprite_get_height(_spr);
        }
        return 0;
    }
    return sprite_get_height(_id);
});

#endregion
