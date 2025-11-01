function atla_get_data(_page, _name, _index)
{
    var _atla_page = global.atla_page[$ _page];
    
    if (_atla_page == undefined)
    {
        show_debug_message($"[ATLA] Page '{_page}' does not exist!");
        
        exit;
    }
    
    var _data = _atla_page[$ _name];
    
    if (_data == undefined)
    {
        show_debug_message($"[ATLA] Sprite '{_page}' does not exist!");
        
        exit;
    }
    
    return global.___atla_page_position[$ _page][_data.get_sprite_index(_index)];
}