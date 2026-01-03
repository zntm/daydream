global.proglang_cache = {}
global.proglang_classes = {}
global.proglang_functions = {}
global.proglang_macros = {}
global.proglang_modules = {}
global.proglang_scripts = {}

global.proglang_macros[$ "infinity"] = infinity;
global.proglang_macros[$ "PI"] = pi;
global.proglang_macros[$ "TAU"] = pi * 2;
global.proglang_macros[$ "E"] = 2.71828182845904523536;
global.proglang_macros[$ "PHI"] = 1.61803398874989484820;

global.proglang_macros[$ "TILE_SIZE"] = TILE_SIZE;
global.proglang_macros[$ "CHUNK_DEPTH"] = {
    DEFAULT: CHUNK_DEPTH_DEFAULT,
    FOLIAGE_BACK: CHUNK_DEPTH_FOLIAGE_BACK,
    FOLIAGE_FRONT: CHUNK_DEPTH_FOLIAGE_FRONT,
    LIQUID: CHUNK_DEPTH_LIQUID,
    TREE_BACK: CHUNK_DEPTH_TREE_BACK,
    TREE_FRONT: CHUNK_DEPTH_TREE_FRONT,
    WALL: CHUNK_DEPTH_WALL
}

global.proglang_macros[$ "TILE_SIZE"] = TILE_SIZE;

global.proglang_macros[$ "CURRENT_YEAR"] = function()
{
    return current_year;
}

global.proglang_macros[$ "CURRENT_MONTH"] = function()
{
    return current_month;
}

global.proglang_macros[$ "CURRENT_DAY"] = function()
{
    return current_day;
}

global.proglang_macros[$ "CURRENT_WEEKDAY"] = function()
{
    return current_weekday;
}

global.proglang_macros[$ "CURRENT_HOUR"] = function()
{
    return current_hour;
}

global.proglang_macros[$ "CURRENT_MINUTE"] = function()
{
    return current_minute;
}

global.proglang_macros[$ "CURRENT_SECOND"] = function()
{
    return current_second;
}

global.proglang_macros[$ "FPS"] = function()
{
    return fps;
}

global.proglang_macros[$ "FPS_REAL"] = function()
{
    return fps_real;
}

global.proglang_macros[$ "DELTA_TIME"] = function()
{
    return global.delta_time;
}

global.proglang_macros[$ "SYS_USERNAME"] = function()
{
    return sysinfo_get_username();
}

global.proglang_macros[$ "SYS_HOSTNAME"] = function()
{
    return sysinfo_get_hostname();
}

global.proglang_macros[$ "SYS_PID"] = function()
{
    return sysinfo_get_pid();
}

global.proglang_macros[$ "SYS_CPU"] = function()
{
    return sysinfo_get_cpu_name();
}

global.proglang_macros[$ "SYS_CPU_BRAND"] = function()
{
    return sysinfo_get_cpu_brand();
}

global.proglang_macros[$ "SYS_CPU_VENDOR"] = function()
{
    return sysinfo_get_cpu_vendor_id();
}

global.proglang_macros[$ "SYS_CPU_FREQ"] = function()
{
    return sysinfo_get_cpu_frequency();
}

global.proglang_macros[$ "SYS_CORE_COUNT"] = function()
{
    return sysinfo_get_core_count();
}

global.proglang_macros[$ "SYS_CPU_USAGE"] = function()
{
    return sysinfo_sys_cpu_usage();
}

global.proglang_macros[$ "SYS_CPU_PROC"] = function()
{
    return sysinfo_proc_cpu_usage();
}

global.proglang_macros[$ "SYS_GPU"] = function()
{
    return sysinfo_get_gpu_name();
}

global.proglang_macros[$ "SYS_GPU_VRAM"] = function()
{
    return sysinfo_get_gpu_vram();
}

global.proglang_macros[$ "SYS_GPU_USAGE"] = function()
{
    return sysinfo_get_gpu_usage();
}

global.proglang_macros[$ "SYS_RAM_MAX"] = function()
{
    return sysinfo_get_memory_max();
}

global.proglang_macros[$ "SYS_RAM_USED"] = function()
{
    return sysinfo_sys_memory_used();
}

global.proglang_macros[$ "SYS_RAM_PROC"] = function()
{
    return sysinfo_proc_memory_used();
}

global.proglang_macros[$ "OS_TYPE"] = function()
{
    return os_type;
}

global.proglang_macros[$ "OS_VERSION"] = function()
{
    return os_version;
}

global.proglang_macros[$ "WINDOW_WIDTH"] = function()
{
    return window_get_width();
}

global.proglang_macros[$ "WINDOW_HEIGHT"] = function()
{
    return window_get_height();
}

global.proglang_macros[$ "DISPLAY_WIDTH"] = function()
{
    return display_get_width();
}

global.proglang_macros[$ "DISPLAY_HEIGHT"] = function()
{
    return display_get_height();
}

global.proglang_macros[$ "WORLD_MOUSE_X"] = function()
{
    return mouse_x;
}

