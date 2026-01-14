/// @desc Loom Nodes - Initial node library for the Loom system
/// Contains Math, Input, Generator, and Output nodes

// ============================================================================
// MATH NODES
// ============================================================================

/// @desc Constant value node
function LoomNodeConstant() : LoomNode("Constant") constructor
{
    display_name = "Constant";
    add_input("in_value", "value", undefined); // Optional input to override or daisy-chain
    add_output("value", "value");
    
    // Store the constant value
    constant_value = 0;
    
    static set_value = function(_value)
    {
        constant_value = _value;
        return self;
    }
    
    static process = function(_context)
    {
        var _in = get_input_value("in_value", _context);
        if (_in != undefined)
        {
            set_output_value("value", _in);
        }
        else
        {
            set_output_value("value", constant_value);
        }
    }
}

/// @desc Add two values
function LoomNodeAdd() : LoomNode("Add") constructor
{
    display_name = "Add";
    add_input("a", "value", 0);
    add_input("b", "value", 0);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("result", _a + _b);
    }
}

/// @desc Subtract two values
function LoomNodeSubtract() : LoomNode("Subtract") constructor
{
    display_name = "Subtract";
    add_input("a", "value", 0);
    add_input("b", "value", 0);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("result", _a - _b);
    }
}

/// @desc Multiply two values
function LoomNodeMultiply() : LoomNode("Multiply") constructor
{
    display_name = "Multiply";
    add_input("a", "value", 1);
    add_input("b", "value", 1);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("result", _a * _b);
    }
}

/// @desc Divide two values
function LoomNodeDivide() : LoomNode("Divide") constructor
{
    display_name = "Divide";
    add_input("a", "value", 1);
    add_input("b", "value", 1);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("result", (_b != 0) ? (_a / _b) : 0);
    }
}

/// @desc Clamp a value between min and max
function LoomNodeClamp() : LoomNode("Clamp") constructor
{
    display_name = "Clamp";
    add_input("value", "value", 0);
    add_input("min", "value", 0);
    add_input("max", "value", 1);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _val = get_input_value("value", _context);
        var _min = get_input_value("min", _context);
        var _max = get_input_value("max", _context);
        set_output_value("result", clamp(_val, _min, _max));
    }
}

/// @desc Lerp between two values
function LoomNodeLerp() : LoomNode("Lerp") constructor
{
    display_name = "Lerp";
    add_input("a", "value", 0);
    add_input("b", "value", 1);
    add_input("t", "value", 0.5);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        var _t = get_input_value("t", _context);
        set_output_value("result", lerp(_a, _b, _t));
    }
}

/// @desc Absolute value
function LoomNodeAbs() : LoomNode("Abs") constructor
{
    display_name = "Abs";
    add_input("value", "value", 0);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _val = get_input_value("value", _context);
        set_output_value("result", abs(_val));
    }
}

/// @desc Maximum of two values
function LoomNodeMax() : LoomNode("Max") constructor
{
    display_name = "Max";
    add_input("a", "value", 0);
    add_input("b", "value", 0);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("result", max(_a, _b));
    }
}

/// @desc Minimum of two values
function LoomNodeMin() : LoomNode("Min") constructor
{
    display_name = "Min";
    add_input("a", "value", 0);
    add_input("b", "value", 0);
    add_output("result", "value");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("result", min(_a, _b));
    }
}

// ============================================================================
// INPUT NODES
// ============================================================================

/// @desc Get current coordinate from context
function LoomNodeInputCoordinate() : LoomNode("InputCoordinate") constructor
{
    display_name = "Coordinate";
    add_output("x", "value");
    add_output("y", "value");
    add_output("z", "value");
    
    static process = function(_context)
    {
        set_output_value("x", _context[$ "x"] ?? 0);
        set_output_value("y", _context[$ "y"] ?? 0);
        set_output_value("z", _context[$ "z"] ?? 0);
    }
}

/// @desc Get world seed from context
function LoomNodeInputSeed() : LoomNode("InputSeed") constructor
{
    display_name = "Seed";
    add_output("seed", "value");
    
    static process = function(_context)
    {
        set_output_value("seed", _context[$ "seed"] ?? 0);
    }
}

