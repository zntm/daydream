global.menu_data = {}

function init_menu(_directory)
{
    var _music_data = global.music_data;
    
    var _array = buffer_load_json(_directory);
    var _length = array_length(_array);
    
    global.menu_data.music = choose_weighted_parse(_array);
}