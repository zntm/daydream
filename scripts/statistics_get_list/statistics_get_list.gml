function statistics_get_list(_stats, _category)
{
    var _list = [];
    
    // Helper to get value safely
    var _get_val = function(_s, _k) { return _s[$ _k] ?? 0; }
    
    // --- GENERAL ---
    if (_category == "general")
    {
        var _keys = [
            "distance_walked", 
            "distance_flown", 
            "distance_swum", 
            "distance_climbed", 
            "distance_travelled",
            "tiles_placed", 
            "tiles_broken", 
            "items_collected", 
            "items_used",
            "damage_dealt", 
            "damage_taken", 
            "deaths", 
            "mobs_killed"
        ];
        
        var _length = array_length(_keys);
        
        for (var i = 0; i < _length; ++i)
        {
            var _key = _keys[i];
            var _val = _get_val(_stats, _key);
            
            if (_val == 0) continue;
            
            var _name = loca_translate($"phantasia:statistics.{_key}");
            var _val_str = number_format_thousandths(_val);
            
            // Format distance
            if (string_pos("distance", _key) == 1)
            {
                var _blocks = _val / TILE_SIZE;
                _val_str = $"{number_format_thousandths(_blocks)} m";
            }
            
            array_push(_list, { name: _name, value: _val_str });
        }
    }
    // --- BLOCKS ---
    else if (_category == "blocks")
    {
        var _keys = struct_get_names(_stats);
        var _length = array_length(_keys);
        
        var _data = {} // id -> { placed, broken, name }
        
        for (var i = 0; i < _length; ++i)
        {
            var _key = _keys[i];
            
            if (string_pos("tiles_", _key) != 1) continue;
            if (_key == "tiles_placed") || (_key == "tiles_broken") continue; // Skip aggregates
            
            var _prefix_placed = "tiles_placed_";
            var _prefix_broken = "tiles_broken_";
            
            var _id = "";
            var _type = "";
            
            if (string_pos(_prefix_placed, _key) == 1)
            {
                _id = string_delete(_key, 1, string_length(_prefix_placed));
                _type = "placed";
            }
            else if (string_pos(_prefix_broken, _key) == 1)
            {
                _id = string_delete(_key, 1, string_length(_prefix_broken));
                _type = "broken";
            }
            else
            {
                continue;
            }
            
            if (_id == "") continue;
            
            var _val = _get_val(_stats, _key);
            if (_val == 0) continue;
            
            if (_data[$ _id] == undefined)
            {
                var _name = _id; 
                if (global.tile_data[$ _id] != undefined)
                {
                    _name = global.tile_data[$ _id].get_name();
                }
                
                _data[$ _id] = { name: _name, placed: 0, broken: 0 }
            }
            
            _data[$ _id][$ _type] = _val;
        }
        
        var _ids = struct_get_names(_data);
        var _count = array_length(_ids);
        
        for (var i = 0; i < _count; ++i)
        {
            var _d = _data[$ _ids[i]];
            var _str = "";
            if (_d.placed > 0) _str += $"{loca_translate("phantasia:statistics.placed")}: {number_format_thousandths(_d.placed)}";
            if (_d.broken > 0)
            {
                if (_str != "") _str += ", ";
                _str += $"{loca_translate("phantasia:statistics.broken")}: {number_format_thousandths(_d.broken)}";
            }
            
            array_push(_list, { name: _d.name, value: _str });
        }
    }
    // --- ITEMS ---
    else if (_category == "items")
    {
        var _keys = struct_get_names(_stats);
        var _length = array_length(_keys);
        
        var _data = {} 
        
        for (var i = 0; i < _length; ++i)
        {
            var _key = _keys[i];
            
            if (string_pos("items_", _key) != 1) continue;
            if (_key == "items_collected") || (_key == "items_used") continue;
            
            var _prefix_collected = "items_collected_";
            var _prefix_used = "items_used_";
             
            var _id = "";
            var _type = "";
            
            if (string_pos(_prefix_collected, _key) == 1)
            {
                _id = string_delete(_key, 1, string_length(_prefix_collected));
                _type = "collected";
            }
            else if (string_pos(_prefix_used, _key) == 1)
            {
                _id = string_delete(_key, 1, string_length(_prefix_used));
                _type = "used";
            }
            else
            {
                continue;
            }
            
            if (_id == "") continue;
            
            var _val = _get_val(_stats, _key);
            if (_val == 0) continue;
            
            if (_data[$ _id] == undefined)
            {
                var _name = _id;
                if (global.item_data[$ _id] != undefined)
                {
                    _name = global.item_data[$ _id].get_name();
                }
                _data[$ _id] = { name: _name, collected: 0, used: 0 }
            }
            
            _data[$ _id][$ _type] = _val;
        }
        
        var _ids = struct_get_names(_data);
        var _count = array_length(_ids);
        
        for (var i = 0; i < _count; ++i)
        {
            var _d = _data[$ _ids[i]];
            var _str = "";
            if (_d.collected > 0) _str += $"{loca_translate("phantasia:statistics.collected")}: {number_format_thousandths(_d.collected)}";
            if (_d.used > 0)
            {
                if (_str != "") _str += ", ";
                _str += $"{loca_translate("phantasia:statistics.used")}: {number_format_thousandths(_d.used)}";
            }
            
            array_push(_list, { name: _d.name, value: _str });
        }
    }
    // --- MOBS ---
    else if (_category == "mobs")
    {
        var _keys = struct_get_names(_stats);
        var _length = array_length(_keys);
        
        for (var i = 0; i < _length; ++i)
        {
            var _key = _keys[i];
            
            if (string_pos("mobs_killed_", _key) != 1) continue;
            
            var _id = string_delete(_key, 1, string_length("mobs_killed_"));
            if (_id == "") continue;
            
            var _val = _get_val(_stats, _key);
            if (_val == 0) continue;
            
            var _name = _id;
            if (global.creature_data[$ _id] != undefined)
            {
                _name = global.creature_data[$ _id].get_name();
            }
            
            array_push(_list, { name: _name, value: number_format_thousandths(_val) });
        }
    }
    
    // Sort
    array_sort(_list, function(_a, _b) {
        if (_a.name < _b.name) return -1;
        if (_a.name > _b.name) return 1;
        return 0;
    });
    
    return _list;
}
