function dbg_timer(_name, _string = undefined)
{
    static __timers = {}
    
    // if (!DEVELOPER_LOG) exit;
    
    var _timer = __timers[$ _name];
    
    if (_timer == undefined)
    {
        __timers[$ _name] = get_timer();
        
        exit;
    }
    
    dbg_log($"{_string} ({(get_timer() - _timer) / 1_000}ms)");
    
    struct_remove(__timers, _name);
}