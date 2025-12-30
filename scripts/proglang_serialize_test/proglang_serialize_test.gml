/// @desc Test proglang serialization
function proglang_serialize_test() {
    var _source = "fn add(a, b) { return a + b; } var x = add(10, 20);";
    var _bytecode = proglang_compile(_source);
    
    if (_bytecode == undefined) {
        show_debug_message("[ProgSerializeTest] FAILED: Compilation failed.");
        return false;
    }
    
    var _buffer = proglang_serialize(_bytecode);
    
    if (_buffer == undefined) {
        show_debug_message("[ProgSerializeTest] FAILED: Serialization returned undefined.");
        return false;
    }
    
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _magic = buffer_read(_buffer, buffer_string);
    var _version = buffer_read(_buffer, buffer_u32);
    var _cp_count = buffer_read(_buffer, buffer_u32);
    var _bc_len = buffer_read(_buffer, buffer_u32);
    
    show_debug_message(
        $"[ProgSerializeTest] Magic: {_magic}\n" +
        $"[ProgSerializeTest] Version: {_version}\n" +
        $"[ProgSerializeTest] Constant Pool Count: {_cp_count}\n" +
        $"[ProgSerializeTest] Bytecode Length: {_bc_len} bytes"
    );
    
    if (_magic != "PRG") {
        show_debug_message("[ProgSerializeTest] FAILED: Invalid magic.");
        return false;
    }
    
    if (_version != 1) {
        show_debug_message("[ProgSerializeTest] FAILED: Invalid version.");
        return false;
    }
    
    show_debug_message("[ProgSerializeTest] PASSED!");
    buffer_delete(_buffer);
    return true;
}