/// @desc Get world data from context
function LoomNodeInputWorldData() : LoomNode("InputWorldData") constructor
{
    display_name = "World Data";
    add_output("world_data", "struct");
    
    static process = function(_context)
    {
        set_output_value("world_data", _context[$ "world_data"]);
    }
}

// ============================================================================
// GENERATOR NODES
// ============================================================================

/// @desc Simplex noise generator
function LoomNodeSimplexNoise() : LoomNode("SimplexNoise") constructor
{
    display_name = "Simplex Noise";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_input("scale", "value", 0.02);
    add_input("octaves", "value", 1);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _scale = get_input_value("scale", _context);
        var _octaves = floor(get_input_value("octaves", _context));
        
        var _nx = _x * _scale;
        var _ny = _y * _scale;
        
        // Use open_simplex_noise if available
        var _noise = open_simplex_noise(_nx, _ny, 1.0, max(1, _octaves));
        
        set_output_value("value", _noise);
    }
}

/// @desc Simplex noise 3D generator
function LoomNodeSimplexNoise3D() : LoomNode("SimplexNoise3D") constructor
{
    display_name = "Simplex Noise 3D";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_input("z", "value", 0);
    add_input("scale", "value", 0.02);
    add_input("octaves", "value", 1);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _z = get_input_value("z", _context);
        var _scale = get_input_value("scale", _context);
        var _octaves = floor(get_input_value("octaves", _context));
        
        var _nx = _x * _scale;
        var _ny = _y * _scale;
        var _nz = _z * _scale; // Z usually doesn't need scale scaling if handled externally? 
        // But for consistency: SimplexNoise3D(x,y,z) usually means noise at that coord.
        // TerrainShaper does: open_simplex_noise_3d(_x*_scale, _squashed_y*_scale, _z + seed...)
        // So scaling inside node is consistent.
        
        var _noise = open_simplex_noise_3d(_nx, _ny, _nz, 1.0, max(1, _octaves));
        
        set_output_value("value", _noise);
    }
}

// --- Terrain Shaper Components (High Level) ---

/// @desc Height Gradient: (y - base) * strength
function LoomNodeTerrainGradient() : LoomNode("TerrainGradient") constructor
{
    display_name = "Terrain Gradient";
    add_input("y", "value", 0);
    add_input("base", "value", 400);
    add_input("strength", "value", 0.006);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _y = get_input_value("y", _context);
        var _base = get_input_value("base", _context);
        var _str = get_input_value("strength", _context);
        set_output_value("value", (_y - _base) * _str);
    }
}

/// @desc Continentalness: Simplex(x) * amp * grad_strength
function LoomNodeContinentalness() : LoomNode("Continentalness") constructor
{
    display_name = "Continentalness";
    add_input("x", "value", 0);
    add_input("scale", "value", 0.0015);
    add_input("amp", "value", 180);
    add_input("grad_str", "value", 0.006);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _scale = get_input_value("scale", _context);
        var _amp = get_input_value("amp", _context);
        var _gstr = get_input_value("grad_str", _context);
        var _seed = _context.seed;
        
        var _noise = open_simplex_noise(_x * _scale, _seed * 7.3, 1.0, 2);
        set_output_value("value", _noise * _amp * _gstr);
    }
}

/// @desc Peaks: Simplex(x) * amp * grad_strength
function LoomNodePeaks() : LoomNode("Peaks") constructor
{
    display_name = "Peaks";
    add_input("x", "value", 0);
    add_input("scale", "value", 0.04);
    add_input("amp", "value", 100);
    add_input("grad_str", "value", 0.006);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _scale = get_input_value("scale", _context);
        var _amp = get_input_value("amp", _context);
        var _gstr = get_input_value("grad_str", _context);
        var _seed = _context.seed;
        
        var _noise = open_simplex_noise(_x * _scale, _seed * 13.7, 1.0, 3);
        set_output_value("value", _noise * _amp * _gstr);
    }
}

