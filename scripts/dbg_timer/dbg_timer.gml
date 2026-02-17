/// @desc Starts or stops a named timer and logs the elapsed time.
/// @param {String} _name  The timer identifier.
/// @param {String} _string The message to log alongside the elapsed time.
function dbg_timer(_name, _string = undefined)
{
    if (!IS_DEVELOPER_MODE) exit;
    
    static __timers = {}
    
    var _timer = __timers[$ _name];
    
    if (_timer == undefined)
    {
        __timers[$ _name] = get_timer();
        
        exit;
    }
    
    dbg_log($"{_string} ({(get_timer() - _timer) / 1_000}ms)");
    
    struct_remove(__timers, _name);
}
