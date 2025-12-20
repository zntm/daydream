// Free surface_inventory surfaces
var _names = struct_get_names(surface_inventory);
var _length = array_length(_names);

for (var i = 0; i < _length; ++i)
{
    var _struct = surface_inventory[$ _names[i]];
    
    if (variable_struct_exists(_struct, "surface"))
    {
        if (surface_exists(_struct.surface)) surface_free(_struct.surface);
    }
    
    if (variable_struct_exists(_struct, "surface_item"))
    {
        if (surface_exists(_struct.surface_item)) surface_free(_struct.surface_item);
    }
    
    if (variable_struct_exists(_struct, "surface_slot"))
    {
        if (surface_exists(_struct.surface_slot)) surface_free(_struct.surface_slot);
    }
}

// Free other surfaces
if (surface_exists(surface_lighting)) surface_free(surface_lighting);
if (surface_exists(surface_hp)) surface_free(surface_hp);
if (surface_exists(surface_harvest)) surface_free(surface_harvest);

if (is_array(surface_pause))
{
    for (var i = 0; i < array_length(surface_pause); ++i)
    {
        if (surface_exists(surface_pause[i])) surface_free(surface_pause[i]);
    }
}