/// @desc Squashed 3D Noise
function LoomNodeSquashedNoise() : LoomNode("SquashedNoise") constructor
{
    display_name = "Squashed Noise";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_input("z", "value", 0);
    add_input("squash", "value", 4.0);
    add_input("scale", "value", 0.015);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _z = get_input_value("z", _context);
        var _sq = get_input_value("squash", _context);
        var _sc = get_input_value("scale", _context);
        var _seed = _context.seed;
        
        var _val = open_simplex_noise_3d(_x * _sc, (_y * _sq) * _sc, _z + (_seed * 0.0001), 1.0, 3);
        set_output_value("value", _val);
    }
}

/// @desc Erosion Noise
function LoomNodeErosion() : LoomNode("Erosion") constructor
{
    display_name = "Erosion";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_input("scale", "value", 0.015); // Match WorldData getter
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _sc = get_input_value("scale", _context);
        var _seed = _context.seed;
        
        var _val = open_simplex_noise(_x * _sc, _y * _sc + 500, 1.0, 2);
        set_output_value("value", _val);
    }
}

/// @desc Final Terrain Combine
function LoomNodeTerrainCombine() : LoomNode("TerrainCombine") constructor
{
    display_name = "Terrain Combine";
    add_input("gradient", "value", 0);
    add_input("noise3d", "value", 0);
    add_input("erosion", "value", 0);
    add_input("weight_noise", "value", 1.8);
    add_input("weight_erosion", "value", 0.8);
    add_input("offset", "value", -0.05);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _grad = get_input_value("gradient", _context);
        var _n3d = get_input_value("noise3d", _context);
        var _ero = get_input_value("erosion", _context);
        var _wn = get_input_value("weight_noise", _context);
        var _we = get_input_value("weight_erosion", _context);
        var _off = get_input_value("offset", _context);
        
        var _res = _grad + (_n3d * (_wn + _ero * _we)) + _off;
        set_output_value("value", _res);
    }
}

// --- Cave System Nodes ---

/// @desc Swiss Cheese Caves (Combines two 2D noises)
function LoomNodeCaveSwiss() : LoomNode("CaveSwiss") constructor
{
    display_name = "Cave Swiss";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_input("scale", "value", 0.03);
    add_input("squash", "value", 4.0);
    add_input("threshold", "value", 0.6);
    add_input("strength", "value", 100.0);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _sc = get_input_value("scale", _context);
        var _sq = get_input_value("squash", _context);
        var _th = get_input_value("threshold", _context);
        var _st = get_input_value("strength", _context);
        var _seed = _context.seed;
        
        var _sy = _y * _sq;
        var _n1 = open_simplex_noise(_x * _sc, _sy * _sc + (_seed * 1.3), 1.0, 2);
        var _n2 = open_simplex_noise(_x * _sc * 2 + 500, _sy * _sc * 2 + (_seed * 1.7), 1.0, 2);
        var _combined = (_n1 * _n1 + _n2 * _n2);
        
        var _res = (_combined > _th) ? _st : 0;
        set_output_value("value", _res);
    }
}

/// @desc Noodle Caves (Tubular tunnels)
function LoomNodeCaveNoodle() : LoomNode("CaveNoodle") constructor
{
    display_name = "Cave Noodle";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_input("scale", "value", 0.015625);
    add_input("squash", "value", 4.0);
    add_input("range_min", "value", 50);
    add_input("range_max", "value", 70);
    add_input("octaves", "value", 4);
    add_input("depth_factor", "value", 1.0);
    add_input("strength", "value", 100.0);
    add_input("index", "value", 0); // Offset for multiple tubes
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _sc = get_input_value("scale", _context);
        var _sq = get_input_value("squash", _context);
        var _rmin = get_input_value("range_min", _context);
        var _rmax = get_input_value("range_max", _context);
        var _oct = get_input_value("octaves", _context);
        var _dfac = get_input_value("depth_factor", _context);
        var _st = get_input_value("strength", _context);
        var _idx = get_input_value("index", _context);
        var _seed = _context.seed;
        
        var _sy = _y * _sq;
        var _noise = open_simplex_noise(_x * _sc, _sy * _sc + ((0xffff * (_idx + 1)) + (_seed * 100) + 8), 0xff, _oct);
        
        var _center = (_rmin + _rmax) / 2;
        var _half = ((_rmax - _rmin) / 2) * _dfac;
        var _smin = _center - _half;
        var _smax = _center + _half;
        
        var _res = (_noise >= _smin && _noise < _smax) ? _st : 0.0;
        set_output_value("value", _res);
    }
}

