function file_load_world_spawn(_world_save_data, _inst, _uuid = _inst.uuid)
{
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _directory = $"{PROGRAM_DIRECTORY_WORLDS}/{_world_save_data.uuid}/dimension/{_world_data.get_namespace()}/{_world_data.get_id()}/spawn/{_uuid}.dat";
    
    if (!file_exists(_directory)) exit;
    
    var _buffer = buffer_load_decompressed(_directory);
    
    var _version_major = buffer_read(_buffer, buffer_u16);
    var _version_minor = buffer_read(_buffer, buffer_u16);
    var _version_patch = buffer_read(_buffer, buffer_u16);
    var _version_type = buffer_read(_buffer, buffer_u16);
    
    file_load_snippet_position(_buffer, _inst);
    
    buffer_delete(_buffer);
}