import { DatagenReturnData } from "../lib/DatagenReturnData";
import {
    SmartValue,
    SmartValueRandom,
    SmartValueType,
} from "../lib/SmartValue";
import { Sound } from "../lib/Sound";
import { Item } from "./items/lib/Item";
import { ItemBooleanComponent } from "./items/lib/ItemComponent";
import { ItemComponent } from "./items/lib/ItemComponent";
import { ItemComponentType } from "./items/lib/ItemComponent";
import { ItemConsumable } from "./items/lib/ItemConsumable";
import { ItemCooldown } from "./items/lib/ItemCooldown";
import { ItemDrop } from "./items/lib/ItemDrop";
import { ItemDurability } from "./items/lib/ItemDurability";
import { ItemFloatComponent } from "./items/lib/ItemComponent";
import { ItemFunction } from "./items/lib/ItemFunction";
import { ItemFunctionAnchorData } from "./items/lib/ItemFunction";
import { ItemFunctionButtonData } from "./items/lib/ItemFunction";
import { ItemFunctionData } from "./items/lib/ItemFunction";
import { ItemFunctionDataType } from "./items/lib/ItemFunction";
import { ItemFunctionTextboxFloatData } from "./items/lib/ItemFunction";
import { ItemFunctionTextboxIntegerData } from "./items/lib/ItemFunction";
import { ItemFunctionTextboxStringData } from "./items/lib/ItemFunction";
import { ItemHarvest } from "./items/lib/ItemHarvest";
import { ItemIntegerComponent } from "./items/lib/ItemComponent";
import { ItemInventory } from "./items/lib/ItemInventory";
import { ItemSprite } from "./items/lib/ItemSprite";
import { ItemStringComponent } from "./items/lib/ItemComponent";
import { ItemType } from "./items/lib/ItemType";

export {
    Item,
    ItemBooleanComponent,
    ItemComponent,
    ItemComponentType,
    ItemConsumable,
    ItemCooldown,
    ItemDrop,
    ItemDurability,
    ItemFloatComponent,
    ItemFunction,
    ItemFunctionAnchorData,
    ItemFunctionButtonData,
    ItemFunctionData,
    ItemFunctionDataType,
    ItemFunctionTextboxFloatData,
    ItemFunctionTextboxIntegerData,
    ItemFunctionTextboxStringData,
    ItemHarvest,
    ItemIntegerComponent,
    ItemInventory,
    ItemSprite,
    ItemStringComponent,
    ItemType,
};

const { default: toolItems } = import.meta.require("./items/toolItems");
const { default: miscItems } = import.meta.require("./items/miscItems");
const { default: foodItems } = import.meta.require("./items/foodItems");
const { default: plantItems } = import.meta.require("./items/plantItems");
const { default: grassItems } = import.meta.require("./items/grassItems");
const { default: furnaceItem } = import.meta.require("./items/furnaceItem");
const { default: glassItem } = import.meta.require("./items/glassItem");
const { default: debrisItems } = import.meta.require("./items/debrisItems");
const { default: stoneItems } = import.meta.require("./items/stoneItems");
const { default: oreItemsList } = import.meta.require("./items/oreItemsList");
const { default: equipmentItems } = import.meta.require("./items/equipmentItems");
const { default: woodItemsList } = import.meta.require("./items/woodItemsList");

export default [
    ...toolItems,
    ...miscItems,
    ...foodItems,
    ...plantItems,
    ...grassItems,
    ...furnaceItem,
    ...glassItem,
    ...debrisItems,
    ...stoneItems,
    ...oreItemsList,
    ...equipmentItems,
    ...woodItemsList,
];
