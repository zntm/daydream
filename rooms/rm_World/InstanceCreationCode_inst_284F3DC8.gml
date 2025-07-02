text = loca_translate("phantasia:menu.pause.exit");

on_select_release = function()
{
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.EXIT;
    obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.PAUSE;
    
    control_instance_unpause();
    
    obj_Menu_Control_Render.xoffset = 0;
    obj_Menu_Control_Render.yoffset = 0;
    
    inst_664AF3B4.x = inst_664AF3B4.xstart;
    inst_664AF3B4.y = inst_664AF3B4.ystart;
}