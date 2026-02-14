global.menu_background_id = undefined;
global.menu_background_region = undefined;
global.menu_background_time = 0;

global.menu_background_offset = 0;

function menu_refresh_value_background()
{
    var _id = choose_weighted(global.menu_data.biomes);
    
    // Fallback to forest if biome is missing
    if (global.biome_data[$ _id] == undefined)
    {
        _id = "phantasia:surface/forest";
    }
    
    global.menu_background_id = _id;
    
    // Pick a random region for menu visuals
    var _region_ids = struct_get_names(global.region_data);
    if (array_length(_region_ids) > 0)
    {
        var _region_id = array_choose(_region_ids);
        global.menu_background_region = global.region_data[$ _region_id];
    }
    
    // Pick a random time of day for the menu
    global.menu_background_time = choose(0.2, 0.45, 0.7, 0.95);
    
    global.menu_background_offset = 0;
}