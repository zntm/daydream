function init_menu_biomes(_directory)
{
    var _array = buffer_load_json(_directory);

    if (!is_array(_array)) exit;

    global.menu_data[$ "biome_entries"] ??= [];

    var _length = array_length(_array);

    for (var i = 0; i < _length; ++i)
    {
        array_push(global.menu_data.biome_entries, _array[i]);
    }

    global.menu_data.biomes = choose_weighted_parse(global.menu_data.biome_entries);
}
