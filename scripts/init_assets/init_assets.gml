global.sprite_asset = {}
global.sound_asset = {}

function SpriteAsset(_sprite, _xoffset, _yoffset, _length) constructor
{
    ___sprite = _sprite;
    ___xoffset = _xoffset;
    ___yoffset = _xoffset;
    ___length = _xoffset;
    
    static get_sprite = function()
    {
        return ___sprite;
    }
    
    static get_xoffset = function()
    {
        return ___xoffset;
    }
    
    static get_yoffset = function()
    {
        return ___yoffset;
    }
    
    static get_length = function()
    {
        return ___length;
    }
    
    static set_is_tile = function()
    {
        ___is_tile = true;
        
        return self;
    }
    
    static is_tile = function()
    {
        return self[$ "___is_tile"] ?? false;
    }
}

function SoundAsset(_sound, _duration, _author = undefined, _title = undefined) constructor
{
    ___sound = _sound;
    ___duration = _duration;
    
    if (_author != undefined)
    {
        ___author = _author;
    }
    
    if (_title != undefined)
    {
        ___title = _title;
    }
    
    static get_sound = function()
    {
        return self[$ "___sound"];
    }
    
    static get_duration = function()
    {
        return self[$ "___duration"];
    }
    
    static get_author = function()
    {
        return self[$ "___author"];
    }
    
    static get_title = function()
    {
        return self[$ "___title"];
    }
}

function init_assets(_directory, _namespace, _folder = "")
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _id = (_folder != "") ? $"{_folder}/{_file}" : _file;
        
        if (directory_exists($"{_directory}/{_file}"))
        {
            init_assets($"{_directory}/{_file}", _namespace, _id);
            
            continue;
        }
        
        if (string_ends_with(_file, ".ogg.json"))
        {
            var _json = buffer_load_json($"{_directory}/{_file}");
            var _file2 = string_delete(_file, string_length(_file) - 8, 9);
            
            if (directory_exists($"{_directory}/{_file2}"))
            {
                var _array = [];
                
                var _sound_files = file_read_directory($"{_directory}/{_file2}");
                var _sound_files_length = array_length(_sound_files);
                
                for (var j = 0; j < _sound_files_length; ++j)
                {
                    var _sound_file = _sound_files[j];
                    var _data = _json[j];
                    
                    var _asset = new SoundAsset(audio_create_stream($"{_directory}/{_file2}/{_sound_file}"), _data.duration, _data[$ "author"], _data[$ "title"]);
                    
                    array_push(_array, _asset);
                }
                
                global.sound_asset[$ $"{_namespace}:{_folder}/{_file2}"] = _array;
            }
            else
            {
            	global.sound_asset[$ $"{_namespace}:{_folder}/{_file2}"] = new SoundAsset(audio_create_stream($"{_directory}/{string_delete(_file, string_length(_file) - 4, 5)}"), _json.duration, _json[$ "author"], _json[$ "title"]);
            }
            
            continue;
        }
        
        if (string_ends_with(_file, ".png.json"))
        {
            var _json = buffer_load_json($"{_directory}/{_file}");
            var _file2 = string_delete(_file, string_length(_file) - 8, 9);
            
            if (directory_exists($"{_directory}/{_file2}"))
            {
                var _array = [];
                
                var _sprite_files = file_read_directory($"{_directory}/{_file2}");
                var _sprite_files_length = array_length(_sprite_files);
                
                for (var j = 0; j < _sprite_files_length; ++j)
                {
                    var _sprite_file = _sprite_files[j];
                    var _data = _json[j];
                    
                    var _xoffset = _data[$ "xoffset"] ?? 0;
                    var _yoffset = _data[$ "yoffset"] ?? 0;
                    var _length  = _data[$ "length"]  ?? 1;
                    
                    var _sprite = sprite_add($"{_directory}/{_file2}/{_sprite_file}", _length, false, false, _xoffset, _yoffset);
                    
                    var _asset = new SpriteAsset(_sprite, _xoffset, _yoffset, _length);
                    
                    if (_data[$ "is_tile"])
                    {
                        _asset.set_is_tile();
                    }
                    
                    array_push(_array, _asset);
                }
                
                global.sprite_asset[$ $"{_namespace}:{_folder}/{_file2}"] = _array;
            }
            else
            {
                var _xoffset = _json[$ "xoffset"] ?? 0;
                var _yoffset = _json[$ "yoffset"] ?? 0;
                var _length  = _json[$ "length"]  ?? 1;
                
                var _sprite = sprite_add($"{_directory}/{string_delete(_file, string_length(_file) - 4, 5)}", _length, false, false, _xoffset, _yoffset);
                
                var _asset = new SpriteAsset(_sprite, _xoffset, _yoffset, _length);
                
                if (_json[$ "is_tile"])
                {
                    _asset.set_is_tile();
                }
                
                global.sprite_asset[$ $"{_namespace}:{_folder}/{_file2}"] = _asset;
            }
            
            continue;
        }
    }
}
