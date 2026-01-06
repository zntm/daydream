global.biome_data = {}

// Convert JSON definitions to MaterialProvider
function __json_to_provider(_json_data)
{
    if (_json_data == undefined) return undefined;
    
    // Case 1: New MaterialProvider struct format
    if (is_struct(_json_data) && struct_exists(_json_data, "items"))
    {
        var _provider = new MaterialProvider();
        
        // Map items
        var _items = _json_data.items;
        for (var _i = 0; _i < array_length(_items); ++_i)
        {
            var _item_data = _items[_i];
            var _rules = [];
            
            // Map rules
            if (struct_exists(_item_data, "rules"))
            {
                var _json_rules = _item_data.rules;
                for (var _j = 0; _j < array_length(_json_rules); ++_j)
                {
                    var _rule_data = _json_rules[_j];
                    var _p = _rule_data[$ "params"] ?? {}
                    var _rule = undefined;
                    
                    switch (_rule_data.type)
                    {
                        case "RuleDepth": _rule = new RuleDepth(_p.min, _p.max); break;
                        case "RuleAirAbove": _rule = new RuleAirAbove(_p.min_blocks); break;
                        case "RuleCaveBiome": _rule = new RuleCaveBiome(_p.biome_id); break;
                        // Add more rules here as we implement them in datagen
                    }
                    if (_rule != undefined) array_push(_rules, _rule);
                }
            }
            
            // Add item to provider
            if (struct_exists(_item_data, "noise_min"))
            {
                 _provider.add_item_noise(_item_data.id, _item_data.noise_min, _item_data.noise_max ?? 255, _rules);
            }
            else
            {
                _provider.add_item(_item_data.id, _rules);
            }
        }
        
        // Map default ID
        if (struct_exists(_json_data, "default_id")) 
        {
            var _def = _json_data.default_id;
            if (_def == "$EMPTY") _def = TILE_EMPTY;
            _provider.set_default(_def);
        }
        
        return _provider;
    }
    
    // Case 2: Single ID (string) or simple struct with ID
    if (is_string(_json_data) || (is_struct(_json_data) && struct_exists(_json_data, "id")))
    {
        var _provider = new MaterialProvider();
        var _id = is_string(_json_data) ? _json_data : _json_data.id;
        if (_id == "$EMPTY") _id = TILE_EMPTY;
        _provider.set_default(_id);
        return _provider;
    }
    
    return undefined;
}

function init_biome_recursive(_directory, _namespace = "phantasia", _id = undefined)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _subdirectory = $"{_directory}/{_file}";
        
        var _name = ((_id == undefined) ? _file : $"{_id}/{_file}");
        
        if (directory_exists(_subdirectory))
        {
            init_biome_recursive(_subdirectory, _namespace, _name);
            continue;
        }
        
        dbg_timer("init_biome");
        
        var _json = tag_value_parse(buffer_load_json(_subdirectory));
        var _id2 = string_delete(_file, string_length(_file) - 4, 5);
        var _biome_data = new BiomeData(_namespace, _name);
        
        _biome_data.set_background(_json.background);
        _biome_data.set_map_colour(_json.map_colour);
        _biome_data.set_sky_colour(_json.sky_colour);
        _biome_data.set_light_colour(_json.light_colour);
        
        if (_json[$ "music"] != undefined) _biome_data.set_music(_json.music);
        
        // Foliage Conversion
        if (_json[$ "foliage"] != undefined)
        {
            var _f_provider = new MaterialProvider();
            var _foliage_list = _json.foliage;
            for (var _j = 0; _j < array_length(_foliage_list); ++_j)
            {
                var _f = _foliage_list[_j];
                var _f_rules = [];
                
                // Chance Rule
                if (struct_exists(_f, "chance")) array_push(_f_rules, new RuleChance(_f.chance));
                
                // Generate On Rule
                if (struct_exists(_f, "generate_on")) array_push(_f_rules, new RuleGenerateOn(_f.generate_on));
                
                // Depth Range Rules
                if (struct_exists(_f, "range_min") || struct_exists(_f, "range_max"))
                {
                    array_push(_f_rules, new RuleDepth(_f[$ "range_min"] ?? -9999, _f[$ "range_max"] ?? 9999));
                }
                
                _f_provider.add_item(_f.id, _f_rules);
            }
            _biome_data.set_tile_foliage(_f_provider);
        }
        
        var _tile = _json.tile;
        
        // Convert JSON definitions to MaterialProviders
        _biome_data.set_tile_top_layer(__json_to_provider(_tile.top_layer));
        _biome_data.set_tile_middle_layer(__json_to_provider(_tile.middle_layer));
        _biome_data.set_tile_bottom_layer(__json_to_provider(_tile.bottom_layer));
        
        _biome_data.set_creature(_json[$ "creatures"]);
        _biome_data.set_structure(_json[$ "structures"]);
        _biome_data.set_terrain_parameters(_json[$ "terrain_modifier"]);
        _biome_data.set_is_ocean(_json[$ "is_ocean"]);
        
        var _shore = _json[$ "shore_tiles"];
        if (_shore != undefined)
        {
            _biome_data.set_shore_tiles(__json_to_provider(_shore));
        }
        else
        {
            _biome_data.set_shore_tiles(undefined); 
        }
        _biome_data.set_is_skyland(_json[$ "is_skyland"]);
        
        var _name2 = string_delete(_name, string_length(_name) - 4, 5);
        global.biome_data[$ $"{_namespace}:{_name2}"] = _biome_data;
        
        delete _json;
        dbg_timer("init_biome", $"[Init] Loaded Biome: \'{_name2}\'");
    }
}
