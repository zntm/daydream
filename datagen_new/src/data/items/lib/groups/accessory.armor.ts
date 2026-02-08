import { DatagenReturnData } from "../../../../lib";
import {
    Helmet,
    Breastplate,
    Leggings,
    ItemAccessory,
    ItemAccessoryType,
    ItemDurability,
} from "../";

export class ArmorDataRegistry {
    defense: number;
    durability: number;
    constructor(defense: number, durability: number) {
        this.defense = defense;
        this.durability = durability;
    }
}

// Create ArmorDataRegistry helper
export const armor = (defense: number, durability: number): ArmorDataRegistry =>
    new ArmorDataRegistry(defense, durability);

interface ArmorSet {
    helmet: ArmorDataRegistry;
    breastplate: ArmorDataRegistry;
    leggings: ArmorDataRegistry;
}

const DURABILITY_BAR = "#phantasia:item/generic/durability_bar";

const makeArmor = (
    factory: (id: string) => ReturnType<typeof Helmet>,
    type: ItemAccessoryType,
    namespace: string,
    id: string,
    slot: string,
    data: ArmorDataRegistry,
) =>
    new DatagenReturnData(
        `${id}_${slot}.json`,
        factory(`${namespace}:${id}_${slot}`)
            .setItemAccessory(new ItemAccessory(type, data.defense))
            .setItemDurability(
                new ItemDurability(data.durability, DURABILITY_BAR),
            ),
    );

export default (namespace: string, id: string, armor: ArmorSet) => [
    makeArmor(
        Helmet,
        ItemAccessoryType.Helmet,
        namespace,
        id,
        "helmet",
        armor.helmet,
    ),
    makeArmor(
        Breastplate,
        ItemAccessoryType.Breastplate,
        namespace,
        id,
        "breastplate",
        armor.breastplate,
    ),
    makeArmor(
        Leggings,
        ItemAccessoryType.Leggings,
        namespace,
        id,
        "leggings",
        armor.leggings,
    ),
];
