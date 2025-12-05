exception_unhandled_handler(function(_exception)
{
    var _buffer = buffer_create(0xffff, buffer_fixed, 1);
    
    var _secret = choose(
        "A massive blunder?!",
        "Another one...",
        "Au Revoir!",
        "At least it compiled.",
        "boo",
        "Brokenhearted.",
        "But it works on my machine?",
        "Close your eyes and pretend this doesn't exist.",
        "cool",
        "Did you enjoy it?",
        "Error? I prefer 'opportunities.'",
        "Everything is working exactly as unplanned.",
        "F",
        "Forget it!",
        "Give Me Orange Give Orange Me Give Eat Orange Me Eat Orange Give Me Eat Orange Give Me You.",
        "Gone fishin' Please hold.",
        "guh",
        "Here's a bunch of fancy words above that I know the meaning of, I think.",
        "Huh?!",
        "I don't know what you're talking about. This game doesn't have any mistkaes.",
        "Is this a witty comment?",
        "It's not my fault the game is broken. I'm just the only programmer!",
        "I'm just as surprised as you are.",
        "I'm not sure what happened, but it wasn't supposed to do that.",
        "Look, I was tired, okay?",
        "My bad.",
        "My fault.",
        "Nisa was here.",
        "Nisa wasn't here.",
        "No, I do not want a banana.",
        "Oops...",
        "Oops, this error message also encountered an error.",
        "Pretend I'm not here.",
        "Quantum instability detected.",
        "Rate this error message from 1 to 10.",
        "Surprisingly easy to fix, probably.",
        "Stop thinking about the crash... Think about the love.",
        "There is no such thing as a coincidence.",
        "This crash was intentional. I hope.",
        "uhh",
        "very cool",
        "Wait you're not supposed to be here?",
        "Well this is awkward...",
        "Well, *someone* wrote this code.",
        "Whoopsie!",
        "Would you like an apple pie with that?",
        "Yeah, don't do that.",
        "You were doing it wrong.",
        "Zhen didn't see this coming."
    );
    
    var _long_message = _exception.longMessage;
    var _stack_trace = string_join_ext("\n", _exception.stacktrace);
    
    var _os_type = os_type;
    
    if (_os_type == os_windows)
    {
        _os_type = "Windows"; 
    }
    else if (_os_type == os_macosx)
    {
        _os_type = "macOS"; 
    }
    else if (_os_type == os_linux)
    {
        _os_type = "Linux"; 
    }
    else if (_os_type == os_ios)
    {
        _os_type = "iOS"; 
    }
    else if (_os_type == os_android)
    {
        _os_type = "Android"; 
    }
    else if (_os_type == os_tvos)
    {
        _os_type = "tvOS"; 
    }
    else if (_os_type == os_ps4)
    {
        _os_type = "PS4"; 
    }
    else if (_os_type == os_ps5)
    {
        _os_type = "PS5"; 
    }
    else if (_os_type == os_xboxseriesxs)
    {
        _os_type = "Xbox Series X/S";
    }
    else if (_os_type == os_switch)
    {
        _os_type = "Switch"; 
    }
    else if (_os_type == os_gdk)
    {
        _os_type = "Microsoft GDK Platform";
    }
    else if (_os_type == os_operagx)
    {
        _os_type = "Opera GX";
    }
    else
    {
        _os_type = "Unknown";
    }
    
    var _message =
        $"---[ Crash Log ]---\n" +
        $"{current_month}/{current_day}/{current_year} @ {current_hour}:{current_minute}:{current_second}\n" +
        $"It is advised to report this error to the Discord server so that it will be fixed in a future update.\n" +
        $"{SITE_DISCORD}\n\n" +
        
        $"---[ Game & System Information ]---\n" +
        $"Version: {program_get_version()}\n" +
        $"OS: {_os_type}\n" +
        $"OS Version: {os_version}\n" +
        $"Display: {display_get_width()}x{display_get_height()}@{display_get_frequency()}\n" +
        $"Is Network Connected: {os_is_network_connected()}\n\n" +
        
        $"---[ Error Message ]---\n" +
        $"{_long_message}\n\n" +
        
        $"---[ Stack Trace ]---\n" +
        $"{_stack_trace}";
    
    
    buffer_write(
        _buffer,
        buffer_text,
        $"{_secret}\n" +
        $"{string_repeat("-", 24)}\n" +
        _message
    );
    
    buffer_save(_buffer, $"{PROGRAM_DIRECTORY_CRASH_LOG}/{_exception.script} (Line {_exception.line}).txt");
    
    buffer_delete(_buffer);
    
    show_debug_message(_message);
    show_message(_message);
});