menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM, room_width, room_height);

text = loca_translate("phantasia:menu.multiplayer.connect");

on_select_release = function()
{
    // Find IP and Port textboxes
    var _ip_textbox = noone;
    var _port_textbox = noone;
    
    with (obj_Menu_Textbox)
    {
        if (placeholder == loca_translate("menu.multiplayer.textbox.ip"))
        {
            _ip_textbox = id;
        }
        else if (placeholder == loca_translate("menu.multiplayer.textbox.port"))
        {
            _port_textbox = id;
        }
    }
    
    if (_ip_textbox != noone && _port_textbox != noone)
    {
        var _ip = _ip_textbox.text;
        var _port = real(_port_textbox.text);
        
        show_debug_message($"[MENU] Connecting to {_ip}:{_port}...");
        network_connect_to_server(_ip, _port);
    }
    else
    {
        show_debug_message("[MENU] Could not find IP or Port textbox!");
    }
}