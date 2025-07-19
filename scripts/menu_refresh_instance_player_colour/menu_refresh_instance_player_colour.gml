function menu_refresh_instance_player_colour()
{
    static __inst = [
        inst_69E6EE12,
        inst_31A1B588,
        inst_68B12C87,
        inst_D1C664A,
        inst_639315EE,
        inst_E09754C
    ];
    
    static __on_select_release = function()
    {
        static __inst = [
            inst_69E6EE12,
            inst_31A1B588,
            inst_68B12C87,
            inst_D1C664A,
            inst_639315EE,
            inst_E09754C
        ];
        
        for (var i = 0; i < 6; ++i)
        {
            __inst[@ i].sprite_index = spr_Menu_Button_Main;
        }
        
        sprite_index = spr_Menu_Button_Secondary;
        
        global.player_save_data.attire[$ global.attire_elements[global.menu_player_attire_index]].colour = index;
    }
    
    var _name = global.attire_elements[global.menu_player_attire_index];
    
    var _attire = global.player_save_data.attire[$ _name];
    
    if (_name == "body") || (global.attire_data[$ _name][_attire.index] == undefined)
    {
        for (var i = 0; i < 6; ++i)
        {
            var _inst = __inst[i];
            
            _inst.y = -64;
        }
        
        inst_756B654D.y = -64;
        inst_340E88C5.y = -64;
        
        exit;
    }
    
    inst_756B654D.y = inst_756B654D.ystart;
    inst_340E88C5.y = inst_340E88C5.ystart;
    
    var _current_index = _attire[$ "colour"];
    
    var _attire_colour_data = global.attire_colour_data;
    var _attire_colour_data_length = array_length(_attire_colour_data);
    
    var _start_index = global.menu_player_colour_page * 6;
    
    for (var i = 0; i < 6; ++i)
    {
        var _inst = __inst[i];
        
        var _index = _start_index + i;
        
        if (_index >= _attire_colour_data_length)
        {
            _inst.y = -64;
            
            continue;
        }
        
        _inst.sprite_index = ((_index == _current_index) ? spr_Menu_Button_Secondary : spr_Menu_Button_Main);
        
        _inst.y = _inst.ystart;
        
        _inst.index = _index;
        
        _inst.icon = spr_Menu_Attire_Colour;
        
        _inst.icon_xscale = 1.5;
        _inst.icon_yscale = 1.5;
        
        _inst.on_select_release = method(_inst, __on_select_release);
    }
}