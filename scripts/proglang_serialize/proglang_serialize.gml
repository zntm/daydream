/// @desc Serialize a Proglang bytecode object to a binary buffer
/// @param {struct} _bytecode The root ProgBytecode object
/// @returns {Id.Buffer} The resulting buffer
function proglang_serialize(_bytecode) {
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    // Header Placeholder (16 bytes)
    buffer_write(_buffer, buffer_string, "PRG"); // Handle null later
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_u8, ord("P"));
    buffer_write(_buffer, buffer_u8, ord("R"));
    buffer_write(_buffer, buffer_u8, ord("G"));
    buffer_write(_buffer, buffer_u8, 0); // Magic: PRG\0
    
    buffer_write(_buffer, buffer_u32, 1); // Version
    
    var _header_cp_count_pos = buffer_tell(_buffer);
    buffer_write(_buffer, buffer_u32, 0); // Placeholder for CP Count
    
    var _header_bc_len_pos = buffer_tell(_buffer);
    buffer_write(_buffer, buffer_u32, 0); // Placeholder for BC Length
    
    // Constant Pool Collection
    var _constants = []; // Flattened constants for CP
    var _string_indices = {}; // To find string indices
    
    var _all_bytecodes = []; // [ { bytecode: bc, offset: 0, length: 0 } ]
    var _bc_queue = [_bytecode];
    
    // Phase 1: Collect all bytecodes and their constants
    while (array_length(_bc_queue) > 0) {
        var _bc = array_shift(_bc_queue);
        array_push(_all_bytecodes, { bytecode: _bc, offset: 0, length: 0 });
        
        // Find nested bytecodes in constants
        for (var i = 0; i < array_length(_bc.constants); i++) {
            var _c = _bc.constants[i];
            if (is_array(_c) && array_length(_c) >= PROG_FUNC.SIZE && _c[PROG_FUNC.TYPE] == "function") {
                array_push(_bc_queue, _c[PROG_FUNC.BYTECODE]);
            }
        }
    }
    
    // Phase 2: Build Global Constant Pool
    var _cp_builder = {
        global_cp: [],
        add: function(_val) {
            // Simple search for now
            for (var i = 0; i < array_length(global_cp); i++) {
                if (global_cp[i] == _val) return i;
            }

            // Recursive collection for structures (post-order)
            if (is_struct(_val)) {
                var _names = variable_struct_get_names(_val);
                for (var i = 0; i < array_length(_names); i++) {
                    var _n = _names[i];
                    self.add(_n);
                    self.add(_val[$ _n]);
                }
            } else if (is_array(_val) && array_length(_val) >= PROG_FUNC.SIZE && _val[PROG_FUNC.TYPE] == "function") {
                self.add(_val[PROG_FUNC.NAME]);
            }

            array_push(global_cp, _val);
            return array_length(global_cp) - 1;
        }
    };
    
    // We need to map local constants to global constant indices
    var _bc_cp_maps = []; 
    
    for (var i = 0; i < array_length(_all_bytecodes); i++) {
        var _bc_struct = _all_bytecodes[i];
        var _local_cp = _bc_struct.bytecode.constants;
        var _map = array_create(array_length(_local_cp));
        
        for (var j = 0; j < array_length(_local_cp); j++) {
            _map[j] = _cp_builder.add(_local_cp[j]);
        }
        _bc_cp_maps[i] = _map;
    }
    var _global_cp = _cp_builder.global_cp;
    
    // Write Constant Pool
    buffer_poke(_buffer, _header_cp_count_pos, buffer_u32, array_length(_global_cp));
    
    var _func_backpatches = []; // [ { val: func_arr, pos: pos } ]
    
    for (var i = 0; i < array_length(_global_cp); i++) {
        var _val = _global_cp[i];
        if (_val == undefined) {
            buffer_write(_buffer, buffer_u8, 0x00);
        } else if (is_real(_val)) {
            buffer_write(_buffer, buffer_u8, 0x01);
            buffer_write(_buffer, buffer_f64, _val);
        } else if (is_string(_val)) {
            buffer_write(_buffer, buffer_u8, 0x02);
            var _str_buf = buffer_create(string_byte_length(_val) + 1, buffer_fixed, 1);
            buffer_write(_str_buf, buffer_string, _val);
            var _str_len = buffer_tell(_str_buf) - 1; // Exclude null
            buffer_write(_buffer, buffer_u32, _str_len);
            buffer_copy(_str_buf, 0, _str_len, _buffer, buffer_tell(_buffer));
            buffer_seek(_buffer, buffer_seek_relative, _str_len);
            buffer_delete(_str_buf);
        } else if (is_bool(_val)) {
            buffer_write(_buffer, buffer_u8, 0x04);
            buffer_write(_buffer, buffer_u8, _val ? 1 : 0);
        } else if (is_array(_val) && array_length(_val) >= PROG_FUNC.SIZE && _val[PROG_FUNC.TYPE] == "function") {
            buffer_write(_buffer, buffer_u8, 0x03);
            
            // Function Pointer Data: Offset (4), Length (4), ParamCount (4), NameIdx (4)
            array_push(_func_backpatches, { val: _val, pos: buffer_tell(_buffer) });
            
            buffer_write(_buffer, buffer_u32, 0); // Offset (to be patched)
            buffer_write(_buffer, buffer_u32, 0); // Length (to be patched)
            buffer_write(_buffer, buffer_u32, _val[PROG_FUNC.PARAM_COUNT]);
            
            // Name as string constant
            var _name_idx = _cp_builder.add(_val[PROG_FUNC.NAME]);
            buffer_write(_buffer, buffer_u32, _name_idx);
        } else if (is_struct(_val)) {
            buffer_write(_buffer, buffer_u8, 0x06); // Struct Tag
            var _names = variable_struct_get_names(_val);
            var _count = array_length(_names);
            buffer_write(_buffer, buffer_u32, _count);
            for (var j = 0; j < _count; j++) {
                var _name = _names[j];
                var _name_idx = _cp_builder.add(_name);
                var _v_idx = _cp_builder.add(_val[$ _name]);
                buffer_write(_buffer, buffer_u32, _name_idx);
                buffer_write(_buffer, buffer_u32, _v_idx);
            }
        } else {
            buffer_write(_buffer, buffer_u8, 0x00);
        }
    }
    
    // Phase 3: Write Bytecode
    var _bc_start_pos = buffer_tell(_buffer);
    
    for (var i = 0; i < array_length(_all_bytecodes); i++) {
        var _bc_struct = _all_bytecodes[i];
        var _bc = _bc_struct.bytecode;
        var _map = _bc_cp_maps[i];
        
        _bc_struct.offset = buffer_tell(_buffer) - _bc_start_pos;
        
        var _code = _bc.code;
        var _lines = _bc.lines;
        
        for (var j = 0; j < array_length(_code); j += 2) {
            var _op = _code[j];
            var _arg = _code[j + 1];
            var _line = _lines[j / 2];
            
            // Instruction (8 bytes)
            buffer_write(_buffer, buffer_u8, _op);
            buffer_write(_buffer, buffer_u8, 0); // Reserved
            buffer_write(_buffer, buffer_u16, _line);
            
            // Argument handling
            if (_op == PROG_OP.PUSH_CONST || _op == PROG_OP.MEMBER_GET || _op == PROG_OP.MEMBER_SET || 
                _op == PROG_OP.LOAD || _op == PROG_OP.STORE || _op == PROG_OP.DEFINE ||
                _op == PROG_OP.LOAD_GLOBAL || _op == PROG_OP.STORE_GLOBAL || _op == PROG_OP.CLASS_DEF) {
                buffer_write(_buffer, buffer_s32, _map[_arg]);
            } else if (_op == PROG_OP.JUMP || _op == PROG_OP.JUMP_IF_FALSE || 
                       _op == PROG_OP.JUMP_IF_NULL || _op == PROG_OP.JUMP_IF_NOT_NULL ||
                       _op == PROG_OP.PUSH_TRY) {
                buffer_write(_buffer, buffer_s32, (_arg / 2) * 8);
            } else {
                buffer_write(_buffer, buffer_s32, is_numeric(_arg) ? _arg : 0);
            }
        }
        
        _bc_struct.length = (buffer_tell(_buffer) - _bc_start_pos) - _bc_struct.offset;
    }
    
    var _bc_total_len = buffer_tell(_buffer) - _bc_start_pos;
    buffer_poke(_buffer, _header_bc_len_pos, buffer_u32, _bc_total_len);
    
    // Back-patch Function Pointers
    for (var i = 0; i < array_length(_func_backpatches); i++) {
        var _bp = _func_backpatches[i];
        var _bc_obj = _bp.val[PROG_FUNC.BYTECODE];
        
        for (var k = 0; k < array_length(_all_bytecodes); k++) {
            if (_all_bytecodes[k].bytecode == _bc_obj) {
                buffer_poke(_buffer, _bp.pos, buffer_u32, _all_bytecodes[k].offset);
                buffer_poke(_buffer, _bp.pos + 4, buffer_u32, _all_bytecodes[k].length);
                break;
            }
        }
    }
    
    return _buffer;
}