/// @desc Random value based on position
function LoomNodeRandom() : LoomNode("Random") constructor
{
    display_name = "Random";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_input("seed", "value", 0);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _seed = get_input_value("seed", _context);
        
        var _hash = _seed + (_x * 73856093) + (_y * 19349663);
        var _rand = frac(sin(_hash) * 43758.5453);
        
        set_output_value("value", _rand);
    }
}

// ============================================================================
// WORLD DATA NODES
// ============================================================================

/// @desc Get surface height at position
function LoomNodeGetSurfaceHeight() : LoomNode("GetSurfaceHeight") constructor
{
    display_name = "Surface Height";
    add_input("x", "value", 0);
    add_output("height", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _seed = _context[$ "seed"] ?? 0;
        var _world_data = _context[$ "world_data"];
        
        var _height = worldgen_get_surface_height(_x, _seed, _world_data);
        set_output_value("height", _height);
    }
}

/// @desc Get biome at position
function LoomNodeGetBiome() : LoomNode("GetBiome") constructor
{
    display_name = "Get Biome";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_output("biome_id", "value");
    add_output("biome", "struct");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _seed = _context[$ "seed"] ?? 0;
        var _world_data = _context[$ "world_data"];
        
        // Get surface or cave biome based on Y position
        var _surface_height = worldgen_get_surface_height(_x, _seed, _world_data);
        var _biome_id = undefined;
        
        if (_y < _surface_height + 5)
        {
            _biome_id = worldgen_get_biome_surface(_x, _seed, _world_data);
        }
        else
        {
            _biome_id = worldgen_get_biome_cave(_x, _y, _seed, _world_data);
        }
        
        set_output_value("biome_id", _biome_id);
        set_output_value("biome", global.biome_data[$ _biome_id]);
    }
}

/// @desc Get terrain density at position (from TerrainGenerator)
function LoomNodeGetDensity() : LoomNode("GetDensity") constructor
{
    display_name = "Terrain Density";
    add_input("x", "value", 0);
    add_input("y", "value", 0);
    add_output("density", "value");
    add_output("is_solid", "bool");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _seed = _context[$ "seed"] ?? 0;
        
        var _density = 0;
        if (global.terrain_shaper != undefined)
        {
            _density = global.terrain_shaper.get_density_solid(_x, _y, _seed);
        }
        
        set_output_value("density", _density);
        set_output_value("is_solid", _density >= 0);
    }
}

// ============================================================================
// LOGIC NODES
// ============================================================================

/// @desc Compare two values
function LoomNodeCompare() : LoomNode("Compare") constructor
{
    display_name = "Compare";
    add_input("a", "value", 0);
    add_input("b", "value", 0);
    add_output("equal", "bool");
    add_output("greater", "bool");
    add_output("less", "bool");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("equal", _a == _b);
        set_output_value("greater", _a > _b);
        set_output_value("less", _a < _b);
    }
}

/// @desc Boolean AND
function LoomNodeAnd() : LoomNode("And") constructor
{
    display_name = "AND";
    add_input("a", "bool", true);
    add_input("b", "bool", true);
    add_output("result", "bool");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("result", _a && _b);
    }
}

/// @desc Boolean OR
function LoomNodeOr() : LoomNode("Or") constructor
{
    display_name = "OR";
    add_input("a", "bool", false);
    add_input("b", "bool", false);
    add_output("result", "bool");
    
    static process = function(_context)
    {
        var _a = get_input_value("a", _context);
        var _b = get_input_value("b", _context);
        set_output_value("result", _a || _b);
    }
}

/// @desc Boolean NOT
function LoomNodeNot() : LoomNode("Not") constructor
{
    display_name = "NOT";
    add_input("value", "bool", false);
    add_output("result", "bool");
    
    static process = function(_context)
    {
        var _val = get_input_value("value", _context);
        set_output_value("result", !_val);
    }
}

// ============================================================================
// OUTPUT NODES
// ============================================================================

