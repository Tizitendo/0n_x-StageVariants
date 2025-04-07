# Onyx-StageVariants
- Helper to create stage variants
- Allows you to replace spritesheets, recolor layers and more

Import line:  
```lua
StageVariants = mods["0n_x-StageVariants"].setup()
```
---

### Functions
```lua
StageVariants.create(namespace, identifier, stage, name, subname, [weight]) -> Stage Variant
```

Creates a stage variant. It won't change anything for now, but it will be added to the variants that can be rolled and is visible in the imgui window

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `namespace`   | string  | The namespace of your mod |
| `identifier`  | string  | The identifier of the variant (namespace + identifier need to be unique) |
| `stage`       | Stage object  | The stage you want to add your variant to |
| `name`        | string  | the name of your variant (will show up in imgui) |
| `subname`     | string  | the subname of your variant (will replace the subname when entering the stage) |
| `weight`      | string  | the default weight of your stage x10 (50 by default) |

<br>

```lua
StageVariants.swap_tileset(stage_variant, original_tileset, replacement_tileset) -> nil
```

Adds a tileset swap to the variant. Once entering a stage with this variant the original tileset will be automatically replcaed by the replacement tileset.
If you want to create a replacement tileset, you need to look at the original tileset and put the tiles of your new tileset in the same position as in the original tileset. for example if you want to replace a bottom right corner piece, your replacement tile needs to be in the same x and y position in the new tilemap

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `stage_variant`      | Stage Variant  | the variant that you got by calling create or find |
| `original_tileset`   | sprite id  | can be obtained by doing gm.sprite_find("ror-<name of tileset you want to replace>") |
| `replacement_tileset`| sprite id  | the id of the tileset you want to use as a replacement (look at Resources.sprite_load in the toolkit) |

<br>

```lua
StageVariants.recolor_layer(stage_variant, layer_name, color) -> nil
```

Like swap_tileset, adds a recolored layer to the variant. Uncomment "GetLayerNames" in main.lua to print the names of all layers of your current stage. Layers get printed in the same order as they appear in provedit (Settings -> Background)

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `stage_variant`      | Stage Variant  | the variant that you got by calling create or find |
| `layer_name`   | string  | the name of the layer you want to recolor |
| `color`| Color  | The new color you want to use for the layer |

<br>

```lua
StageVariants.swap_sprite(stage_variant, original_sprite, replacement_sprite) -> nil
```

Like swap_tileset, adds a sprite swap to the variant, but for a single sprite. Tilesets get drawn differently and therefore need a different method to be replaced

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `stage_variant`      | Stage Variant  | the variant that you got by calling create or find |
| `original_sprite`   | sprite id  | can be obtained by doing gm.constants.<sprite name>. (get sprite names with undertale mod tool) |
| `replacement_sprite`| sprite id  | the id of the sprite you want to use as a replacement (look at Resources.sprite_load in the toolkit for custom sprites) |

<br>

```lua
StageVariants.find(namespace, identifier) -> Stage Variant
```
Returns a variant with the given namespace and identifier. Returns nil if it doesn't exist.

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `namespace`      | string  | the namespace of the Stage Variant you want to get |
| `identifier`   | string  | the identifier of the Stage Variant you want to get |

<br>

```lua
StageVariants.find_all(namespace, identifier) -> {Stage Variant}
```

Returns a table with all stage variants

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `namespace`      | string  | the namespace of the Stage Variant you want to get |
| `identifier`   | string  | the identifier of the Stage Variant you want to get |

<br>

```lua
StageVariants.delete(stage_variant) -> boolean
```

Deletes the given Stage Variant. Returns true if succesful and false if not

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `stage_variant`      | Stage Variant  | The variant you want to delete |

<br>

```lua
StageVariants.clear(stage_variant) -> nil
```

Removes all recolors, tile swaps and sprite swaps from the given variant

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `stage_variant`      | Stage Variant  | The variant you want to clear |

<br>

```lua
StageVariants.set_hidden(stage_variant, [hidden]) -> nil
```

Removes a variant from being visible in the imgui window

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `stage_variant`      | Stage Variant  | The variant you want to clear |
| `[hidden]`      | boolean  | whether to hide or unhide the variant (true by default) |

<br>

```lua
StageVariants.set_weight(stage_variant, weight) -> nil
```

Sets the weight for the given Stage, ranging from 0 to 100 (the imgui window only lets you set between 0 and 10. This value gets multiplied by 10 internally)

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `stage_variant`      | Stage Variant  | The variant you want to clear |
| `weight`      | int  | value from 0 to 100 for the weight of the stage |

<br>

```lua
StageVariants.force_next(stage_variant) -> nil
```

Forces the given variant to appear next stage, if the next stage has this variant. Only for the next stage. If you want it for every stage, you need to call this after entering for every stage. If multiple variants are forced for next stage, one will be chosen randomly

---

### Hotloading

```lua
if hotload then
    gm.sprite_replace(<sprite id of replacement sprite>, path.combine(PATH .. <same path used to originally load sprite>, "<sprite name>.png"), 1, false,
        false, 0, 0)
end
hotload = true
```

To hotload changes made to a tileset make sure to add this piece of code in your initialize before the swap tileset calls and after the resource load calls. Additionally, the following should be added after the initialize

```lua
if hotload then
    StageVariants.unload_stage()
    for _, variant in ipairs(StageVariants.find_all()) do --clear the content of all stagevariants, so there won't be duplicates when init gets run again
        StageVariants.clear(variant)
    end
    init()
end
```

Reference variants.lua for an example of hotloading

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `stage_variant`      | Stage Variant  | The variant you want to force for next stage |

## Special Thanks To
* The Return Of Modding Discord

## Contact
For questions or bug reports, you can find us in the [RoRR Modding Server](https://discord.gg/VjS57cszMq) @Onyx
