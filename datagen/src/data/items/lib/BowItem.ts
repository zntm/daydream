import { Item } from "./Item";
import { ItemDurability } from "./ItemDurability";
import { ItemType } from "./ItemType";

export class BowItem extends Item {
    // @ts-ignore
    private item?: {
        damage?: number;
        durability?: ItemDurability;
        ammo_requirement?: string;
        projectile?: string;
        hold_type?: string;
    };

    constructor(
        sprite: string,
        damage: number,
        durability: number,
        ammoType: string = "arrow",
        projectile: string = "phantasia:arrow",
    ) {
        super(ItemType.Tool, sprite, "#phantasia:item/generic/inventory_tool");

        this.item = {
            damage,
            durability: new ItemDurability(
                durability,
                "#phantasia:item/generic/durability_bar",
            ),
            ammo_requirement: ammoType,
            projectile,
            hold_type: "bow",
        };
    }
}
