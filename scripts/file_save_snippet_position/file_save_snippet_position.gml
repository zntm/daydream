function file_save_snippet_position(_buffer, _inst)
{
    buffer_write(_buffer, buffer_f64, _inst.x);
    buffer_write(_buffer, buffer_f64, _inst.y);
    
    buffer_write(_buffer, buffer_f64, _inst.xvelocity);
    buffer_write(_buffer, buffer_f64, _inst.yvelocity);
}