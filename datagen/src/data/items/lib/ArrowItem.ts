import { Item } from "./Item";
import { ItemType } from "./ItemType";

export class AmmoItem extends Item {
    // @ts-ignore
    private item?: {
        ammo_type?: string;
        damage?: number;
        projectile?: string;
    };

    constructor(
        sprite: string,
        damage: number,
        ammoType: string = "arrow",
        projectile?: string,
    ) {
        super(
            ItemType.Default,
            sprite,
            "#phantasia:item/generic/inventory_default",
        );

        this.item = {
            ammo_type: ammoType,
            damage,
        };

        if (projectile !== undefined) {
            this.item.projectile = projectile;
        }
    }

    public setProjectile(projectile: string) {
        if (!this.item) this.item = {};
        this.item.projectile = projectile;
        return this;
    }
}
