/// @desc Session invite code system for easy multiplayer joining
/// Encodes IP:port into a short, shareable code

/// @desc Generate a human-friendly invite code from IP and port
/// @param {String} _ip IPv4 address (e.g., "192.168.1.100")
/// @param {Real} _port Port number (e.g., 6510)
/// @returns {String} Encoded invite code (e.g., "C0A8016419FE")
function invite_code_generate(_ip, _port)
{
    var _parts = string_split(_ip, ".");
    if (array_length(_parts) != 4)
    {
        // Fallback: just use raw IP:port format
        return $"{_ip}:{_port}";
    }
    
    // Encode IP as 4 bytes (hex)
    var _ip_hex = "";
    for (var i = 0; i < 4; ++i)
    {
        var _octet = real(_parts[i]);
        _ip_hex += _byte_to_hex(_octet);
    }
    
    // Encode port as 2 bytes (hex)
    var _port_hex = _byte_to_hex((_port >> 8) & 0xFF) + _byte_to_hex(_port & 0xFF);
    
    return _ip_hex + _port_hex;
}

/// @desc Decode invite code back to IP and port
/// @param {String} _code The invite code
/// @returns {Struct|undefined} { ip, port } or undefined if invalid
function invite_code_decode(_code)
{
    // Check for raw IP:port format
    if (string_pos(":", _code) > 0)
    {
        var _parts = string_split(_code, ":");
        if (array_length(_parts) == 2)
        {
            return {
                ip: _parts[0],
                port: real(_parts[1])
            };
        }
        return undefined;
    }
    
    // Hex encoded format (12 characters: 8 for IP + 4 for port)
    if (string_length(_code) != 12)
    {
        return undefined;
    }
    
    // Decode IP
    var _ip = "";
    for (var i = 0; i < 4; ++i)
    {
        var _hex = string_copy(_code, i * 2 + 1, 2);
        var _octet = _hex_to_byte(_hex);
        if (_octet < 0) return undefined;
        
        if (i > 0) _ip += ".";
        _ip += string(_octet);
    }
    
    // Decode port
    var _port_hex = string_copy(_code, 9, 4);
    var _port_high = _hex_to_byte(string_copy(_port_hex, 1, 2));
    var _port_low = _hex_to_byte(string_copy(_port_hex, 3, 2));
    
    if (_port_high < 0 || _port_low < 0) return undefined;
    
    var _port = (_port_high << 8) | _port_low;
    
    return {
        ip: _ip,
        port: _port
    };
}

/// @desc Convert a byte (0-255) to 2-character hex string
/// @param {Real} _byte
/// @returns {String}
function _byte_to_hex(_byte)
{
    static _hex_chars = "0123456789ABCDEF";
    
    var _high = (_byte >> 4) & 0x0F;
    var _low = _byte & 0x0F;
    
    return string_char_at(_hex_chars, _high + 1) + string_char_at(_hex_chars, _low + 1);
}

/// @desc Convert 2-character hex string to byte
/// @param {String} _hex
/// @returns {Real} Byte value (0-255) or -1 if invalid
function _hex_to_byte(_hex)
{
    static _hex_chars = "0123456789ABCDEF";
    
    if (string_length(_hex) != 2) return -1;
    
    var _high = string_pos(string_upper(string_char_at(_hex, 1)), _hex_chars) - 1;
    var _low = string_pos(string_upper(string_char_at(_hex, 2)), _hex_chars) - 1;
    
    if (_high < 0 || _low < 0) return -1;
    
    return (_high << 4) | _low;
}

/// @desc Copy the current invite code to clipboard
/// @returns {Bool} Success
function invite_code_copy()
{
    if (global.relay == undefined) return false;
    if (global.relay.room_code == "") return false;
    
    clipboard_set_text(global.relay.room_code);
    show_debug_message($"[INVITE] Code copied to clipboard: {global.relay.room_code}");
    return true;
}

/// @desc Get a user-friendly string for sharing the invite
/// @returns {String}
function invite_get_share_text()
{
    if (global.relay == undefined || global.relay.room_code == "")
    {
        return "No active session";
    }
    
    return $"Join my game! Code: {global.relay.room_code}";
}

/// @desc Get the room code for display
/// @returns {String}
function invite_get_code()
{
    if (global.relay == undefined) return "";
    return global.relay.room_code;
}

/// @desc Format invite code for display (add dashes for readability)
/// @param {String} _code Raw code
/// @returns {String} Formatted code (e.g., "C0A8-0164-19FE")
function invite_code_format(_code)
{
    if (string_length(_code) != 12) return _code;
    
    return string_copy(_code, 1, 4) + "-" + 
           string_copy(_code, 5, 4) + "-" + 
           string_copy(_code, 9, 4);
}

/// @desc Parse formatted invite code (remove dashes)
/// @param {String} _formatted Code with or without dashes
/// @returns {String} Clean code
function invite_code_parse(_formatted)
{
    return string_replace_all(_formatted, "-", "");
}
