function control_player(_dt)
{
    control_physics_input(_dt, id);
    control_physics_creative(_dt, id);
    control_physics_input_after(_dt, id);
    
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false, _dt);
}