/// @desc Generic result output node
function LoomNodeResult() : LoomNode("Result") constructor
{
    display_name = "Result";
    add_input("value", "any", undefined);
    add_output("value", "any");
    
    static process = function(_context)
    {
        var _val = get_input_value("value", _context);
        set_output_value("value", _val);
    }
}

// ============================================================================
// DATA PRIMITIVE NODES
// ============================================================================

/// @desc Color output node with inline color swatch
function LoomNodeColor() : LoomNode("Color") constructor
{
    display_name = "Color";
    add_attribute("color", "color", c_white);
    add_output("color", "color");
    
    static process = function(_context)
    {
        set_output_value("color", get_attribute("color"));
    }
}

/// @desc String output node with inline text editing
function LoomNodeString() : LoomNode("String") constructor
{
    display_name = "String";
    add_attribute("text", "string", "");
    add_output("text", "string");
    
    static process = function(_context)
    {
        set_output_value("text", get_attribute("text"));
    }
}

// ============================================================================
// WORLD CONFIGURATION NODES
// ============================================================================

/// @desc Root world settings node
function LoomNodeWorldSettings() : LoomNode("WorldSettings") constructor
{
    display_name = "World Settings";
    width = 160;
    add_attribute("world_height", "value", 1024);
    add_attribute("spawn_interval", "value", 14);
    add_input("time", "struct", undefined);
    add_input("vignette", "struct", undefined);
    add_input("surface", "struct", undefined);
    add_input("cave", "struct", undefined);
    add_input("biome", "struct", undefined);
    add_input("celestials", "struct", undefined);
    add_input("terrain_shaping", "struct", undefined);
    add_output("world_config", "struct");
    
    static process = function(_context)
    {
        var _config = {
            world_height: get_attribute("world_height"),
            spawn_interval: get_attribute("spawn_interval"),
            time: get_input_value("time", _context),
            vignette: get_input_value("vignette", _context),
            surface: get_input_value("surface", _context),
            cave: get_input_value("cave", _context),
            biome: get_input_value("biome", _context),
            celestials: get_input_value("celestials", _context),
            terrain_shaping: get_input_value("terrain_shaping", _context)
        };
        set_output_value("world_config", _config);
    }
}

/// @desc Time settings node
function LoomNodeTimeSettings() : LoomNode("TimeSettings") constructor
{
    display_name = "Time Settings";
    width = 140;
    add_attribute("start", "value", 240);
    add_attribute("length", "value", 1200);
    add_output("time", "struct");
    
    static process = function(_context)
    {
        var _time = {
            start: get_attribute("start"),
            length: get_attribute("length"),
            diurnal: [
                { id: "dawn", time_range_min: 0, time_range_max: 240 },
                { id: "day", time_range_min: 240, time_range_max: 820 },
                { id: "dusk", time_range_min: 820, time_range_max: 890 },
                { id: "night", time_range_min: 890, time_range_max: 1200 }
            ]
        };
        set_output_value("time", _time);
    }
}

/// @desc Vignette settings node
function LoomNodeVignetteSettings() : LoomNode("VignetteSettings") constructor
{
    display_name = "Vignette";
    width = 140;
    add_attribute("ystart", "value", 768);
    add_attribute("yend", "value", 1024);
    add_attribute("colour", "color", c_black);
    add_output("vignette", "struct");
    
    static process = function(_context)
    {
        var _vig = {
            ystart: get_attribute("ystart"),
            yend: get_attribute("yend"),
            colour: get_attribute("colour")
        };
        set_output_value("vignette", _vig);
    }
}

/// @desc Sky settings node
function LoomNodeSkySettings() : LoomNode("SkySettings") constructor
{
    display_name = "Sky Settings";
    width = 160;
    add_attribute("enabled", "bool", true);
    add_attribute("threshold", "value", 256);
    add_attribute("spacing", "value", 32);
    add_attribute("radius", "value", 18);
    add_attribute("thickness", "value", 10);
    add_output("sky", "struct");
    
    static process = function(_context)
    {
        var _sky = {
            enabled: get_attribute("enabled"),
            id: "phantasia:sky/floating_islands",
            threshold: get_attribute("threshold"),
            spacing: get_attribute("spacing"),
            radius: get_attribute("radius"),
            thickness: get_attribute("thickness"),
            noise_scale_region: 0.12,
            noise_scale_edge: 0.15,
            noise_scale_detail: 0.3
        };
        set_output_value("sky", _sky);
    }
}

