menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM, room_width, room_height);

text = loca_translate("phantasia:menu.create_world.title");

on_select_release = function()
{
    var _name = string_trim(inst_5F90B43E.text);
    
    if (_name == "")
    {
        var _inst_header = instance_create_layer(480, 224, "Instances", obj_Menu_Anchor);
        
        with (_inst_header)
        {
            text = loca_translate("phantasia:menu.create_world.error.empty_name");
            
            menu_layer = 1;
            
            on_draw = function(_x, _y, _xscale, _yscale)
            {
                var _x2 = x * _xscale;
                var _y2 = y * _yscale;
                
                var _halign = draw_get_halign();
                var _valign = draw_get_valign();
                
                draw_set_align(fa_center, fa_middle);
                
                render_text(_x2, _y2, text, _xscale, _yscale);
                
                draw_set_align(_halign, _valign);
            }
        }
        
        var _inst_close = instance_create_layer(480, 300, "Instances", obj_Menu_Button);
        
        with (_inst_close)
        {
            text = loca_translate("phantasia:menu.generic.close");
            
            image_xscale = 17;
            image_yscale = 3;
            
            menu_layer = 1;
            
            on_select_release = menu_popup_destroy;
        }
        
        menu_popup_create([
            _inst_header,
            _inst_close
        ]);
        
        exit;
    }
    
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