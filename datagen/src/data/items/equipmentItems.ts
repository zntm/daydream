const { default: tieredEquipmentItems } = import.meta.require("./tieredEquipmentItems");

export default [
    ...[
        {
            id: "copper",
            helmet: { defense: 2, durability: 100 },
            breastplate: { defense: 4, durability: 136 },
            leggings: { defense: 3, durability: 108 },
            sword: { damage: 5, durability: 162 },
            pickaxe: { damage: 4, durability: 141 },
            axe: { damage: 4, durability: 133 },
            shovel: { damage: 3, durability: 125 },
            harvest: {
                hardness: 1.12,
                level: 2,
            },
        },
        {
            id: "iron",
            helmet: { defense: 4, durability: 277 },
            breastplate: { defense: 7, durability: 308 },
            leggings: { defense: 5, durability: 244 },
            sword: { damage: 7, durability: 367 },
            pickaxe: { damage: 6, durability: 319 },
            axe: { damage: 6, durability: 300 },
            shovel: { damage: 4, durability: 283 },
            harvest: {
                hardness: 1.19,
                level: 3,
            },
        },
        {
            id: "gold",
            helmet: { defense: 6, durability: 494 },
            breastplate: { defense: 11, durability: 671 },
            leggings: { defense: 8, durability: 531 },
            sword: { damage: 8, durability: 799 },
            pickaxe: { damage: 7, durability: 695 },
            axe: { damage: 7, durability: 653 },
            shovel: { damage: 5, durability: 616 },
            harvest: {
                hardness: 1.25,
                level: 4,
            },
        },
        {
            id: "platinum",
            helmet: { defense: 7, durability: 766 },
            breastplate: { defense: 13, durability: 1041 },
            leggings: { defense: 9, durability: 823 },
            sword: { damage: 13, durability: 1239 },
            pickaxe: { damage: 11, durability: 1078 },
            axe: { damage: 10, durability: 1012 },
            shovel: { damage: 7, durability: 955 },
            harvest: {
                hardness: 1.31,
                level: 5,
            },
        },
    ]
        .map(
            ({
                id,
                helmet,
                breastplate,
                leggings,
                sword,
                pickaxe,
                axe,
                shovel,
                harvest,
            }) =>
                tieredEquipmentItems(
                    id,
                    helmet,
                    breastplate,
                    leggings,
                    sword,
                    pickaxe,
                    axe,
                    shovel,
                    harvest,
                ),
        )
        .flat(),
];
