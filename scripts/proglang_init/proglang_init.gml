/// @desc Initialize Proglang environment
function proglang_init() {
    // Clear bytecode cache to ensure fresh compilation after hot-reload
    if (variable_global_exists("proglang_cache")) {
        global.proglang_cache = {}
    }
    
    // Global function registry
    if (!variable_global_exists("proglang_functions")) {
        global.proglang_functions = {}
    }
    
    // Global script registry
    if (!variable_global_exists("proglang_scripts")) {
        global.proglang_scripts = {}
    }
    
    // Global module registry
    if (!variable_global_exists("proglang_modules")) {
        global.proglang_modules = {}
    }
    
    // Global constants
    if (!variable_global_exists("proglang_macros")) {
        global.proglang_macros = {}
    }
    
    global.proglang_macros[$ "infinity"] = infinity;
    global.proglang_macros[$ "PI"] = pi;
    global.proglang_macros[$ "TAU"] = pi * 2;
    global.proglang_macros[$ "E"] = 2.71828182845904523536;
    global.proglang_macros[$ "PHI"] = 1.61803398874989484820; // Golden Ratio
    
    // Time Macros
    global.proglang_macros[$ "CURRENT_YEAR"] = function() { return current_year; }
    global.proglang_macros[$ "CURRENT_MONTH"] = function() { return current_month; }
    global.proglang_macros[$ "CURRENT_DAY"] = function() { return current_day; }
    global.proglang_macros[$ "CURRENT_WEEKDAY"] = function() { return current_weekday; }
    global.proglang_macros[$ "CURRENT_HOUR"] = function() { return current_hour; }
    global.proglang_macros[$ "CURRENT_MINUTE"] = function() { return current_minute; }
    global.proglang_macros[$ "CURRENT_SECOND"] = function() { return current_second; }
    // global.proglang_macros[$ "CURRENT_TIME"] = function() { return current_time; } // ms since start
    
    // Engine Macros
    global.proglang_macros[$ "FPS"] = function() { return fps; }
    global.proglang_macros[$ "FPS_REAL"] = function() { return fps_real; }
    global.proglang_macros[$ "DELTA_TIME"] = function() { return global.delta_time; }
    
    // Sysinfo Macros
    global.proglang_macros[$ "SYS_USERNAME"] = function() { return sysinfo_get_username(); }
    global.proglang_macros[$ "SYS_HOSTNAME"] = function() { return sysinfo_get_hostname(); }
    global.proglang_macros[$ "SYS_PID"] = function() { return sysinfo_get_pid(); }
    
    global.proglang_macros[$ "SYS_CPU"] = function() { return sysinfo_get_cpu_name(); }
    global.proglang_macros[$ "SYS_CPU_BRAND"] = function() { return sysinfo_get_cpu_brand(); }
    global.proglang_macros[$ "SYS_CPU_VENDOR"] = function() { return sysinfo_get_cpu_vendor_id(); }
    global.proglang_macros[$ "SYS_CPU_FREQ"] = function() { return sysinfo_get_cpu_frequency(); }
    global.proglang_macros[$ "SYS_CORE_COUNT"] = function() { return sysinfo_get_core_count(); }
    global.proglang_macros[$ "SYS_CPU_USAGE"] = function() { return sysinfo_sys_cpu_usage(); }
    global.proglang_macros[$ "SYS_CPU_PROC"] = function() { return sysinfo_proc_cpu_usage(); }
    
    global.proglang_macros[$ "SYS_GPU"] = function() { return sysinfo_get_gpu_name(); }
    global.proglang_macros[$ "SYS_GPU_VRAM"] = function() { return sysinfo_get_gpu_vram(); }
    global.proglang_macros[$ "SYS_GPU_USAGE"] = function() { return sysinfo_get_gpu_usage(); }
    
    global.proglang_macros[$ "SYS_RAM_MAX"] = function() { return sysinfo_get_memory_max(); }
    global.proglang_macros[$ "SYS_RAM_USED"] = function() { return sysinfo_sys_memory_used(); }
    global.proglang_macros[$ "SYS_RAM_PROC"] = function() { return sysinfo_proc_memory_used(); }
    
    // OS Macros
    global.proglang_macros[$ "OS_TYPE"] = function() { return os_type; }
    global.proglang_macros[$ "OS_VERSION"] = function() { return os_version; }
    
    // Display & Window Macros
    global.proglang_macros[$ "WINDOW_WIDTH"] = function() { return window_get_width(); }
    global.proglang_macros[$ "WINDOW_HEIGHT"] = function() { return window_get_height(); }
    global.proglang_macros[$ "DISPLAY_WIDTH"] = function() { return display_get_width(); }
    global.proglang_macros[$ "DISPLAY_HEIGHT"] = function() { return display_get_height(); }
    
    // Input Macros
    global.proglang_macros[$ "WORLD_MOUSE_X"] = function() { return mouse_x; } // Room X
    global.proglang_macros[$ "WORLD_MOUSE_Y"] = function() { return mouse_y; } // Room Y
    global.proglang_macros[$ "DEVICE_MOUSE_X"] = function() { return device_mouse_x(0); }
    global.proglang_macros[$ "DEVICE_MOUSE_Y"] = function() { return device_mouse_y(0); }
    global.proglang_macros[$ "GUI_MOUSE_X"] = function() { return device_mouse_x_to_gui(0); }
    global.proglang_macros[$ "GUI_MOUSE_Y"] = function() { return device_mouse_y_to_gui(0); }
    
    // Expose PROG_ERROR enum
    global.proglang_macros.PROG_ERROR = {
        RUNTIME: PROG_ERROR.RUNTIME,
        TYPE: PROG_ERROR.TYPE,
        INDEX: PROG_ERROR.INDEX,
        MEMBER: PROG_ERROR.MEMBER,
        VARIABLE: PROG_ERROR.VARIABLE,
        DIVIDE_BY_ZERO: PROG_ERROR.DIVIDE_BY_ZERO,
        UNDEFINED_VALUE: PROG_ERROR.UNDEFINED_VALUE,
        NULL_REFERENCE: PROG_ERROR.NULL_REFERENCE,
        INVALID_ARGUMENT: PROG_ERROR.INVALID_ARGUMENT,
        NOT_CALLABLE: PROG_ERROR.NOT_CALLABLE,
        SYNTAX: PROG_ERROR.SYNTAX,
        IMPORT: PROG_ERROR.IMPORT,
        STACK_OVERFLOW: PROG_ERROR.STACK_OVERFLOW,
        STACK_UNDERFLOW: PROG_ERROR.STACK_UNDERFLOW,
        RECURSION_LIMIT: PROG_ERROR.RECURSION_LIMIT,
        INFINITE_LOOP: PROG_ERROR.INFINITE_LOOP,
        ACCESS_DENIED: PROG_ERROR.ACCESS_DENIED,
        ABSTRACT_METHOD: PROG_ERROR.ABSTRACT_METHOD,
        FILE_NOT_FOUND: PROG_ERROR.FILE_NOT_FOUND,
        PATH_SECURITY: PROG_ERROR.PATH_SECURITY,
        ARITY_MISMATCH: PROG_ERROR.ARITY_MISMATCH,
        SUPER_ERROR: PROG_ERROR.SUPER_ERROR
    }
}
