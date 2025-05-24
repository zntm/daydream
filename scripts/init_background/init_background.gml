global.background_data = {}

function init_background(_directory, _namespace = "phantasia", _type = 0)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        dbg_timer("init_background");
        
        var _file = _files[i];
        
        var _json = buffer_load_json($"{_directory}/{_file}/data.json");
        
        var _layers = _json.layers;
        
        var _background = file_read_directory($"{_directory}/{_file}/sprite");
        var _background_length = array_length(_background);
        
        var _background_data = new BackgroundData(_json.type);
        
        _background_data.set_blend(_json.blend);
        
        for (var j = 0; j < _background_length; ++j)
        {
            var _layer = _layers[j];
            
            var _sprite = sprite_add($"{_directory}/{_file}/sprite/{_background[j]}", 1, false, false, 0, 0);
            
            sprite_set_offset(_sprite, _layer.xoffset, _layer.yoffset);
            
            _background_data.add_sprite(_sprite, _layer.width, _layer.height);
        }
        
        global.background_data[$ $"{_namespace}:{_file}"] = _background_data;
        
        delete _json;
        
        dbg_timer("init_background", $"[Init] Loaded Background: \'{_file}\' ({_background_length})");
    }
}