global.proglang_macros[$ "WORLD_MOUSE_Y"] = function()
{
    return mouse_y;
}

global.proglang_macros[$ "DEVICE_MOUSE_X"] = function()
{
    return device_mouse_x(0);
}

global.proglang_macros[$ "DEVICE_MOUSE_Y"] = function()
{
    return device_mouse_y(0);
}

global.proglang_macros[$ "GUI_MOUSE_X"] = function()
{
    return device_mouse_x_to_gui(0);
}

global.proglang_macros[$ "GUI_MOUSE_Y"] = function()
{
    return device_mouse_y_to_gui(0);
}

global.proglang_macros[$ "ERROR_TYPE"] = {
    RUNTIME: PROGLANG_ERROR_TYPE.RUNTIME,
    TYPE: PROGLANG_ERROR_TYPE.TYPE,
    INDEX: PROGLANG_ERROR_TYPE.INDEX,
    MEMBER: PROGLANG_ERROR_TYPE.MEMBER,
    VARIABLE: PROGLANG_ERROR_TYPE.VARIABLE,
    DIVIDE_BY_ZERO: PROGLANG_ERROR_TYPE.DIVIDE_BY_ZERO,
    UNDEFINED_VALUE: PROGLANG_ERROR_TYPE.UNDEFINED_VALUE,
    NULL_REFERENCE: PROGLANG_ERROR_TYPE.NULL_REFERENCE,
    INVALID_ARGUMENT: PROGLANG_ERROR_TYPE.INVALID_ARGUMENT,
    NOT_CALLABLE: PROGLANG_ERROR_TYPE.NOT_CALLABLE,
    SYNTAX: PROGLANG_ERROR_TYPE.SYNTAX,
    IMPORT: PROGLANG_ERROR_TYPE.IMPORT,
    STACK_OVERFLOW: PROGLANG_ERROR_TYPE.STACK_OVERFLOW,
    STACK_UNDERFLOW: PROGLANG_ERROR_TYPE.STACK_UNDERFLOW,
    RECURSION_LIMIT: PROGLANG_ERROR_TYPE.RECURSION_LIMIT,
    INFINITE_LOOP: PROGLANG_ERROR_TYPE.INFINITE_LOOP,
    ACCESS_DENIED: PROGLANG_ERROR_TYPE.ACCESS_DENIED,
    ABSTRACT_METHOD: PROGLANG_ERROR_TYPE.ABSTRACT_METHOD,
    FILE_NOT_FOUND: PROGLANG_ERROR_TYPE.FILE_NOT_FOUND,
    PATH_SECURITY: PROGLANG_ERROR_TYPE.PATH_SECURITY,
    ARITY_MISMATCH: PROGLANG_ERROR_TYPE.ARITY_MISMATCH,
    SUPER_ERROR: PROGLANG_ERROR_TYPE.SUPER_ERROR
}

global.proglang_macros[$ "EVENT_TYPE"] = {
    // Entity Movement
    ENTITY_STEP: GAME_EVENT.ENTITY_STEP,
    ENTITY_SWIM: GAME_EVENT.ENTITY_SWIM,
    ENTITY_LAND: GAME_EVENT.ENTITY_LAND,
    ENTITY_SPLASH: GAME_EVENT.ENTITY_SPLASH,
    
    // Entity Actions
    ENTITY_CONSUME: GAME_EVENT.ENTITY_CONSUME,
    ENTITY_HEAL: GAME_EVENT.ENTITY_HEAL,
    ENTITY_DAMAGE: GAME_EVENT.ENTITY_DAMAGE,
    ENTITY_DIE: GAME_EVENT.ENTITY_DIE,
    ENTITY_SPAWN: GAME_EVENT.ENTITY_SPAWN,
    ENTITY_MOUNT: GAME_EVENT.ENTITY_MOUNT,
    ENTITY_DISMOUNT: GAME_EVENT.ENTITY_DISMOUNT,
    ENTITY_TELEPORT: GAME_EVENT.ENTITY_TELEPORT,
    
    // Entity Item Interactions
    ENTITY_ITEM_COLLECT: GAME_EVENT.ENTITY_ITEM_COLLECT,
    ENTITY_ITEM_DROP: GAME_EVENT.ENTITY_ITEM_DROP,
    
    // Item Events
    ITEM_COLLECT: GAME_EVENT.ITEM_COLLECT,
    ITEM_DROP: GAME_EVENT.ITEM_DROP,
    
    // Tile Item Interactions
    TILE_ITEM_COLLECT: GAME_EVENT.TILE_ITEM_COLLECT,
    TILE_ITEM_DROP: GAME_EVENT.TILE_ITEM_DROP,
    
    // Projectile Events
    PROJECTILE_SHOOT: GAME_EVENT.PROJECTILE_SHOOT,
    PROJECTILE_LAND: GAME_EVENT.PROJECTILE_LAND,
    
    // Item Use Events
    ITEM_USE: GAME_EVENT.ITEM_USE,
    ITEM_USE_START: GAME_EVENT.ITEM_USE_START,
    ITEM_USE_FINISH: GAME_EVENT.ITEM_USE_FINISH,
    
    // Tile Use Events
    TILE_USE: GAME_EVENT.TILE_USE,
    TILE_USE_START: GAME_EVENT.TILE_USE_START,
    TILE_USE_FINISH: GAME_EVENT.TILE_USE_FINISH,
    
    // Tile Placement Events
    TILE_PLACE: GAME_EVENT.TILE_PLACE,
    TILE_UPDATE: GAME_EVENT.TILE_UPDATE,
    
    // Container Events
    TILE_CONTAINER_OPEN: GAME_EVENT.TILE_CONTAINER_OPEN,
    TILE_CONTAINER_CLOSE: GAME_EVENT.TILE_CONTAINER_CLOSE,
    
    // Explosive Events
    EXPLOSIVE_PRIME: GAME_EVENT.EXPLOSIVE_PRIME,
    EXPLOSIVE_EXPLODE: GAME_EVENT.EXPLOSIVE_EXPLODE,
    
    // Miscellaneous
    TILE_FALLING_LAND: GAME_EVENT.TILE_FALLING_LAND,
    ITEM_CRAFT: GAME_EVENT.ITEM_CRAFT
}

