import { DatagenReturnData } from "../../../../lib";
import {
    BreastplateItem,
    HelmetItem,
    ItemAccessory,
    ItemAccessoryType,
    ItemDurability,
    LeggingsItem,
} from "../";

export class ArmorDataRegistry {
    defense: number;
    durability: number;

    constructor(defense: number, durability: number) {
        this.defense = defense;
        this.durability = durability;
    }
}

export default (
    namespace: string,
    id: string,
    armor: {
        helmet: ArmorDataRegistry;
        breastplate: ArmorDataRegistry;
        leggings: ArmorDataRegistry;
    },
) => [
        new DatagenReturnData(
            `${id}_helmet.json`,
            new HelmetItem(`${namespace}:${id}_helmet`)
                .setItemAccessory(new ItemAccessory(ItemAccessoryType.Helmet, armor.helmet.defense))
                .setItemDurability(
                    new ItemDurability(
                        armor.helmet.durability,
                        "#phantasia:item/generic/durability_bar",
                    ),
                ),
        ),
        new DatagenReturnData(
            `${id}_breastplate.json`,
            new BreastplateItem(`${namespace}:${id}_breastplate`)
                .setItemAccessory(
                    new ItemAccessory(ItemAccessoryType.Breastplate, armor.breastplate.defense),
                )
                .setItemDurability(
                    new ItemDurability(
                        armor.breastplate.durability,
                        "#phantasia:item/generic/durability_bar",
                    ),
                ),
        ),
        new DatagenReturnData(
            `${id}_leggings.json`,
            new LeggingsItem(`${namespace}:${id}_leggings`)
                .setItemAccessory(
                    new ItemAccessory(ItemAccessoryType.Leggings, armor.leggings.defense),
                )
                .setItemDurability(
                    new ItemDurability(
                        armor.leggings.durability,
                        "#phantasia:item/generic/durability_bar",
                    ),
                ),
        ),
    ];
