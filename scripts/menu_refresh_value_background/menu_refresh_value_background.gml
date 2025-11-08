global.menu_background_id = undefined;
global.menu_background_colour = c_black;

global.menu_background_offset = 0;

function menu_refresh_value_background()
{
    var _id = choose_weighted(global.menu_data.biomes);
    
    global.menu_background_id = _id;
    global.menu_background_colour = array_choose(global.biome_data[$ _id].get_sky_colour_names());
    
    global.menu_background_offset = 0;
}