/// @desc Logs a timestamped debug message to the console.
/// @param {String} _string The message to log.
function dbg_log(_string)
{
    gml_pragma("forceinline");
    
    if (!IS_DEVELOPER_MODE) exit;
    
    show_debug_message($"[DEBUG] :: [{string_pad_start(current_hour, "0", 2)}:{string_pad_start(current_minute, "0", 2)}:{string_pad_start(current_second, "0", 2)}] {_string}");
}
