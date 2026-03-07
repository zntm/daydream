var _names = struct_get_names(surface_inventory);

for (var i = array_length(_names) - 1; i >= 0; --i)
{
    var _struct = surface_inventory[$ _names[i]];

    if (struct_exists(_struct, "surface"))      && (surface_exists(_struct.surface))      surface_free(_struct.surface);
    if (struct_exists(_struct, "surface_item")) && (surface_exists(_struct.surface_item)) surface_free(_struct.surface_item);
    if (struct_exists(_struct, "surface_slot")) && (surface_exists(_struct.surface_slot)) surface_free(_struct.surface_slot);
}

if (surface_exists(surface_lighting)) surface_free(surface_lighting);
if (surface_exists(surface_hp))       surface_free(surface_hp);
if (surface_exists(surface_harvest))  surface_free(surface_harvest);

if (is_array(surface_pause))
{
    for (var i = array_length(surface_pause) - 1; i >= 0; --i)
    {
        if (surface_exists(surface_pause[i])) surface_free(surface_pause[i]);
    }
}

debug_cleanup();
