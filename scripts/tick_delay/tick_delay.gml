/// @desc Tick delay system for scheduling function execution after N ticks

global.tick_delay_queue = [];

/// @function tick_delay_add(_ticks, _func, _args)
/// @desc Schedule a function to execute after a number of ticks
/// @param {real} _ticks Number of ticks to wait
/// @param {function} _func Function to execute
/// @param {array} _args Optional array of arguments to pass
function tick_delay_add(_ticks, _func, _args = [])
{
    array_push(global.tick_delay_queue, {
        ticks: _ticks,
        "function": _func,
        args: _args
    });
}

/// @function tick_delay_process()
/// @desc Process the tick delay queue - call once per tick
function tick_delay_process()
{
    var _queue = global.tick_delay_queue;
    
    for (var i = array_length(_queue) - 1; i >= 0; --i)
    {
        var _entry = _queue[i];
        
        _entry.ticks -= 1;
        
        if (_entry.ticks <= 0)
        {
            script_execute_ext(_entry[$ "function"], _entry.args);

            array_delete(_queue, i, 1);
        }
    }
}

/// @function tick_delay_clear()
/// @desc Clear all pending delayed executions
function tick_delay_clear()
{
    global.tick_delay_queue = [];
}

/// @function tick_delay_count()
/// @desc Get the number of pending delayed executions
/// @returns {real} Number of pending delays
function tick_delay_count()
{
    return array_length(global.tick_delay_queue);
}
