function proglang_native_init() {
    // If the IDE hasn't reloaded the .yy, we force defining them manually
    var _dll = "proglang_native_vm.dll";
    
    // Check if one of the functions already exists (means IDE reloaded)
    if (real(asset_get_index("proglang_vm_create")) != -1) {
        show_debug_message("Proglang Native VM already bound via extension.");
        return true;
    }

    if (!file_exists(_dll)) {
        show_debug_message("Native VM DLL not found: " + _dll);
        return false;
    }

    global.__prg_vm_create = external_define(_dll, "proglang_vm_create", dll_cdecl, ty_real, 0);
    global.__prg_vm_destroy = external_define(_dll, "proglang_vm_destroy", dll_cdecl, ty_real, 1, ty_real);
    global.__prg_vm_load = external_define(_dll, "proglang_vm_load", dll_cdecl, ty_real, 3, ty_real, ty_string, ty_real);
    global.__prg_vm_run = external_define(_dll, "proglang_vm_run", dll_cdecl, ty_real, 1, ty_real);
    global.__prg_vm_get_type = external_define(_dll, "proglang_vm_get_type", dll_cdecl, ty_real, 1, ty_real);
    
    global.__prg_vm_pop_double = external_define(_dll, "proglang_vm_pop_double", dll_cdecl, ty_real, 1, ty_real);
    global.__prg_vm_push_double = external_define(_dll, "proglang_vm_push_double", dll_cdecl, ty_none, 2, ty_real, ty_real);
    
    global.__prg_vm_pop_string = external_define(_dll, "proglang_vm_pop_string", dll_cdecl, ty_string, 1, ty_real);
    global.__prg_vm_push_string = external_define(_dll, "proglang_vm_push_string", dll_cdecl, ty_none, 2, ty_real, ty_string);
    
    global.__prg_vm_get_yield_arg_count = external_define(_dll, "proglang_vm_get_yield_arg_count", dll_cdecl, ty_real, 1, ty_real);
    global.__prg_vm_get_yield_callee_string = external_define(_dll, "proglang_vm_get_yield_callee_string", dll_cdecl, ty_string, 1, ty_real);
    
    global.__prg_vm_define_global_double = external_define(_dll, "proglang_vm_define_global_double", dll_cdecl, ty_none, 3, ty_real, ty_string, ty_real);
    global.__prg_vm_define_global_string = external_define(_dll, "proglang_vm_define_global_string", dll_cdecl, ty_none, 3, ty_real, ty_string, ty_string);

    show_debug_message("Proglang Native VM initialized manually.");
    global.proglang_native_enabled = true;
    return true;
}
/*
// Wrapper macros for transparent fallback (Native vs Manual)
#macro proglang_vm_create (real(asset_get_index("proglang_vm_create")) != -1 ? proglang_vm_create() : external_call(global.__prg_vm_create))
#macro proglang_vm_destroy (real(asset_get_index("proglang_vm_destroy")) != -1 ? proglang_vm_destroy(argument0) : external_call(global.__prg_vm_destroy, argument0))
#macro proglang_vm_load (real(asset_get_index("proglang_vm_load")) != -1 ? proglang_vm_load(argument0, argument1, argument2) : external_call(global.__prg_vm_load, argument0, argument1, argument2))
#macro proglang_vm_run (real(asset_get_index("proglang_vm_run")) != -1 ? proglang_vm_run(argument0) : external_call(global.__prg_vm_run, argument0))
#macro proglang_vm_pop_double (real(asset_get_index("proglang_vm_pop_double")) != -1 ? proglang_vm_pop_double(argument0) : external_call(global.__prg_vm_pop_double, argument0))
#macro proglang_vm_push_double (real(asset_get_index("proglang_vm_push_double")) != -1 ? proglang_vm_push_double(argument0, argument1) : external_call(global.__prg_vm_push_double, argument0, argument1))
#macro proglang_vm_pop_string (real(asset_get_index("proglang_vm_pop_string")) != -1 ? proglang_vm_pop_string(argument0) : external_call(global.__prg_vm_pop_string, argument0))
#macro proglang_vm_push_string (real(asset_get_index("proglang_vm_push_string")) != -1 ? proglang_vm_push_string(argument0, argument1) : external_call(global.__prg_vm_push_string, argument0, argument1))
#macro proglang_vm_get_yield_arg_count (real(asset_get_index("proglang_vm_get_yield_arg_count")) != -1 ? proglang_vm_get_yield_arg_count(argument0) : external_call(global.__prg_vm_get_yield_arg_count, argument0))
#macro proglang_vm_get_yield_callee_string (real(asset_get_index("proglang_vm_get_yield_callee_string")) != -1 ? proglang_vm_get_yield_callee_string(argument0) : external_call(global.__prg_vm_get_yield_callee_string, argument0))
#macro proglang_vm_get_type (real(asset_get_index("proglang_vm_get_type")) != -1 ? proglang_vm_get_type(argument0) : external_call(global.__prg_vm_get_type, argument0))
#macro proglang_vm_define_global_double (real(asset_get_index("proglang_vm_define_global_double")) != -1 ? proglang_vm_define_global_double(argument0, argument1, argument2) : external_call(global.__prg_vm_define_global_double, argument0, argument1, argument2))
#macro proglang_vm_define_global_string (real(asset_get_index("proglang_vm_define_global_string")) != -1 ? proglang_vm_define_global_string(argument0, argument1, argument2) : external_call(global.__prg_vm_define_global_string, argument0, argument1, argument2))
