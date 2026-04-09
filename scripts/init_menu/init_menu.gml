global.menu_data = {}

function init_menu(_directory)
{
    var _array = buffer_load_json(_directory);

    if (!is_array(_array)) exit;

    global.menu_data[$ "music_entries"] ??= [];

    var _length = array_length(_array);

    for (var i = 0; i < _length; ++i)
    {
        array_push(global.menu_data.music_entries, _array[i]);
    }

    global.menu_data.music = choose_weighted_parse(global.menu_data.music_entries);
}
