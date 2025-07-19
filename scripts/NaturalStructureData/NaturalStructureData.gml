global.natural_structure_data = {}

function NaturalStructureData() constructor
{
    static set_parser = function(_parser)
    {
        ___parser = _parser;
        
        return self;
    }
    
    static get_parser = function()
    {
        return ___parser;
    }
    
    static set_function = function(_function)
    {
        ___function = _function;
        
        return self;
    }
    
    static get_function = function()
    {
        return ___function;
    }
}

enum NATURAL_STRUCTURE_CLUMP {
    USE_TILE_STRUCTURE_VOID,
    TILE_BASE,
    TILE_WALL,
    LENGTH
}

global.natural_structure_data[$ "phantasia:clump"] = new NaturalStructureData()
    .set_parser(function(_parameter)
    {
        var _data = array_create(NATURAL_STRUCTURE_CLUMP.LENGTH);
        
        _data[@ NATURAL_STRUCTURE_CLUMP.USE_TILE_STRUCTURE_VOID] = _parameter[$ "use_structure_void"] ?? true;
        
        _data[@ NATURAL_STRUCTURE_CLUMP.TILE_BASE] = _parameter.tile_base;
        _data[@ NATURAL_STRUCTURE_CLUMP.TILE_WALL] = _parameter.tile_wall;
        
        return _data;
    })
    .set_function(function(_x, _y, _width, _height, _seed, _parameter, _item_data)
    {
        var _rectangle = _width * _height;
        var _data = array_create(_rectangle * CHUNK_DEPTH, (_parameter[NATURAL_STRUCTURE_CLUMP.USE_TILE_STRUCTURE_VOID] ? TILE_STRUCTURE_VOID : TILE_EMPTY));
        
        var _width_last  = _width  - 1;
        var _height_last = _height - 1;
        
        var _depth_base = _rectangle * CHUNK_DEPTH_DEFAULT;
        var _depth_wall = _rectangle * CHUNK_DEPTH_WALL;
        
        var _tile_wall = _parameter[NATURAL_STRUCTURE_CLUMP.TILE_WALL];
        var _tile_wall_id = _tile_wall.id;
        
        for (var i = 0; i < _width; ++i)
        {
            var _is_edge_x = (i == 0) || (i == _width_last);
            
            for (var j = 0; j < _height; ++j)
            {
                var _is_edge_y = (j == 0) || (j == _height_last);
                
                if (_is_edge_x) && (_is_edge_y) continue;
                
                _data[@ i + (j * _width) + _depth_wall] = new Tile(_tile_wall_id, _item_data);
            }
        }
        
        var _tile_base = _parameter[NATURAL_STRUCTURE_CLUMP.TILE_BASE];
        var _tile_base_id = _tile_base.id;
        
        _data[@ 2 + (2 * 5) + _depth_base] = new Tile(_tile_base_id, _item_data);
        
        var _has_side = false;
        
        var _xorshift = xorshift(round(_seed / 0x8fb9) - ((_x * 1_143) + (_y * 3_209)));
        
        if (_xorshift & 0b001)
        {
            _data[@ 1 + (2 * 5) + _depth_base] = new Tile(_tile_base_id, _item_data);
            
            _has_side += 1;
        }
        
        if (_xorshift & 0b010)
        {
            _data[@ 3 + (2 * 5) + _depth_base] = new Tile(_tile_base_id, _item_data);
            
            _has_side += 1;
        }
        
        if (_has_side == 2) || ((_has_side == 1) && (_xorshift & 0b100))
        {
            _data[@ 2 + (1 * 5) + _depth_base] = new Tile(_tile_base_id, _item_data);
        }
        
        return _data;
    });

enum NATURAL_STRUCTURE_ORE {
    USE_TILE_STRUCTURE_VOID,
    TILE,
    LENGTH
}

global.natural_structure_data[$ "phantasia:ore"] = new NaturalStructureData()
    .set_parser(function(_parameter)
    {
        var _data = array_create(NATURAL_STRUCTURE_ORE.LENGTH);
        
        _data[@ NATURAL_STRUCTURE_ORE.USE_TILE_STRUCTURE_VOID] = _parameter[$ "use_structure_void"] ?? true;
        
        _data[@ NATURAL_STRUCTURE_ORE.TILE] = _parameter.tile;
        
        return _data;
    })
    .set_function(function(_x, _y, _width, _height, _seed, _parameter, _item_data)
    {
        static __cave = [];
        
        var _rectangle = _width * _height;
        var _data = array_create(_rectangle * CHUNK_DEPTH, (_parameter[NATURAL_STRUCTURE_ORE.USE_TILE_STRUCTURE_VOID] ? TILE_STRUCTURE_VOID : TILE_EMPTY));
        
        for (var i = 0; i < _width; ++i)
        {
            __cave[@ i] = 0;
            
            var _surface_height = worldgen_get_surface_height(_x + i, _seed);
            
            for (var j = 0; j < _height; ++j)
            {
                if (worldgen_get_cave(_x + i, _y + j, _surface_height, _seed))
                {
                    __cave[@ i] |= 1 << j;
                }
            }
        }
        
        var _depth = _rectangle * CHUNK_DEPTH_DEFAULT;
        
        var _tile = _parameter[NATURAL_STRUCTURE_ORE.TILE];
        var _tile_id = _tile.id;
        
        for (var i = 0; i < _width; ++i)
        {
            var _cave = __cave[i];
            
            for (var j = 0; j < _height; ++j)
            {
                if (_cave & (1 << j)) continue;
                
                _data[@ i + (j * _width) + _depth] = new Tile(_tile_id, _item_data);
            }
        }
        
        return _data;
    });

