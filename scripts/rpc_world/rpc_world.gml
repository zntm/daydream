function rpc_world(_x, _y)
{
    var _world = global.world;
    
    var _id = bg_get_biome(_x, _y);
    var _data = global.biome_data[$ _id];
    
    np_setpresence(loca_translate($"{_data.get_namespace()}:rpc.biome.{_data.get_id()}"));
}