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
    
    var _version;
    
    if (PROGRAM_VERSION_PATCH > 0)
    {
        _version = string(loca_translate("phantasia:menu.title.version.patch"), PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR, PROGRAM_VERSION_PATCH);
    }
    else
    {
        _version = string(loca_translate("phantasia:menu.title.version"), PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR);
    }
    
    var _os_info = os_type;
    
    if (_os_info == os_windows)
    {
        _os_info = "Windows"; 
    }
    else if (_os_info == os_macosx)
    {
        _os_info = "macOS"; 
    }
    else if (_os_info == os_linux)
    {
        _os_info = "Linux"; 
    }
    else if (_os_info == os_ios)
    {
        _os_info = "iOS"; 
    }
    else if (_os_info == os_android)
    {
        _os_info = "Android"; 
    }
    else if (_os_info == os_tvos)
    {
        _os_info = "tvOS"; 
    }
    else if (_os_info == os_ps4)
    {
        _os_info = "PS4"; 
    }
    else if (_os_info == os_ps5)
    {
        _os_info = "PS5"; 
    }
    else if (_os_info == os_xboxseriesxs)
    {
        _os_info = "Xbox Series X/S";
    }
    else if (_os_info == os_switch)
    {
        _os_info = "Switch"; 
    }
    else if (_os_info == os_gdk)
    {
        _os_info = "Microsoft GDK Platform";
    }
    else if (_os_info == os_operagx)
    {
        _os_info = "Opera GX";
    }
    else
    {
        _os_info = "Unknown";
    }
    
    var _message =
        $"---[ Crash Log ]---\n" +
        $"{current_month}/{current_day}/{current_year} @ {current_hour}:{current_minute}:{current_second}\n" +
        $"It is advised to report this error to the Discord server so that it will be fixed in a future update.\n" +
        $"{SITE_DISCORD}\n\n" +
        
        $"---[ Game & System Information ]---\n" +
        $"Version: {_version}\n" +
        $"OS: {_os_info}\n" +
        $"Display: {display_get_width()}x{display_get_height()}@{display_get_frequency()}\n\n" +
        
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