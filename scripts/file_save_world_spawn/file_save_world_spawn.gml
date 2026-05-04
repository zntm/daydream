function file_save_world_spawn(_current_world, _inst)
{
    var _world_data = global.world_data[$ _current_world.dimension];
    var _buffer     = buffer_create(0xff, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);
    
    file_save_snippet_position(_buffer, _inst);
    buffer_write(_buffer, buffer_f64, _inst.y_last);
    
    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_WORLDS}/{_current_world.uuid}/dim/{_world_data.get_namespace()}/{_world_data.get_id()}/spawn_{_inst.uuid}.dat");
    
    buffer_delete(_buffer);
}
