global.menu_background_id = undefined;
global.menu_background_colour = c_black;

global.menu_background_offset = 0;

function menu_refresh_value_background()
{
    var _id = choose_weighted(global.menu_data.biomes);
    var _biome = global.biome_data[$ _id];
    
    // Fallback to forest if biome is missing
    if (_biome == undefined)
    {
        _id = "phantasia:surface/forest";
        _biome = global.biome_data[$ _id];
    }
    
    global.menu_background_id = _id;
    
    // Use a random time on the biome's sky color gradient (0.0 - 1.0)
    if (_biome != undefined)
    {
        global.menu_background_colour = random(1.0);
    }
    else
    {
        global.menu_background_colour = 0.0;
    }
    
    global.menu_background_offset = 0;
}