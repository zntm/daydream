/// @desc Chunk save queue for batched file I/O
/// Spreads chunk saves across multiple frames to prevent stuttering

global.chunk_save_queue = [];
global.chunk_save_budget_ms = 4;

/// @function chunk_save_queue_init()
/// @desc Initialize save queue
function chunk_save_queue_init()
{
    global.chunk_save_queue = [];
}

/// @function chunk_save_queue_add(_inst)
/// @desc Add chunk to save queue
/// @param {Id.Instance} _inst Chunk instance
function chunk_save_queue_add(_inst)
{
    if (!instance_exists(_inst)) exit;
    
    // Check if already queued
    var _queue = global.chunk_save_queue;
    var _length = array_length(_queue);
    
    for (var i = 0; i < _length; ++i)
    {
        if (_queue[i] == _inst) exit; // Already queued
    }
    
    array_push(_queue, _inst);
}

/// @function chunk_save_queue_process()
/// @desc Process queued saves within time budget
function chunk_save_queue_process()
{
    var _queue = global.chunk_save_queue;
    
    if (array_length(_queue) == 0) exit;
    
    var _start = get_timer();
    var _budget_us = global.chunk_save_budget_ms * 1000;
    var _world_save_data = global.world_save_data;
    
    while (array_length(_queue) > 0)
    {
        // Check time budget
        if ((get_timer() - _start) > _budget_us) break;
        
        var _inst = _queue[0];
        array_delete(_queue, 0, 1);
        
        if (instance_exists(_inst))
        {
            file_save_world_chunk(_world_save_data, _inst);
        }
    }
}

/// @function chunk_save_queue_flush()
/// @desc Immediately save all queued chunks (for game exit)
function chunk_save_queue_flush()
{
    var _queue = global.chunk_save_queue;
    var _world_save_data = global.world_save_data;
    
    while (array_length(_queue) > 0)
    {
        var _inst = _queue[0];
        array_delete(_queue, 0, 1);
        
        if (instance_exists(_inst))
        {
            file_save_world_chunk(_world_save_data, _inst);
        }
    }
}

/// @function chunk_save_queue_clear()
/// @desc Clear save queue without saving
function chunk_save_queue_clear()
{
    global.chunk_save_queue = [];
}

/// @function chunk_save_queue_get_size()
/// @returns {real} Number of chunks queued for saving
function chunk_save_queue_get_size()
{
    return array_length(global.chunk_save_queue);
}
