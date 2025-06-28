function menu_refresh_background()
{
    static __filter = function(_value)
    {
        return (global.biome_data[$ _value].get_type() == BIOME_TYPE.SURFACE);
    }
    
    var _biome_data = global.biome_data;
    var _id = array_choose(array_filter(struct_get_names(_biome_data), __filter));
    
    global.menu_background_id = _id;
    global.menu_background_colour = array_choose(_biome_data[$ global.menu_background_id].get_sky_colour_names());
    
    global.menu_background_offset = 0;
}