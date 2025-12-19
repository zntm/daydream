import { DatagenReturnData } from "../../index";

interface GUIComponentProps {
    x?: number;
    y?: number;
    width?: number;
    height?: number;
    scale?: number;           // Optional scale multiplier (default 1.0)
    inventory_name?: string;
    slot_index?: number;
    anchor_x?: string;
    anchor_y?: string;
}

interface GUIComponent {
    type: string;
    props: GUIComponentProps;
    children?: GUIComponent[];
}

const SLOT_SIZE = 16;
const ROW_LENGTH = 10;
const INVENTORY_SIZE = 50;

// Hotbar layout - 10 slots in a row
const hotbar: GUIComponent = {
    type: "panel",
    props: {
        anchor_x: "center",
        anchor_y: "bottom",
        x: 0,
        y: 16,
        width: SLOT_SIZE * ROW_LENGTH,
        height: SLOT_SIZE
    },
    children: Array.from({ length: ROW_LENGTH }, (_, i) => ({
        type: "slot",
        props: {
            x: i * SLOT_SIZE,
            y: 0,
            inventory_name: "base",
            slot_index: i
        }
    }))
};

// Full inventory layout - 50 slots in 5 rows of 10
const inventory: GUIComponent = {
    type: "panel",
    props: {
        anchor_x: "center",
        anchor_y: "bottom",
        x: 0,
        y: 36,
        width: SLOT_SIZE * ROW_LENGTH,
        height: SLOT_SIZE * ((INVENTORY_SIZE - ROW_LENGTH) / ROW_LENGTH)
    },
    children: Array.from({ length: INVENTORY_SIZE - ROW_LENGTH }, (_, i) => ({
        type: "slot",
        props: {
            x: (i % ROW_LENGTH) * SLOT_SIZE,
            y: Math.floor(i / ROW_LENGTH) * SLOT_SIZE,
            inventory_name: "base",
            slot_index: i + ROW_LENGTH
        }
    }))
};

// Armor slots layout
const armorSlots: GUIComponent = {
    type: "panel",
    props: {
        x: -64,
        y: -64,
        width: SLOT_SIZE,
        height: SLOT_SIZE * 3
    },
    children: [
        { type: "slot", props: { x: 0, y: 0, inventory_name: "armor_helmet", slot_index: 0 } },
        { type: "slot", props: { x: 0, y: SLOT_SIZE, inventory_name: "armor_breastplate", slot_index: 0 } },
        { type: "slot", props: { x: 0, y: SLOT_SIZE * 2, inventory_name: "armor_leggings", slot_index: 0 } }
    ]
};

// Accessory slots layout
const accessorySlots: GUIComponent = {
    type: "panel",
    props: {
        x: -32,
        y: -112,
        width: SLOT_SIZE,
        height: SLOT_SIZE * 6
    },
    children: Array.from({ length: 6 }, (_, i) => ({
        type: "slot",
        props: {
            x: 0,
            y: i * SLOT_SIZE,
            inventory_name: "accessory",
            slot_index: i
        }
    }))
};

export default [
    new DatagenReturnData("generated/data/guis/hotbar.json", hotbar),
    new DatagenReturnData("generated/data/guis/inventory.json", inventory),
    new DatagenReturnData("generated/data/guis/armor.json", armorSlots),
    new DatagenReturnData("generated/data/guis/accessory.json", accessorySlots),
];
