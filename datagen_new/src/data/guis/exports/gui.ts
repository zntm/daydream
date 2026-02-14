import { DatagenReturnData } from "../../../lib";

interface GUIComponentProps {
    x?: number;
    y?: number;
    width?: number;
    height?: number;
    scale?: number;
    inventory_name?: string;
    slot_index?: number;
    anchor_x?: string;
    anchor_y?: string;
    icon_sprite?: string;
    icon_index?: number;
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
        height: SLOT_SIZE,
    },
    children: Array.from({ length: ROW_LENGTH }, (_, i) => ({
        type: "slot",
        props: {
            x: i * SLOT_SIZE,
            y: 0,
            inventory_name: "base",
            slot_index: i,
        },
    })),
};

// Full inventory layout - 50 slots in 5 rows of 10, plus Armor and Accessories
const inventory: GUIComponent = {
    type: "panel",
    props: {
        anchor_x: "center",
        anchor_y: "bottom",
        x: 0,
        y: 36,
        width: SLOT_SIZE * ROW_LENGTH,
        height: SLOT_SIZE * ((INVENTORY_SIZE - ROW_LENGTH) / ROW_LENGTH),
    },
    children: [
        // Backpack Slots (Rows 1-4)
        ...Array.from({ length: INVENTORY_SIZE - ROW_LENGTH }, (_, i) => ({
            type: "slot",
            props: {
                x: (i % ROW_LENGTH) * SLOT_SIZE,
                y: Math.floor(i / ROW_LENGTH) * SLOT_SIZE,
                inventory_name: "base",
                slot_index: i + ROW_LENGTH,
            },
        })),

        // Armor Slots
        {
            type: "slot",
            props: {
                x: -20,
                y: 0,
                inventory_name: "armor_helmet",
                slot_index: 0,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 0,
            },
        },
        {
            type: "slot",
            props: {
                x: -20,
                y: 16,
                inventory_name: "armor_breastplate",
                slot_index: 0,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 1,
            },
        },
        {
            type: "slot",
            props: {
                x: -20,
                y: 32,
                inventory_name: "armor_leggings",
                slot_index: 0,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 2,
            },
        },

        // Accessory Slots
        {
            type: "slot",
            props: {
                x: -56,
                y: 0,
                inventory_name: "accessory",
                slot_index: 0,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 3,
            },
        },
        {
            type: "slot",
            props: {
                x: -40,
                y: 0,
                inventory_name: "accessory",
                slot_index: 1,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 3,
            },
        },
        {
            type: "slot",
            props: {
                x: -56,
                y: 16,
                inventory_name: "accessory",
                slot_index: 2,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 3,
            },
        },
        {
            type: "slot",
            props: {
                x: -40,
                y: 16,
                inventory_name: "accessory",
                slot_index: 3,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 3,
            },
        },
        {
            type: "slot",
            props: {
                x: -56,
                y: 32,
                inventory_name: "accessory",
                slot_index: 4,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 3,
            },
        },
        {
            type: "slot",
            props: {
                x: -40,
                y: 32,
                inventory_name: "accessory",
                slot_index: 5,
                icon_sprite: "spr_Inventory_Slot_Icon",
                icon_index: 3,
            },
        },
    ],
};

export default [
    new DatagenReturnData("hotbar.json", hotbar),
    new DatagenReturnData("inventory.json", inventory),
];
