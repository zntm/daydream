function hash_code(_string)
{
	var _result = 0;
	var _length = string_length(_string);
	
	for (var i = 1; i <= _length; ++i)
	{
		_result = (_result * 31) + ord(string_char_at(_string, i));
	}
	
	return _result;
}