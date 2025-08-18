menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM, room_width, room_height);

text = loca_translate("phantasia:menu.create_world.title");

on_select_release = function()
{
    var _name = string_trim(inst_5F90B43E.text);
    
    if (_name == "") exit;
    
    var _seed = inst_8ABD565.text;
    
    if (!string_contains(_seed, "."))
    {
        if (string_starts_with(_seed, "-"))
        {
            if ($"-{string_digits(_seed)}" == _seed)
            {
                _seed = real(_seed);
            }
        }
        else
        {
            if (string_digits(_seed) == _seed)
            {
                _seed = real(_seed);
            }
        }
    }
    
    if (is_string(_seed))
    {
        _seed = string_get_seed(_seed);
    }
    
    global.world_save_data.name = _name;
    global.world_save_data.seed = _seed;
    
    randomize();
    
    var _uuid = "";
    var _index = datetime_to_unix();
    
    do
    {
        _uuid = uuid_generate(_index++);
    }
    until (!directory_exists($"{PROGRAM_DIRECTORY_WORLDS}/{_uuid}"));
    
    global.world_save_data.uuid = _uuid;
    
    room_goto(rm_World);
}