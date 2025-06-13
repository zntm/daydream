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
        
        _data[@ NATURAL_STRUCTURE_CLUMP.USE_TILE_STRUCTURE_VOID] = _parameter[$ "use_TILE_STRUCTURE_VOID"] ?? true;
        
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
        var _tile_wall_variant = _tile_wall[$ "variant"];
        
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
        
        var _xorshift = xorshift(_seed - ((_x + _y) * 8));
        
        if (_xorshift & 0b1)
        {
            _data[@ 1 + (2 * 5) + _depth_base] = new Tile(_tile_base_id, _item_data);
            
            _has_side += 1;
        }
        
        if (_xorshift & 0b01)
        {
            _data[@ 3 + (2 * 5) + _depth_base] = new Tile(_tile_base_id, _item_data);
            
            _has_side += 1;
        }
        
        if (_has_side == 2) || ((_has_side == 1) && (_xorshift & 0b001))
        {
            _data[@ 2 + (1 * 5) + _depth_base] = new Tile(_tile_base_id, _item_data);
        }
        
        return _data;
    });