global.loca_font = fnt_Default;
global.loca_data = {}

init_loca_effect(fnt_Default);

function init_loca(_directory, _namespace)
{
	if (global.loca_font != fnt_Default)
	{
		font_delete(global.loca_font);
	}
    
    var _names  = struct_get_names(global.loca_data);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        struct_remove(global.loca_data, _names[i]);
    }
    
	if (file_exists($"{_directory}\\font.ttf"))
	{
        var _data = json_parse(buffer_load_text($"{_directory}\\font.json"));
        
		global.loca_font = font_add($"{_directory}\\font.ttf", _data.size, false, false, _data.first, _data.last);
        
        font_enable_sdf(global.loca_font, true);
	}
	else if (file_exists($"{_directory}\\font.otf"))
	{
        var _data = json_parse(buffer_load_text($"{_directory}\\font.json"));
        
		global.loca_font = font_add($"{_directory}\\font.otf", _data.size, false, false, _data.first, _data.last);
        
        font_enable_sdf(global.loca_font, true);
	}
	else
	{
		global.loca_font = fnt_Default;
	}
    
    var _json = buffer_load_json($"{_directory}\\data.json");
    
    var _names2  = struct_get_names(_json);
    var _length2 = array_length(_names2);
    
    for (var i = 0; i < _length2; ++i)
    {
        var _name = _names2[i];
        
        global.loca_data[$ $"{_namespace}:{_name}"] = _json[$ _name];
    }
    
    delete _json;
    
    draw_set_font(global.loca_font);
    
    init_loca_effect();
}