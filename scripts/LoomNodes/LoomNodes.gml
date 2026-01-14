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
    add_input("threshold", "value", 0.6);
    add_input("strength", "value", 100.0);
    add_output("value", "value");
    
    static process = function(_context)
    {
        var _x = get_input_value("x", _context);
        var _y = get_input_value("y", _context);
        var _sc = get_input_value("scale", _context);
        var _th = get_input_value("threshold", _context);
        var _st = get_input_value("strength", _context);
        var _seed = _context.seed;
        
        var _n1 = open_simplex_noise(_x * _sc, _y * _sc + (_seed * 1.3), 1.0, 2);
        var _n2 = open_simplex_noise(_x * _sc * 2 + 500, _y * _sc * 2 + (_seed * 1.7), 1.0, 2);
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
        var _rmin = get_input_value("range_min", _context);
        var _rmax = get_input_value("range_max", _context);
        var _oct = get_input_value("octaves", _context);
        var _dfac = get_input_value("depth_factor", _context);
        var _st = get_input_value("strength", _context);
        var _idx = get_input_value("index", _context);
        var _seed = _context.seed;
        
        var _noise = open_simplex_noise(_x * _sc, _y * _sc + ((0xffff * (_idx + 1)) + (_seed * 100) + 8), 0xff, _oct);
        
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
    
    // Input
    "Coordinate": LoomNodeInputCoordinate,
    "Seed": LoomNodeInputSeed,
    "World Data": LoomNodeInputWorldData,
    
    // Generators
    "Simplex Noise": LoomNodeSimplexNoise,
    "Simplex Noise 3D": LoomNodeSimplexNoise3D,
    "Random": LoomNodeRandom,
    
    // Terrain
    "Terrain Gradient": LoomNodeTerrainGradient,
    "Continentalness": LoomNodeContinentalness,
    "Peaks": LoomNodePeaks,
    "Squashed Noise": LoomNodeSquashedNoise,
    "Erosion": LoomNodeErosion,
    "Terrain Combine": LoomNodeTerrainCombine,
    
    // Cave
    "Cave Swiss": LoomNodeCaveSwiss,
    "Cave Noodle": LoomNodeCaveNoodle,
    
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
