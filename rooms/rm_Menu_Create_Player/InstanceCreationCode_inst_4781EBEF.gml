menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM, room_width, room_height);

text = loca_translate("phantasia:menu.create_player.title");

on_select_release = function()
{
    var _name = inst_72277DAD.text;
    
    if (_name == "")
    {
        var _inst_header = instance_create_layer(480, 224, "Instances", obj_Menu_Anchor);
        
        with (_inst_header)
        {
            text = loca_translate("phantasia:menu.create_player.error.empty_name");
            
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
    
    var _uuid = "";
    var _index = datetime_to_unix();
    
    do 
    {
        _uuid = uuid_generate(_index++);
    }
    until (!directory_exists($"{PROGRAM_DIRECTORY_PLAYERS}/{_uuid}"));
    
    var _attire = global.player_save_data.attire;
    
    file_save_player_global($"{PROGRAM_DIRECTORY_PLAYERS}/{_uuid}", _name, _attire, 100, 100, 0, {});
    
    array_insert(global.file_players, 0, new FilePlayer(_uuid, _name, date_current_datetime())
        .set_version(PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR, PROGRAM_VERSION_PATCH, PROGRAM_VERSION_TYPE)
        .set_attire(_attire)
        .set_hp(100, 100)
        .set_effects({}));
    
    array_insert(global.file_players_uuid, 0, _uuid);
    
    room_goto(rm_Menu_Players);
}