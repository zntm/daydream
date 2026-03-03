import { Item } from "./Item";
import { ItemDurability } from "./ItemDurability";
import { ItemType } from "./ItemType";

export class LauncherItem extends Item {
    // @ts-ignore
    private item?: {
        damage?: number;
        durability?: ItemDurability;
        ammo_requirement?: string;
        projectile?: string;
        hold_type?: string;
        skill?: any;
        cooldown?: number;
    };

    constructor(
        sprite: string,
        damage: number,
        durability: number,
        ammoType: string = "arrow",
        projectile: string = "phantasia:arrow",
        chargeDuration: number = 0.5,
        cooldown: number = 0.3,
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
            hold_type: "launcher",
            cooldown,
            skill: {
                type: "charge",
                threshold: chargeDuration,
                stamina_cost: 10,
            },
        };
    }
}
