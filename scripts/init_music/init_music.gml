global.music_data = {}

function init_music(_directory, _namespace = "phantasia", _type = 0)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        dbg_timer("init_data_biome_surface");
        
        var _name = $"{_namespace}:{_file}";
        
        var _audio = audio_create_stream($"{_directory}/{_file}/audio.ogg");
        var _json = buffer_load_json($"{_directory}/{_file}/data.json");
        
        global.music_data[$ _name] = new MusicData(_audio, _json.title, _json.author, _json.length);
        
        delete _json;
        
        dbg_timer("init_data_biome_surface", $"[Init] Loaded Music: \'{_file}\'");
    }
}