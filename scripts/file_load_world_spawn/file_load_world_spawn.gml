function file_load_world_spawn(_current_world, _inst, _uuid = _inst.uuid)
{
    var _world_data = global.world_data[$ _current_world.dimension];
    
    var _directory = $"{PROGRAM_DIRECTORY_WORLDS}/{_current_world.uuid}/dim/{_world_data.get_namespace()}/{_world_data.get_id()}/spawn_{_uuid}.dat";
    
    if (!file_exists(_directory)) exit;
    
    var _buffer = buffer_load_decompressed(_directory);
    
    var _version = buffer_read(_buffer, buffer_u32);
    
    file_load_snippet_position(_buffer, _inst);
    
    _inst.y_last = buffer_read(_buffer, buffer_f64);
    
    buffer_delete(_buffer);
}
