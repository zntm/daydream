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
        global.player_save_data[$ global.attire_elements[global.menu_player_attire_index]].colour = index;
    }
    
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
        
        _inst.y = _inst.ystart;
        
        _inst.index = _index;
        
        _inst.icon = spr_Menu_Attire_Colour;
        
        _inst.icon_xscale = 1.5;
        _inst.icon_yscale = 1.5;
        
        _inst.on_select_release = method(_inst, __on_select_release);
    }
}