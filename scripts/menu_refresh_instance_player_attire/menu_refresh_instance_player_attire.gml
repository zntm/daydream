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
    
    var _attire_data = global.attire_data[$ global.attire_elements[global.menu_player_attire_index]];
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
        
        _inst.y = _inst.ystart;
        
        var _data = _attire_data[_index];
        
        _inst.icon = ((_data != undefined) ? _data.get_icon() : spr_Icon_Prohibited);
    }
}