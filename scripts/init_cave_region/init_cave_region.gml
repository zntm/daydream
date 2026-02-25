/// @desc Initialize special cave regions.
function init_cave_region()
{
    global.cave_region_data = [
        /* lumin — moonfall biome, very common for testing */
        new CaveRegionData("lumin", {
            biome: "phantasia:cave/moonfall",
            noise_scale: 0.008,
            noise_threshold: 0.4,
            min_depth: 20,
            salt: 0x7A3F
        })
    ];

    global.cave_region_data_length = array_length(global.cave_region_data);
}