global.proglang_macros[$ "GAME_EVENT"] = global.proglang_macros[$ "EVENT_TYPE"];

// Event Data Constructors - one for each GAME_EVENT type

// Entity Movement
global.proglang_classes[$ "EventDataEntityStep"] = EventDataEntityStep;
global.proglang_classes[$ "EventDataEntitySwim"] = EventDataEntitySwim;
global.proglang_classes[$ "EventDataEntityLand"] = EventDataEntityLand;
global.proglang_classes[$ "EventDataEntitySplash"] = EventDataEntitySplash;

// Entity Actions
global.proglang_classes[$ "EventDataEntityConsume"] = EventDataEntityConsume;
global.proglang_classes[$ "EventDataEntityHeal"] = EventDataEntityHeal;
global.proglang_classes[$ "EventDataEntityDamage"] = EventDataEntityDamage;
global.proglang_classes[$ "EventDataEntityDie"] = EventDataEntityDie;
global.proglang_classes[$ "EventDataEntitySpawn"] = EventDataEntitySpawn;
global.proglang_classes[$ "EventDataEntityMount"] = EventDataEntityMount;
global.proglang_classes[$ "EventDataEntityDismount"] = EventDataEntityDismount;
global.proglang_classes[$ "EventDataEntityTeleport"] = EventDataEntityTeleport;

// Entity Item Interactions
global.proglang_classes[$ "EventDataEntityItemCollect"] = EventDataEntityItemCollect;
global.proglang_classes[$ "EventDataEntityItemDrop"] = EventDataEntityItemDrop;

// Item Events
global.proglang_classes[$ "EventDataItemCollect"] = EventDataItemCollect;
global.proglang_classes[$ "EventDataItemDrop"] = EventDataItemDrop;

// Tile Item Interactions
global.proglang_classes[$ "EventDataTileItemCollect"] = EventDataTileItemCollect;
global.proglang_classes[$ "EventDataTileItemDrop"] = EventDataTileItemDrop;

// Projectile Events
global.proglang_classes[$ "EventDataProjectileShoot"] = EventDataProjectileShoot;
global.proglang_classes[$ "EventDataProjectileLand"] = EventDataProjectileLand;

// Item Use Events
global.proglang_classes[$ "EventDataItemUse"] = EventDataItemUse;
global.proglang_classes[$ "EventDataItemUseStart"] = EventDataItemUseStart;
global.proglang_classes[$ "EventDataItemUseFinish"] = EventDataItemUseFinish;
global.proglang_classes[$ "EventDataItemCraft"] = EventDataItemCraft;

// Tile Use Events
global.proglang_classes[$ "EventDataTileUse"] = EventDataTileUse;
global.proglang_classes[$ "EventDataTileUseStart"] = EventDataTileUseStart;
global.proglang_classes[$ "EventDataTileUseFinish"] = EventDataTileUseFinish;

// Tile Placement Events
global.proglang_classes[$ "EventDataTilePlace"] = EventDataTilePlace;
global.proglang_classes[$ "EventDataTileUpdate"] = EventDataTileUpdate;

// Container Events
global.proglang_classes[$ "EventDataTileContainerOpen"] = EventDataTileContainerOpen;
global.proglang_classes[$ "EventDataTileContainerClose"] = EventDataTileContainerClose;

// Explosive Events
global.proglang_classes[$ "EventDataExplosivePrime"] = EventDataExplosivePrime;
global.proglang_classes[$ "EventDataExplosiveExplode"] = EventDataExplosiveExplode;

// Miscellaneous
global.proglang_classes[$ "EventDataTileFallingLand"] = EventDataTileFallingLand;

global.proglang_classes[$ "Tile"] = Tile;
global.proglang_classes[$ "Inventory"] = Inventory;