/// @desc Celestial body node (sun/moon)
function LoomNodeCelestialBody() : LoomNode("CelestialBody") constructor
{
    display_name = "Celestial Body";
    width = 160;
    add_attribute("id", "string", "phantasia:world/playground/celestial/sun");
    add_attribute("time_min", "value", 0);
    add_attribute("time_max", "value", 890);
    add_output("celestial", "struct");
    
    static process = function(_context)
    {
        var _cel = {
            id: get_attribute("id"),
            time_range_min: get_attribute("time_min"),
            time_range_max: get_attribute("time_max")
        };
        set_output_value("celestial", _cel);
    }
}

/// @desc Surface settings node
function LoomNodeSurfaceSettings() : LoomNode("SurfaceSettings") constructor
{
    display_name = "Surface";
    width = 160;
    add_attribute("start", "value", 512);
    add_attribute("noise_scale", "value", 0.015625);
    add_attribute("min_depth", "value", 8);
    add_attribute("bedrock_depth", "value", 3);
    add_output("surface", "struct");
    
    static process = function(_context)
    {
        var _surf = {
            start: get_attribute("start"),
            noise_offset: { octaves: 4, min: 40, max: 96 },
            smoothing: { range: 32, factor: 0.6 },
            noise_scale: get_attribute("noise_scale"),
            seed_offset: -40,
            min_depth: get_attribute("min_depth"),
            bedrock_depth: get_attribute("bedrock_depth"),
            bedrock_noise_scale: 0.3,
            tile_variation_noise_scale: 0.05,
            biome_blend_range: 24,
            biome_blend_noise_scale: 0.08
        };
        set_output_value("surface", _surf);
    }
}

/// @desc Cave settings node
function LoomNodeCaveSettings() : LoomNode("CaveSettings") constructor
{
    display_name = "Cave Settings";
    width = 160;
    add_attribute("noise_scale", "value", 0.015625);
    add_attribute("breach_thresh", "value", 242);
    add_attribute("breach_depth", "value", -8);
    add_input("aquifers", "struct", undefined);
    add_output("cave", "struct");
    
    static process = function(_context)
    {
        var _cave = {
            start: { octaves: 0, min: 12, max: 2 },
            system: [
                { range_min: 50, range_max: 70, threshold: { octaves: 4 } },
                { range_min: 116, range_max: 140, threshold: { octaves: 4 } }
            ],
            aquifers: get_input_value("aquifers", _context) ?? [],
            noise_scale: get_attribute("noise_scale"),
            breach_threshold: get_attribute("breach_thresh"),
            breach_depth: get_attribute("breach_depth")
        };
        set_output_value("cave", _cave);
    }
}

/// @desc Aquifer node (water/lava pockets)
function LoomNodeAquifer() : LoomNode("Aquifer") constructor
{
    display_name = "Aquifer";
    width = 160;
    add_attribute("type", "string", "phantasia:water");
    add_attribute("depth_min", "value", 20);
    add_attribute("depth_max", "value", 200);
    add_attribute("threshold", "value", 200);
    add_attribute("fill_level", "value", 8);
    add_output("aquifer", "struct");
    
    static process = function(_context)
    {
        var _aq = {
            type: get_attribute("type"),
            depth_min: get_attribute("depth_min"),
            depth_max: get_attribute("depth_max"),
            threshold: get_attribute("threshold"),
            octaves: 3,
            fill_level: get_attribute("fill_level"),
            noise_scale: 0.02,
            range: 255,
            edge_tile: "phantasia:stone",
            edge_width: 15
        };
        set_output_value("aquifer", _aq);
    }
}

