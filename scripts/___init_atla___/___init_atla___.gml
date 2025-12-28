#macro ___ATLA_INIT_SIZE 256
#macro ___ATLA_MAX_SIZE  2048


// Cleanup existing surfaces and buffers before reset to prevent leaks
if (variable_global_exists("___atla_surface")) && (is_struct(global.___atla_surface))
{
    var _names = struct_get_names(global.___atla_surface);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _surface = global.___atla_surface[$ _names[i]];
        if (surface_exists(_surface)) surface_free(_surface);
    }
}

if (variable_global_exists("___atla_surface_buffer")) && (is_struct(global.___atla_surface_buffer))
{
    var _names = struct_get_names(global.___atla_surface_buffer);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _buffer = global.___atla_surface_buffer[$ _names[i]];
        if (buffer_exists(_buffer)) buffer_delete(_buffer);
    }
}

global.___atla_page = {}
global.___atla_page_position = {}

global.___atla_surface = {}
global.___atla_surface_buffer = {}
global.___atla_surface_size = {}
global.___atla_surface_texture = {}
global.___atla_surface_uvs = {}
