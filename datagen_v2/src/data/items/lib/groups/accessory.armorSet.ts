import {
    AccessoryItem,
    ItemAccessory,
    ItemAccessoryType,
    ItemDurability,
} from "../";
import { DatagenReturnData, Attribute } from "../../../../lib";
import { AccessoryRegistry } from "../../registries/tiered";

export default (
    namespace: string,
    id: string,
    helmet: AccessoryRegistry,
    breastplate: AccessoryRegistry,
    leggings: AccessoryRegistry,
) => [
    new DatagenReturnData(
        `${id}_helmet.json`,
        new AccessoryItem(
            `${namespace}:item/${id}_helmet`,
            new ItemAccessory(ItemAccessoryType.Helmet).setAttribute(
                new Attribute().setDefense(helmet.defense),
            ),
            new ItemDurability(
                helmet.durability,
                "#phantasia:item/generic/durability_bar",
            ),
        ),
    ),
    new DatagenReturnData(
        `${id}_breastplate.json`,
        new AccessoryItem(
            `${namespace}:item/${id}_breastplate`,
            new ItemAccessory(ItemAccessoryType.Breastplate).setAttribute(
                new Attribute().setDefense(breastplate.defense),
            ),
            new ItemDurability(
                breastplate.durability,
                "#phantasia:item/generic/durability_bar",
            ),
        ),
    ),
    new DatagenReturnData(
        `${id}_leggings.json`,
        new AccessoryItem(
            `${namespace}:item/${id}_leggings`,
            new ItemAccessory(ItemAccessoryType.Leggings).setAttribute(
                new Attribute().setDefense(leggings.defense),
            ),
            new ItemDurability(
                leggings.durability,
                "#phantasia:item/generic/durability_bar",
            ),
        ),
    ),
];
