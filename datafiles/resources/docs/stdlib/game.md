# Game API

## Functions

### `tile_get(x, y, z)`: Tile?

Gets the tile ID at the specified position.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | X position |
| `y` | number | Y position |
| `z` | number | Z position (layer) |

**Returns:** Tile?

---

### `tile_place(tile_id, x, y, z)`: void

Places a tile at the specified position.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `tile_id` | any | Tile ID or name |
| `x` | number | X position |
| `y` | number | Y position |
| `z` | number | Z position (layer) |

**Returns:** void

---

### `spawn_particle(particle, x, y)`: void

Spawns a particle at the specified position.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `particle` | string | Particle name |
| `x` | number | X position in tiles |
| `y` | number | Y position in tiles |

**Returns:** void

---

### `tag_get(tag_name)`: any

Gets tag data.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `tag_name` | string | Name of the tag (without #) |

**Returns:** any

---