/// @desc Biome definition node
function LoomNodeBiomeDefinition() : LoomNode("BiomeDefinition") constructor
{
    display_name = "Biome";
    width = 160;
    add_attribute("id", "string", "phantasia:cave/depths");
    add_attribute("start", "value", 768);
    add_attribute("end", "value", 1024);
    add_output("biome", "struct");
    
    static process = function(_context)
    {
        var _biome = {
            id: get_attribute("id"),
            start: get_attribute("start"),
            "end": get_attribute("end"),
            transition: { type: "random", octaves: 4, min: 2, max: 22 }
        };
        set_output_value("biome", _biome);
    }
}

/// @desc Noise configuration helper node
function LoomNodeNoiseConfig() : LoomNode("NoiseConfig") constructor
{
    display_name = "Noise Config";
    width = 140;
    add_attribute("scale", "value", 0.02);
    add_attribute("octaves", "value", 4);
    add_output("noise", "struct");
    
    static process = function(_context)
    {
        var _noise = {
            scale: get_attribute("scale"),
            octaves: get_attribute("octaves")
        };
        set_output_value("noise", _noise);
    }
}

/// @desc Terrain shaping configuration
function LoomNodeTerrainShaping() : LoomNode("TerrainShaping") constructor
{
    display_name = "Terrain Shaping";
    width = 160;
    add_attribute("noise_scale_3d", "value", 0.015);
    add_attribute("squash_factor", "value", 4.0);
    add_attribute("z_offset_wall", "value", 0.075);
    add_output("terrain_shaping", "struct");
    
    static process = function(_context)
    {
        var _ts = {
            noise_scale_3d: get_attribute("noise_scale_3d"),
            squash_factor: get_attribute("squash_factor"),
            z_offset_wall: get_attribute("z_offset_wall")
        };
        set_output_value("terrain_shaping", _ts);
    }
}

/// @desc Dynamic array collector node - adds inputs when connected
function LoomNodeArrayCollector() : LoomNode("ArrayCollector") constructor
{
    display_name = "Array";
    input_count = 1;
    add_input("item_0", "any", undefined);
    add_input("+ Add", "any", undefined); // Special "add" slot
    add_output("array", "struct");
    
    /// @desc Called when a connection is made to this node
    static on_connect = function(_pin_name)
    {
        if (_pin_name == "+ Add")
        {
            // Rename current add slot to item_N
            var _new_name = "item_" + string(input_count);
            var _pin = inputs[$ "+ Add"];
            
            // Update pin name and input mappings
            _pin.name = _new_name;
            variable_struct_remove(inputs, "+ Add");
            inputs[$ _new_name] = _pin;
            
            for (var i = 0; i < array_length(input_order); ++i)
            {
                if (input_order[i] == "+ Add")
                {
                    input_order[i] = _new_name;
                    break;
                }
            }
            
            // Add new "+ Add" pin
            add_input("+ Add", "any", undefined);
            input_count++;
            ___recalculate_size();
        }
    }
    
    /// @desc Called when a connection is removed from this node
    static on_disconnect = function(_pin_name)
    {
        // Don't shrink if it's the add slot or we only have 1 item
        if (_pin_name == "+ Add" || input_count <= 1) return;
        
        // Find the index of the disconnected pin
        var _idx = -1;
        if (string_copy(_pin_name, 1, 5) == "item_")
        {
            _idx = real(string_copy(_pin_name, 6, string_length(_pin_name) - 5));
        }
        
        // If it's the last item (just before "+ Add"), and it's disconnected,
        // we can potentially remove it if it's not the ONLY one.
        // Actually, let's only remove it if it's the last one AND input_count > 1
        if (_idx == input_count - 1 && input_count > 1)
        {
            // Remove last item and move "+ Add" up
            variable_struct_remove(inputs, _pin_name);
            for (var i = 0; i < array_length(input_order); ++i)
            {
                if (input_order[i] == _pin_name)
                {
                    array_delete(input_order, i, 1);
                    break;
                }
            }
            input_count--;
            ___recalculate_size();
        }
    }
    
    static process = function(_context)
    {
        var _arr = [];
        for (var i = 0; i < input_count; ++i)
        {
            var _val = get_input_value("item_" + string(i), _context);
            if (_val != undefined) array_push(_arr, _val);
        }
        set_output_value("array", _arr);
    }
}

