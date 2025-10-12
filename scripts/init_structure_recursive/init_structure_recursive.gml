function init_structure_recursive(_directory, _namespace, _id)
{
    var _natural_structure_data = global.natural_structure_data;
    
    var _item_data = global.item_data;
    // var fixer = global.datafixer.item;
    
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _subdirectory = $"{_directory}/{_file}";
        
        var _name = ((_id == undefined) ? _file : $"{_id}/{_file}");
        
        if (directory_exists(_subdirectory))
        {
            init_structure_recursive(_subdirectory, _namespace, _name);
            
            continue;
        }
        
        if (string_ends_with(_subdirectory, ".json"))
        {
            if (!string_ends_with(_subdirectory, ".dat.json"))
            {
                dbg_timer("init_structure");
                
                if (_id != undefined)
                {
                    global.structure_data[$ _id] ??= [];
                    
                    array_push(global.structure_data[$ _id], _name);
                }
                
                var _json = buffer_load_json(_subdirectory);
                var _data = _json.data;
                
                var _parameter = (_natural_structure_data[$ _data[$ "function"]].get_parser())(_data[$ "parameter"]);
                
                var _width  = smart_value_parse(_json.width);
                var _height = smart_value_parse(_json.height);
                
                global.structure_data[$ $"{_namespace}:{string_delete(_name, string_length(_name) - 4, 5)}"] = new StructureData(_width, _height, _json.placement, false, true)
                    .set_parameter(_parameter)
                    .set_data(_data);
                
                delete _json;
                
                dbg_timer("init_structure", $"[Init] Loaded Natural Structure: \'{string_delete(_name, string_length(_name) - 4, 5)}\'");
            }
            
            continue;
        }
        
        if (string_ends_with(_subdirectory, ".dat"))
        {
            dbg_timer("init_structure");
            
            if (_id != undefined)
            {
                global.structure_data[$ $"{_namespace}:{_id}"] ??= [];
                
                array_push(global.structure_data[$ $"{_namespace}:{_id}"], $"{_namespace}:{string_delete(_name, string_length(_name) - 3, 4)}");
            }
            
            var _json = buffer_load_json($"{_subdirectory}.json");
            
            var _buffer = buffer_load_decompressed(_subdirectory);
            
            var _version = buffer_read(_buffer, buffer_u32);
            
            var _width  = buffer_read(_buffer, buffer_s32);
            var _height = buffer_read(_buffer, buffer_s32);
            
            var _rectangle = _width * _height;
            
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
                        var _tile = file_load_snippet_tile(_buffer, _item_data);
                        
                        if (_tile != undefined)
                        {
                            _data[@ _index_xy + (m * _rectangle)] = _tile;
                        }
                    }
                }
            }
            
            buffer_delete(_buffer);
            
            global.structure_data[$ $"{_namespace}:{string_delete(_name, string_length(_name) - 3, 4)}"] = new StructureData(_width, _height, _json.placement, false, true)
                .set_data(_data);
            
            delete _json;
            
            dbg_timer("init_structure", $"[Init] Loaded Structure: \'{string_delete(_name, string_length(_name) - 3, 4)}\'");
            
            continue;
        }
    }
}