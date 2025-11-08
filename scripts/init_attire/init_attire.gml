#macro ATTIRE_COLOUR_BASE_AMOUNT 6
#macro ATTIRE_COLOUR_OUTLINE_AMOUNT 2

#macro ATTIRE_COLOUR_AMOUNT (ATTIRE_COLOUR_BASE_AMOUNT * ATTIRE_COLOUR_OUTLINE_AMOUNT)

#macro ATTIRE_COLOUR_WHITE_INDEX 0

global.attire_data = {}
global.attire_colour_data = [];

function init_attire(_directory, _namespace = "phantasia", _type = 0)
{
    /*
    if (_type & INIT_TYPE.RESET)
    {
        static __delete = function(_data)
        {
            if (_data == undefined) exit;
            
            var _length = array_length(_data);
            
            for (var i = 0; i < _length; ++i)
            {
                sprite_delete(_data[i]);
            }
        }
        
        var _attire_data = global.attire_data;
        
        var _names = struct_get_names(_attire_data);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            var _data = _attire_data[$ _names[i]];
            
            if (_data == undefined) continue;
            
            var _icon = _data.icon;
            
            if (sprite_exists(_icon))
            {
                sprite_delete(_icon);
            }
            
            __delete(_data.colour);
            __delete(_data.white);
        }
        
        init_data_reset("attire_data");
    }
    */
    /*
    var _attire_elements = global.attire_elements;
    
    var _length = array_length(_attire_elements);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name = _attire_elements[i];
        
        if (_name == "body") continue;
        
        delete global.attire_data[$ _name];
    }
    
    static __init = function(_name, _index, _type, _directory)
    {
        static __get_index = function(_name, _index = 0)
        {
            if (_name == "pants") || (_name == "footwear")
            {
                return 8;
            }
            
            if (_name == "shirt") || (_name == "shirt_detail")
            {
                if (_index == 1)
                {
                    return 8;
                }
                
                if (_index == 2)
                {
                    return 8 + 6;
                }
            }
            
            return 1;
        }
        
        if (file_exists($"{_directory}.png"))
        {
            return sprite_add($"{_directory}.png", __get_index(_name), false, false, 16, 32);
        }
        
        if (directory_exists(_directory))
        {
            var _array = [];
            
            for (var i = 0; file_exists($"{_directory}/{i}.png"); ++i)
            {
                array_push(_array, sprite_add($"{_directory}/{i}.png", __get_index(_name, i), false, false, 16, 32));
            }
            
            return _array;
        }
    }
    
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        if (!directory_exists($"{_directory}/{_file}")) continue; 
        
        global.attire_data[$ _file] = [ undefined ];
        
        for (var j = ((directory_exists($"{_directory}/{_file}/0")) ? 0 : 1); directory_exists($"{_directory}/{_file}/{j}"); ++j)
        {
            dbg_timer("init_attire");
            
            var _directory2 = $"{_directory}/{_file}/{j}";
            
            var _data = new AttireData();
            
            if (file_exists($"{_directory2}/icon.png"))
            {
                var _icon = sprite_add($"{_directory2}/icon.png", 1, false, false, 0, 0);
                
                sprite_set_offset(_icon, round(sprite_get_xoffset(_icon) / 2), round(sprite_get_yoffset(_icon) / 2));
                
                _data.set_icon(_icon);
            }
            
            _data.set_sprite_colour(__init(_file, j, "colour", $"{_directory2}/colour"));
            _data.set_sprite_white(__init(_file, j, "white", $"{_directory2}/white"));
            
            global.attire_data[$ _file][@ j] = _data;
            
            dbg_timer("init_attire", $"Loaded Attire Type: '{_file}', Index: '{j}'");
        }
    }
    
    var _sprite = sprite_add($"{_directory}\\colour.png", 1, false, false, 0, 0);
    
    var _sprite_width  = sprite_get_width(_sprite);
    var _sprite_height = sprite_get_height(_sprite);
    
    var _surface = surface_create(_sprite_width, _sprite_height);
    var _buffer = buffer_create(_sprite_width * _sprite_height * 4, buffer_fixed, 1);
    
    surface_set_target(_surface);
    
    draw_sprite(_sprite, 0, 0, 0);
    
    surface_reset_target();
    
    buffer_get_surface(_buffer, _surface, 0);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    global.attire_colour_data = array_create(_sprite_height);
    
    for (var i = 0; i < _sprite_height; ++i)
    {
        global.attire_colour_data[@ i] = array_create(_sprite_width);
        
        for (var j = 0; j < _sprite_width; ++j)
        {
            global.attire_colour_data[@ i][@ j] = buffer_read(_buffer, buffer_u32) & 0xffffff;
        }
    }
    
    global.attire_colour_white_data = array_shift(global.attire_colour_data);
    
    sprite_delete(_sprite);
    surface_free(_surface);
    buffer_delete(_buffer);*/
}