enum NATURAL_STRUCTURE_TREE_GENERIC {
    USE_STRUCTURE_VOID,
    TILE_WOOD,
    TILE_LEAVES,
    INDEX,
    INDEX_TOP,
    INDEX_BOTTOM,
    LENGTH
}

global.natural_structure_data[$ "phantasia:tree/generic"] = new NaturalStructureData()
    .set_parser(function(_parameter)
    {
        var _item_data = global.item_data;
        
        var _data = array_create(NATURAL_STRUCTURE_TREE_GENERIC.LENGTH);
        
        _data[@ NATURAL_STRUCTURE_TREE_GENERIC.USE_STRUCTURE_VOID] = _parameter[$ "use_structure_void"] ?? true;
        
        _data[@ NATURAL_STRUCTURE_TREE_GENERIC.TILE_WOOD]   = _parameter.tile_wood;
        _data[@ NATURAL_STRUCTURE_TREE_GENERIC.TILE_LEAVES] = _parameter.tile_leaves;
        
        var _index = _parameter.index;
        
        _data[@ NATURAL_STRUCTURE_TREE_GENERIC.INDEX] = smart_value_parse(_index);
        
        _data[@ NATURAL_STRUCTURE_TREE_GENERIC.INDEX_TOP]    = smart_value_parse(_parameter[$ "index_top"])    ?? _index;
        _data[@ NATURAL_STRUCTURE_TREE_GENERIC.INDEX_BOTTOM] = smart_value_parse(_parameter[$ "index_bottom"]) ?? _index;
        
        return _data;
    })
    .set_function(function(_x, _y, _width, _height, _seed, _parameter, _item_data)
    {
        var _rectangle = _width * _height;
        var _data = array_create(_rectangle * CHUNK_DEPTH, (_parameter[NATURAL_STRUCTURE_TREE_GENERIC.USE_STRUCTURE_VOID] ? TILE_STRUCTURE_VOID : TILE_EMPTY));
        
        var _width_half = floor(_width / 2);
        
        var _depth_wood   = _rectangle * CHUNK_DEPTH_TREE;
        var _depth_leaves = _depth_wood + _rectangle;
        
        var _tile_leaves = _parameter[NATURAL_STRUCTURE_TREE_GENERIC.TILE_LEAVES];
        
        var _tile_leaves_id = _tile_leaves.id;
        
        for (var i = 1; i < _width - 1; ++i)
        {
            _data[@ i + _depth_leaves] = new Tile(_tile_leaves_id, _item_data);
            _data[@ i + (1 * _width) + _depth_leaves] = new Tile(_tile_leaves_id, _item_data)
                .set_yscale(1)
                .set_index_offset(5);
        }
        
        for (var i = 0; i < _width; ++i)
        {
            _data[@ i + (2 * _width) + _depth_leaves] = new Tile(_tile_leaves_id, _item_data);
            _data[@ i + (3 * _width) + _depth_leaves] = new Tile(_tile_leaves_id, _item_data)
                .set_yscale(1)
                .set_index_offset(5);
        }
        
        var _tile_wood = _parameter[NATURAL_STRUCTURE_TREE_GENERIC.TILE_WOOD];
        
        var _tile_wood_id = _tile_wood.id;
        var _tile_wood_variant = _tile_wood[$ "variant"];
        
        var _index = _parameter[NATURAL_STRUCTURE_TREE_GENERIC.INDEX];
        
        var _index_top    = _parameter[NATURAL_STRUCTURE_TREE_GENERIC.INDEX_TOP];
        var _index_bottom = _parameter[NATURAL_STRUCTURE_TREE_GENERIC.INDEX_BOTTOM];
        
        for (var i = 0; i < _height; ++i)
        {
            if (i == 0)
            {
                _data[@ _width_half + (i * _width) + _depth_wood] = new Tile(_tile_wood_id, _item_data)
                    .set_index(smart_value(_index_top));
            }
            else if (i == _height - 1)
            {
                _data[@ _width_half + (i * _width) + _depth_wood] = new Tile(_tile_wood_id, _item_data)
                    .set_index(smart_value(_index_bottom));
            }
            else
            {
                _data[@ _width_half + (i * _width) + _depth_wood] = new Tile(_tile_wood_id, _item_data)
                    .set_index(smart_value(_index));
            }
        }
        
        return _data;
    });