global.sprite_asset = {};
global.sound_asset  = {};

function SpriteAsset(_path, _xoffset, _yoffset, _length) constructor
{
    ___xoffset = _xoffset;
    ___yoffset = _yoffset;
    ___length  = _length;
    ___sprite  = sprite_add(_path, _length, false, false, _xoffset, _yoffset);
    ___width   = sprite_get_width(___sprite);
    ___height  = sprite_get_height(___sprite);
    
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

function SoundAsset(_path, _duration, _author = undefined, _title = undefined, _falloff_ref = undefined, _falloff_max = undefined) constructor
{
    ___sound             = audio_create_stream(_path);
    ___duration          = _duration;
    ___author            = _author;
    ___title             = _title;
    ___falloff_reference = _falloff_ref;
    ___falloff_max       = _falloff_max;
    
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

/// @desc Loads all assets from a directory into the global asset tables.
/// @param {String} _namespace The namespace to register assets under.
/// @param {String} _directory The directory to load assets from.
function init_assets(_namespace, _directory)
{
    var _files = file_read_directory(_directory, true);
    
    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        var _file = _files[i];
        
        if (string_ends_with(_file, ".ogg.json"))
        {
            var _json = buffer_load_json($"{_directory}/{_file}");
            /* magic numbers are from string length of '.ogg.json' */
            var _id = string_delete(_file, string_length(_file) - 8, 9);
            
            if (!directory_exists($"{_directory}/{_id}"))
            {
                global.sound_asset[$ $"{_namespace}:{_id}"] = new SoundAsset(
                    /* magic numbers are from string length of '.json' */
                    $"{_directory}/{string_delete(_file, string_length(_file) - 4, 5)}",
                    _json.duration,
                    _json[$ "author"],
                    _json[$ "title"]
                );
                
                continue;
            }
            
            var _array = [];
            var _subfiles = file_read_directory($"{_directory}/{_id}");
            
            for (var j = array_length(_subfiles) - 1; j >= 0; --j)
            {
                var _data = _json[j];
                
                _array[@ j] = new SoundAsset(
                    $"{_directory}/{_id}/{_subfiles[j]}",
                    _data.duration,
                    _data[$ "author"],
                    _data[$ "title"]
                );
            }
            
            global.sound_asset[$ $"{_namespace}:{_id}"] = _array;
        }
        else if (string_ends_with(_file, ".png.json"))
        {
            var _json = buffer_load_json($"{_directory}/{_file}");
            /* magic numbers are from string length of '.png.json' */
            var _id = string_delete(_file, string_length(_file) - 8, 9);
            
            if (!directory_exists($"{_directory}/{_id}"))
            {
                global.sprite_asset[$ $"{_namespace}:{_id}"] = new SpriteAsset(
                    /* magic numbers are from string length of '.json' */
                    $"{_directory}/{string_delete(_file, string_length(_file) - 4, 5)}",
                    _json[$ "xoffset"] ?? 0,
                    _json[$ "yoffset"] ?? 0,
                    _json[$ "length"]  ?? 1
                );
                
                continue;
            }
            
            var _array = [];
            var _subfiles = file_read_directory($"{_directory}/{_id}");
            
            for (var j = array_length(_subfiles) - 1; j >= 0; --j)
            {
                var _data = _json[j];
                
                _array[@ j] = new SpriteAsset(
                    $"{_directory}/{_id}/{_subfiles[j]}",
                    _data[$ "xoffset"] ?? 0,
                    _data[$ "yoffset"] ?? 0,
                    _data[$ "length"]  ?? 1
                );
            }
            
            global.sprite_asset[$ $"{_namespace}:{_id}"] = _array;
        }
    }
}
