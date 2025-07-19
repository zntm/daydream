function menu_refresh_instance_player_attire()
{
    static __inst = [
        inst_3A828A0C,
        inst_797ECDFE,
        inst_2E54B2A7,
        inst_33DF38CC,
        inst_62096C9C,
        inst_165E7BCC
    ];
    
    static __on_select_release = function()
    {
        static __inst = [
            inst_3A828A0C,
            inst_797ECDFE,
            inst_2E54B2A7,
            inst_33DF38CC,
            inst_62096C9C,
            inst_165E7BCC
        ];
        
        for (var i = 0; i < 6; ++i)
        {
            __inst[@ i].sprite_index = spr_Menu_Button_Main;
        }
        
        sprite_index = spr_Menu_Button_Secondary;
        
        global.player_save_data.attire[$ global.attire_elements[global.menu_player_attire_index]].index = index;
        
        menu_refresh_instance_player_colour();
    }
    
    var _name = global.attire_elements[global.menu_player_attire_index];
    
    var _attire_data = global.attire_data[$ _name];
    var _attire_data_length = array_length(_attire_data);
    
    if (_attire_data_length <= 6)
    {
        inst_548C85BE.y = -64;
        inst_5F2060E.y = -64;
    }
    else
    {
        inst_548C85BE.y = inst_548C85BE.ystart;
        inst_5F2060E.y = inst_5F2060E.ystart;
    }
    
    var _current_index = global.player_save_data.attire[$ _name][$ "index"];
    
    var _start_index = global.menu_player_attire_page * 6;
    
    for (var i = 0; i < 6; ++i)
    {
        var _inst = __inst[i];
        
        var _index = _start_index + i;
        
        if (_index >= _attire_data_length)
        {
            _inst.y = -64;
            
            continue;
        }
        
        _inst.sprite_index = ((_index == _current_index) ? spr_Menu_Button_Secondary : spr_Menu_Button_Main);
        
        _inst.y = _inst.ystart;
        
        _inst.index = _index;
        
        var _data = _attire_data[_index];
        
        _inst.icon = ((_data != undefined) ? _data.get_icon() : spr_Icon_Prohibited);
        
        _inst.icon_xscale = 1.5;
        _inst.icon_yscale = 1.5;
        
        _inst.on_select_release = method(_inst, __on_select_release);
    }
}