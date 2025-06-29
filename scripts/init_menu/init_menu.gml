global.menu_data = {}

function init_menu(_directory)
{
    var _music_data = global.music_data;
    
    var _json = buffer_load_json(_directory);
    
    var _music = _json.music;
    var _music_length = array_length(_music);
    
    global.menu_data.music = choose_weighted_parse(_music);
    global.menu_data.music_audio = [];
    
    for (var i = 0; i < _music_length; ++i)
    {
        var _id = _music[i].id;
        
        array_push(global.menu_data.music_audio, _music_data[$ _id].get_audio());
    }
    
    delete _json;
}