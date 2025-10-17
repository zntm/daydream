function file_save_world_spawn(_world_save_data, _inst)
{
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _buffer = buffer_create(0xff, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);
    
    file_save_snippet_position(_buffer, _inst);
    
    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_WORLDS}/{_world_save_data.uuid}/dim/{_world_data.get_namespace()}/{_world_data.get_id()}/spawn_{_inst.uuid}.dat");
    
    buffer_delete(_buffer);
}