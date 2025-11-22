import { DatagenReturnData } from "../../lib/DatagenReturnData";
import { Item } from "./lib/Item";
import { ItemType } from "./lib/ItemType";
import type { ItemTileCondition, ItemTileDrop, ItemTileHarvest, ItemTileParticle, ItemTileProperties } from "./tileItem";

const { default: tileItem, ItemTileCondition: ItemTileConditionClass, ItemTileDrop: ItemTileDropClass, ItemTileHarvest: ItemTileHarvestClass, ItemTileParticle: ItemTileParticleClass, ItemTileProperties: ItemTilePropertiesEnum } = import.meta.require("./tileItem");

export default [
    new DatagenReturnData(
        "generated/data/items/feather.json",
        new Item(
            ItemType.Default,
            "phantasia:item/feather",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    tileItem(
        "sand",
        ItemType.Solid,
        "#phantasia:item/generic/inventory_default",
        [ItemTilePropertiesEnum.CanFlip, ItemTilePropertiesEnum.CanMirror, ItemTilePropertiesEnum.IsTile],
        [
            new ItemTileDropClass(`phantasia:sand`).setCondition(
                new ItemTileConditionClass(
                    "#phantasia:item/type/shovel",
                    0,
                ),
            ),
        ],
        new ItemTileHarvestClass(
            0.36,
            0,
            new ItemTileParticleClass(
                "#phantasia:tile/particle_colour/sand",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        undefined,
        "#phantasia:tile/sfx/sand",
    ),
];
