var _biome_data = global.biome_data;

biome_id = array_choose(array_filter(struct_get_names(_biome_data), function(_value)
{
    return (global.biome_data[$ _value].get_type() == BIOME_TYPE.SURFACE);
}));

colour = array_choose(_biome_data[$ biome_id].get_sky_colour_names());

offset = 0;