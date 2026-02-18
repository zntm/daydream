for (var i = 0, n = array_length(surfaces); i < n; ++i)
{
	if (surface_exists(surfaces[i]))
	{
		surface_free(surfaces[i]);
	}
}

menu_create_world_cleanup();