/// @desc Spline builder node - creates spline point data
function LoomNodeSplineBuilder() : LoomNode("SplineBuilder") constructor
{
    display_name = "Spline";
    width = 160;
    
    // Default points (linear from 0 to 1)
    spline_points = [
        { position: 0, value: 0, easing: "linear" },
        { position: 1024, value: 1, easing: "linear" }
    ];
    
    add_attribute("point_count", "value", 2);
    add_output("spline", "spline");
    
    /// @desc Add a point to the spline
    static add_point = function(_pos, _val, _easing = "linear")
    {
        array_push(spline_points, { position: _pos, value: _val, easing: _easing });
        set_attribute("point_count", array_length(spline_points));
        return self;
    }
    
    /// @desc Set point at index
    static set_point = function(_idx, _pos, _val, _easing = "linear")
    {
        if (_idx >= 0 && _idx < array_length(spline_points))
        {
            spline_points[_idx] = { position: _pos, value: _val, easing: _easing };
        }
        return self;
    }
    
    static process = function(_context)
    {
        var _spline = {
            type: "spline",
            points: spline_points
        };
        set_output_value("spline", _spline);
    }
}

// ============================================================================
// NODE REGISTRY
// ============================================================================

/// @desc Global registry of available node types
global.loom_node_registry = {
    // Math
    "Constant": LoomNodeConstant,
    "Add": LoomNodeAdd,
    "Subtract": LoomNodeSubtract,
    "Multiply": LoomNodeMultiply,
    "Divide": LoomNodeDivide,
    "Clamp": LoomNodeClamp,
    "Lerp": LoomNodeLerp,
    "Abs": LoomNodeAbs,
    "Max": LoomNodeMax,
    "Min": LoomNodeMin,
    
    // Input
    "Coordinate": LoomNodeInputCoordinate,
    "Seed": LoomNodeInputSeed,
    "World Data": LoomNodeInputWorldData,
    
    // Data Primitives
    "Color": LoomNodeColor,
    "String": LoomNodeString,
    "Array": LoomNodeArrayCollector,
    "Spline": LoomNodeSplineBuilder,
    
    // Generators
    "Simplex Noise": LoomNodeSimplexNoise,
    "Simplex Noise 3D": LoomNodeSimplexNoise3D,
    "Random": LoomNodeRandom,
    "Noise Config": LoomNodeNoiseConfig,
    
    // Terrain
    "Terrain Gradient": LoomNodeTerrainGradient,
    "Continentalness": LoomNodeContinentalness,
    "Peaks": LoomNodePeaks,
    "Squashed Noise": LoomNodeSquashedNoise,
    "Erosion": LoomNodeErosion,
    "Terrain Combine": LoomNodeTerrainCombine,
    "Terrain Shaping": LoomNodeTerrainShaping,
    
    // Cave
    "Cave Swiss": LoomNodeCaveSwiss,
    "Cave Noodle": LoomNodeCaveNoodle,
    "Cave Settings": LoomNodeCaveSettings,
    "Aquifer": LoomNodeAquifer,
    
    // World Config
    "World Settings": LoomNodeWorldSettings,
    "Time Settings": LoomNodeTimeSettings,
    "Vignette": LoomNodeVignetteSettings,
    "Sky Settings": LoomNodeSkySettings,
    "Celestial Body": LoomNodeCelestialBody,
    "Surface Settings": LoomNodeSurfaceSettings,
    "Biome": LoomNodeBiomeDefinition,
    
    // World Data
    "Surface Height": LoomNodeGetSurfaceHeight,
    "Get Biome": LoomNodeGetBiome,
    "Terrain Density": LoomNodeGetDensity,
    
    // Logic
    "Compare": LoomNodeCompare,
    "AND": LoomNodeAnd,
    "OR": LoomNodeOr,
    "NOT": LoomNodeNot,
    
    // Output
    "Result": LoomNodeResult
};

/// @desc Create a node by type name
/// @param {String} _type Node type name
/// @returns {Struct.LoomNode} New node instance
function loom_create_node(_type)
{
    var _constructor = global.loom_node_registry[$ _type];
    if (_constructor == undefined)
    {
        show_debug_message("loom_create_node: Unknown node type: " + _type);
        return undefined;
    }
    return new _constructor();
}
