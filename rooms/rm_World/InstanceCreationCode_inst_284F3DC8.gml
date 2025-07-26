text = loca_translate("phantasia:menu.pause.exit");

on_select_release = function()
{
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.EXIT;
    obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.PAUSE;
    
    obj_Game_Control.chunk_saved_count_max = instance_number(obj_Chunk);
    
    inst_629EFD9E.y = -1000;
    
    inst_13FA255D.y = -1000;
    
    inst_7A620B98.y = -1000;
    
    inst_284F3DC8.y = -1000;
    
    obj_Menu_Control_Render.xoffset = 0;
    obj_Menu_Control_Render.yoffset = 0;
    
    inst_664AF3B4.x = inst_664AF3B4.xstart;
    inst_664AF3B4.y = inst_664AF3B4.ystart;
}