function init_structure_recursive(_namespace, _directory)
{
    var _natural_structure_data = global.natural_structure_data;
    var _item_data              = global.item_data;
    
    var _files        = file_read_directory(_directory, true);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file         = _files[i];
        var _subdirectory = $"{_directory}/{_file}";

        if (directory_exists(_subdirectory)) continue;
        
        if (string_ends_with(_file, ".json"))
        {
            if (!string_ends_with(_file, ".dat.json"))
            {
                dbg_timer("init_structure");
                
                var _id = filename_dir(_file);
                if (_id != "")
                {
                    /* flip backslash to forward slash if on windows */
                    _id = string_replace_all(_id, "\\", "/");

                    global.structure_data[$ _id] ??= [];
                    array_push(global.structure_data[$ _id], _file);
                }
                
                var _json = buffer_load_json(_subdirectory);
                
                if (is_struct(_json))
                {
                    var _function = _json[$ "function"];
                    
                    if (_function != undefined)
                    {
                        var _function_id = _function.id;
                        
                        var _width  = smart_value_parse(_json.width);
                        var _height = smart_value_parse(_json.height);
                        
                        global.structure_data[$ $"{_namespace}:{string_delete(_file, string_length(_file) - 4, 5)}"] = new StructureData(_width, _height, _json.placement, false, true)
                            .set_function(_function_id, (_natural_structure_data[$ _function_id].get_parser())(_function[$ "parameters"]))
                            .set_terrain_modifier(_json[$ "terrain_modifier"]);
                        
                        dbg_timer("init_structure", $"[Init] Loaded Natural Structure: \'{string_delete(_file, string_length(_file) - 4, 5)}\'");
                    }
                    
                    delete _json;
                }
            }
            
            continue;
        }
        
        if (string_ends_with(_file, ".dat"))
        {
            dbg_timer("init_structure");
            
            var _id = filename_dir(_file);
            if (_id != "")
            {
                /* flip backslash to forward slash if on windows */
                _id = string_replace_all(_id, "\\", "/");

                global.structure_data[$ $"{_namespace}:{_id}"] ??= [];
                array_push(global.structure_data[$ $"{_namespace}:{_id}"], $"{_namespace}:{string_delete(_file, string_length(_file) - 3, 4)}");
            }
            
            var _json = buffer_load_json($"{_subdirectory}.json");
            
            if (is_struct(_json))
            {
                var _buffer = buffer_load_decompressed(_subdirectory);
                
                var _version = buffer_read(_buffer, buffer_u32);
                
                var _width  = buffer_read(_buffer, buffer_s32);
                var _height = buffer_read(_buffer, buffer_s32);
                
                var _rectangle = _width * _height;
                
                // Read Palette
                var _palette_length = buffer_read(_buffer, buffer_u16);
                var _palette = array_create(_palette_length);
                
                for (var m = 0; m < _palette_length; ++m)
                {
                    _palette[@ m] = buffer_read(_buffer, buffer_string);
                }
                
                var _data = array_create(_rectangle * CHUNK_DEPTH, TILE_EMPTY);
                
                for (var j = 0; j < _width; ++j)
                {
                    for (var l = 0; l < _height; ++l)
                    {
                        var _index_xy = (l * _width) + j;
                        
                        if (buffer_read(_buffer, buffer_bool))
                        {
                            for (var m = 0; m < CHUNK_DEPTH; ++m)
                            {
                                _data[@ _index_xy + (m * _rectangle)] = TILE_STRUCTURE_VOID;
                            }
                            
                            continue;
                        }
                        
                        for (var m = 0; m < CHUNK_DEPTH; ++m)
                        {
                            var _tile = file_load_snippet_tile(_buffer, _item_data, _palette);
                            
                            if (_tile != undefined)
                            {
                                _data[@ _index_xy + (m * _rectangle)] = _tile;
                            }
                        }
                    }
                }
                
                buffer_delete(_buffer);
                
                global.structure_data[$ $"{_namespace}:{string_delete(_file, string_length(_file) - 3, 4)}"] = new StructureData(_width, _height, _json.placement, false, true)
                    .set_data(_data)
                    .set_terrain_modifier(_json[$ "terrain_modifier"]);
                
                delete _json;
                
                dbg_timer("init_structure", $"[Init] Loaded Structure: \'{string_delete(_file, string_length(_file) - 3, 4)}\'");
            }
            
            continue;
        }
    }
}