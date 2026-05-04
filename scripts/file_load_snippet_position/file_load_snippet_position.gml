function file_load_snippet_position(_buffer, _inst)
{
    _inst.x = buffer_read(_buffer, buffer_f64);
    _inst.y = buffer_read(_buffer, buffer_f64);
    
    _inst.physics_body.vel_x = buffer_read(_buffer, buffer_f64);
    _inst.physics_body.vel_y = buffer_read(_buffer, buffer_f64);
}
