text = loca_translate("phantasia:menu.pause.exit");

on_select_release = function()
{
    obj_Game_Control.is_opened |= WORLD_OPENED_BOOL.EXIT;
    obj_Game_Control.is_opened ^= WORLD_OPENED_BOOL.PAUSE;
    
    obj_Game_Control.chunk_saved_count_max = chunk_map_count();
    
    with (obj_Menu_Anchor)
    {
        y = -1000;
    }
    
    with (obj_Menu_Button)
    {
        y = -1000;
    }
    
    with (obj_Menu_Dropdown)
    {
        y = -1000;
    }
    
    with (obj_Menu_Textbox)
    {
        y = -1000;
    }
    
    obj_Menu_Control_Render.xoffset = 0;
    obj_Menu_Control_Render.yoffset = 0;
    
    inst_664AF3B4.x = inst_664AF3B4.xstart;
    inst_664AF3B4.y = inst_664AF3B4.ystart;
}