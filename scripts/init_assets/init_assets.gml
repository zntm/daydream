global.sprite_asset = {}
global.sound_asset = {}

function SpriteAsset(_sprite, _xoffset, _yoffset, _width, _height, _length) constructor
{
    ___sprite = _sprite;
    ___xoffset = _xoffset;
    ___yoffset = _yoffset;
    ___width = _width;
    ___height = _height;
    ___length = _length;
    
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
    
    static get_width = function()
    {
        return ___width;
    }
    
    static get_height = function()
    {
        return ___height;
    }
    
    static get_length = function()
    {
        return ___length;
    }
}

function SoundAsset(_sound, _duration, _author = undefined, _title = undefined, _falloff_reference = undefined, _falloff_max = undefined) constructor
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
    
    static get_falloff_reference = function()
    {
        return self[$ "___falloff_reference"] ?? (TILE_SIZE * 8);
    }
    
    static get_falloff_max = function()
    {
        return self[$ "___falloff_max"] ?? (TILE_SIZE * 16);
    }
}

/// @function __strip_first_folder(_path)
/// @desc Strips the first folder from a path (e.g., "sprites/item/foo" -> "item/foo")
function __strip_first_folder(_path)
{
    var _slash_pos = string_pos("/", _path);
    if (_slash_pos > 0)
    {
        return string_delete(_path, 1, _slash_pos);
    }
    return _path;
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
                
                var _key_folder = __strip_first_folder(_folder);
                global.sound_asset[$ $"{_namespace}:{_key_folder}/{_file2}"] = _array;
            }
            else
            {
                var _key_folder = __strip_first_folder(_folder);
            	global.sound_asset[$ $"{_namespace}:{_key_folder}/{_file2}"] = new SoundAsset(audio_create_stream($"{_directory}/{string_delete(_file, string_length(_file) - 4, 5)}"), _json.duration, _json[$ "author"], _json[$ "title"]);
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
                    
                    var _full_path = $"{_directory}/{_file2}/{_sprite_file}";
                    show_debug_message($"[init_assets] Loading sprite: {_full_path} (length: {_length})");
                    
                    var _sprite = sprite_add(_full_path, _length, false, false, _xoffset, _yoffset);
                    
                    var _asset = new SpriteAsset(_sprite, _xoffset, _yoffset, sprite_get_width(_sprite), sprite_get_height(_sprite), _length);
                    
                    array_push(_array, _asset);
                }
                
                var _key_folder = __strip_first_folder(_folder);
                global.sprite_asset[$ $"{_namespace}:{_key_folder}/{_file2}"] = _array;
            }
            else
            {
                var _xoffset = _json[$ "xoffset"] ?? 0;
                var _yoffset = _json[$ "yoffset"] ?? 0;
                var _length  = _json[$ "length"]  ?? 1;
                
                var _full_path = $"{_directory}/{string_delete(_file, string_length(_file) - 4, 5)}";
                show_debug_message($"[init_assets] Loading sprite (single): {_full_path} (length: {_length})");
                
                var _sprite = sprite_add(_full_path, _length, false, false, _xoffset, _yoffset);
                
                var _asset = new SpriteAsset(_sprite, _xoffset, _yoffset, sprite_get_width(_sprite), sprite_get_height(_sprite), _length);
                
                var _key_folder = __strip_first_folder(_folder);
                global.sprite_asset[$ $"{_namespace}:{_key_folder}/{_file2}"] = _asset;
            }
            
            continue;
        }
    }
}
