function carbasa_repair_all()
{
    var _names  = struct_get_names(global.carbasa_surface_buffer);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        carbasa_repair_page(_names[i]);
    }
}