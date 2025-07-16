function control_player(_dt)
{
    audio_listener_position(x, y, 0);
    
    control_physics_input(_dt, id);
    
    if (xvelocity != 0) || (yvelocity != 0)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
    
    control_physics_creative(_dt, id);
    
    control_entity_sfx(_dt);
    
    control_physics_input_after(_dt, id);
    
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false, _dt);
}