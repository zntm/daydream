/// @desc Pool system for render state structs
global.render_state_pool = [];

function render_state_pool_init()
{
	global.render_state_pool = [];
}

function render_state_pool_acquire(_x, _y, _z, _data)
{
	var _pool = global.render_state_pool;
	
	if (array_length(_pool) > 0)
	{
		var _struct = array_pop(_pool);
		
		_struct.x = _x;
		_struct.y = _y;
		_struct.z = _z;
		_struct.data = _data;
		
		return _struct;
	}
	
	return {
		x: _x,
		y: _y,
		z: _z,
		data: _data
	};
}

function render_state_pool_release(_struct)
{
	array_push(global.render_state_pool, _struct);
}

function render_state_pool_clean(_array)
{
	var _length = array_length(_array);
	
	for (var i = 0; i < _length; ++i)
	{
		render_state_pool_release(_array[i]);
	}
	
	array_resize(_array, 0);
}
