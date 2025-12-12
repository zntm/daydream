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
        func: _func,
        args: _args
    });
}

/// @function tick_delay_process()
/// @desc Process the tick delay queue - call once per tick
function tick_delay_process()
{
    var _queue = global.tick_delay_queue;
    var _length = array_length(_queue);
    
    for (var i = _length - 1; i >= 0; --i)
    {
        var _entry = _queue[i];
        
        _entry.ticks -= 1;
        
        if (_entry.ticks <= 0)
        {
            // Execute the function with args
            var _func = _entry.func;
            var _args = _entry.args;
            var _args_length = array_length(_args);
            
            switch (_args_length)
            {
                case 0: _func(); break;
                case 1: _func(_args[0]); break;
                case 2: _func(_args[0], _args[1]); break;
                case 3: _func(_args[0], _args[1], _args[2]); break;
                case 4: _func(_args[0], _args[1], _args[2], _args[3]); break;
                case 5: _func(_args[0], _args[1], _args[2], _args[3], _args[4]); break;
                default:
                    // For more args, use method and call
                    script_execute_ext(_func, _args);
                    break;
            }
            
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
