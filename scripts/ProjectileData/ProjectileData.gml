enum PROJECTILE_BOOL {
    DESTROY_ON_TILE    = 1 << 0,
    DESTROY_ON_ENTITY  = 1 << 1,
    ADDITIVE           = 1 << 2,
    FADE_OUT           = 1 << 3,
    HAS_COLLISION      = 1 << 4,
    STRETCH_ANIMATION  = 1 << 5
}

enum PROJECTILE_PARTICLE_MODE {
    TICK,
    SHOOT,
    LAND
}

#macro PROJECTILE_PROPERTIES_MAP global.___projectile_properties_map

PROJECTILE_PROPERTIES_MAP = {
    "phantasia:can_destroy_on_tile_collision":   PROJECTILE_BOOL.DESTROY_ON_TILE,
    "phantasia:can_destroy_on_entity_collision": PROJECTILE_BOOL.DESTROY_ON_ENTITY,
    "phantasia:is_additive":                    PROJECTILE_BOOL.ADDITIVE,
    "phantasia:is_fade_out":                    PROJECTILE_BOOL.FADE_OUT,
    "phantasia:has_collision":                  PROJECTILE_BOOL.HAS_COLLISION,
    "phantasia:has_stretch_animation":          PROJECTILE_BOOL.STRETCH_ANIMATION
}

/// @desc Projectile data constructor.
/// @param {String} _namespace
/// @param {String} _id
/// @param {String} _sprite
function ProjectileData(_namespace, _id, _sprite) : ParentData(_namespace, _id) constructor
{
    ___sprite   = _sprite;
    ___boolean  = 0;
    ___lifetime = 60;
    ___gravity  = 0;
    
    /* launch physics */
    ___speed              = 0;
    ___speed_y            = 0;
    ___scale              = 1;
    ___rotation           = 0;
    ___rotation_increment = 0;
    
    /* on-collision physics override */
    ___on_collision_speed_x = undefined;
    ___on_collision_speed_y = undefined;
    
    /* attribute (collision/hit box) */
    ___attribute = undefined;
    
    /* particles: array of { id, mode, frequency, offset_x, offset_y } */
    ___particles = undefined;
    
    /* proglang script hook arrays */
    ___on_shoot      = undefined;
    ___on_tick       = undefined;
    ___on_hit_entity = undefined;
    ___on_hit_tile   = undefined;
    ___on_land       = undefined;
    
    #region Setters
    
    static set_sprite = function(_v) { ___sprite = _v; return self; }
    static set_boolean = function(_v) { ___boolean = _v; return self; }
    static set_lifetime = function(_v) { ___lifetime = _v; return self; }
    static set_gravity = function(_v) { ___gravity = _v; return self; }
    static set_speed = function(_v) { ___speed = _v; return self; }
    static set_speed_y = function(_v) { ___speed_y = _v; return self; }
    static set_scale = function(_v) { ___scale = _v; return self; }
    static set_rotation = function(_v) { ___rotation = _v; return self; }
    static set_rotation_increment = function(_v) { ___rotation_increment = _v; return self; }
    static set_on_collision_speed_x = function(_v) { ___on_collision_speed_x = _v; return self; }
    static set_on_collision_speed_y = function(_v) { ___on_collision_speed_y = _v; return self; }
    static set_attribute = function(_v) { ___attribute = _v; return self; }
    static set_particles = function(_v) { ___particles = _v; return self; }
    static set_on_shoot = function(_v) { ___on_shoot = _v; return self; }
    static set_on_tick = function(_v) { ___on_tick = _v; return self; }
    static set_on_hit_entity = function(_v) { ___on_hit_entity = _v; return self; }
    static set_on_hit_tile = function(_v) { ___on_hit_tile = _v; return self; }
    static set_on_land = function(_v) { ___on_land = _v; return self; }
    
    #endregion
    
    #region Getters
    
    static get_sprite = function() { return ___sprite; }
    static get_boolean = function() { return ___boolean; }
    static get_lifetime = function() { return ___lifetime; }
    static get_gravity = function() { return ___gravity; }
    static get_speed = function() { return ___speed; }
    static get_speed_y = function() { return ___speed_y; }
    static get_scale = function() { return ___scale; }
    static get_rotation = function() { return ___rotation; }
    static get_rotation_increment = function() { return ___rotation_increment; }
    static get_on_collision_speed_x = function() { return ___on_collision_speed_x; }
    static get_on_collision_speed_y = function() { return ___on_collision_speed_y; }
    static get_attribute = function() { return ___attribute; }
    static get_particles = function() { return ___particles; }
    static get_on_shoot = function() { return ___on_shoot; }
    static get_on_tick = function() { return ___on_tick; }
    static get_on_hit_entity = function() { return ___on_hit_entity; }
    static get_on_hit_tile = function() { return ___on_hit_tile; }
    static get_on_land = function() { return ___on_land; }
    
    #endregion
}

/// @desc Parse boolean properties from a JSON array of property strings.
/// @param {Array} _properties
/// @returns {Real} bitfield
function projectile_parse_properties(_properties)
{
    if (_properties == undefined) return 0;
    
    var _bits = 0;
    var _len  = array_length(_properties);
    
    for (var i = 0; i < _len; ++i)
    {
        var _flag = PROJECTILE_PROPERTIES_MAP[$ _properties[i]];
        
        if (_flag != undefined) _bits |= _flag;
    }
    
    return _bits;
}

/// @desc Parse a particle array from JSON into runtime format with mode enums.
/// @param {Array} _particles_json
/// @returns {Array|Undefined}
function projectile_parse_particles(_particles_json)
{
    if (_particles_json == undefined) return undefined;
    
    var _len = array_length(_particles_json);
    
    if (_len == 0) return undefined;
    
    var _out = array_create(_len);
    
    for (var i = 0; i < _len; ++i)
    {
        var _p    = _particles_json[i];
        var _mode = _p[$ "mode"] ?? "tick";
        
        _out[i] = {
            id:        _p[$ "id"],
            mode: (_mode == "shoot") ? PROJECTILE_PARTICLE_MODE.SHOOT
                : ((_mode == "land") ? PROJECTILE_PARTICLE_MODE.LAND
                    : PROJECTILE_PARTICLE_MODE.TICK),
            frequency: _p[$ "frequency"] ?? 0.1,
            offset_x:  _p[$ "offset_x"]  ?? 0,
            offset_y:  _p[$ "offset_y"]  ?? 0
        }
    }
    
    return _out;
}