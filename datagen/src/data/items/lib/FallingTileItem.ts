import { TileItem, TileItemProperties, TileItemHarvest, TileItemParticle, TileItemDrop } from "./TileItem";
import { ItemType } from "./ItemType";
import type { ItemSprite } from "./ItemSprite";
import type { ItemInventory } from "./ItemInventory";

/**
 * FallingTileItem - A tile that falls when there's no solid block below it
 * Similar to Minecraft sand/gravel behavior with gravity physics
 */
export class FallingTileItem extends TileItem {
    constructor(
        type: ItemType,
        sprite: string,
        inventory: string | ItemInventory,
        properties?: TileItemProperties | TileItemProperties[],
    ) {
        super(type, sprite, inventory, properties);

        // Initialize falling with default enabled
        (this as any).tile.falling = {
            enabled: true
        };
    }

    /**
     * Set the delay before the tile starts falling (in game ticks)
     * This creates a brief pause like Minecraft's sand behavior
     */
    setFallDelay(ticks: number) {
        (this as any).tile.falling.delay = ticks;
        return this;
    }

    /**
     * Set custom gravity for this falling tile
     * If not set, uses PHYSICS_GLOBAL_GRAVITY
     */
    setFallGravity(gravity: number) {
        (this as any).tile.falling.gravity = gravity;
        return this;
    }

    /**
     * Disable falling behavior (useful for toggling)
     */
    setFallEnabled(enabled: boolean) {
        (this as any).tile.falling.enabled = enabled;
        return this;
    }
}
