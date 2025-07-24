function dbg_log(_string)
{
    gml_pragma("forceinline");
    
    // if (!DEVELOPER_LOG) exit;
    
    show_debug_message($"[DEBUG] :: [{string_pad_start(current_hour, "0", 2)}:{string_pad_start(current_minute, "0", 2)}:{string_pad_start(current_second, "0", 2)}] {_string}");
}