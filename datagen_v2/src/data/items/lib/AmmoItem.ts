import { Item } from "./Item";
import { ItemType } from "./ItemType";

export class AmmoItem extends Item {
    // @ts-ignore
    private item?: {
        damage?: number;
        projectile?: string;
    };

    constructor(sprite: string, damage: number, projectile?: string) {
        super(
            ItemType.Default,
            sprite,
            "#phantasia:item/generic/inventory_default",
        );

        this.item = {
            damage,
            projectile,
        };
    }

    setProjectile(projectile: string): AmmoItem {
        this.item ??= {};
        this.item.projectile = projectile;

        return this;
    }
}
