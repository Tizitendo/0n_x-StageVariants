log.info("Successfully loaded " .. _ENV["!guid"] .. ".")
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)
StageVariants = mods["0n_x-StageVariantHelper"].setup() 
PATH = _ENV["!plugins_mod_folder_path"]
NAMESPACE = "OnyxStageVariants"

local empty
local function init()
    empty = Resources.sprite_load(NAMESPACE, "empty", path.combine(PATH, "empty.png"), 1, 0, 0)

    -- loading in all the sprites
    ---- Dried Lake ----
    local driedlake_retro = Resources.sprite_load(NAMESPACE, "driedlake_retro",
        path.combine(PATH .. "/Stages/driedLake", "Retro.png"), 1, 0, 0)
    local driedlake = gm.sprite_find("ror-Tile16Sand")

    ---- Desolate Forest ----
    local desolateForest = gm.sprite_find("ror-Tile16Dead")
    local desolateForest_2 = gm.sprite_find("ror-DesolateForest2")
    local backTiles1 = gm.sprite_find("ror-64_1_1")
    local desolateForest_retro = Resources.sprite_load(NAMESPACE, "desolateForest_retro",
        path.combine(PATH .. "/Stages/desolateForest", "Retro.png"), 1, 0, 0)
    local desolateForest_retro_2 = Resources.sprite_load(NAMESPACE, "desolateForest_retro_2",
        path.combine(PATH .. "/Stages/desolateForest", "Retro_2.png"), 1, 0, 0)
    local backTiles1_retro = Resources.sprite_load(NAMESPACE, "backTiles1_retro",
    path.combine(PATH .. "/Stages/desolateForest", "backTiles1_retro.png"), 1, 0, 0)

    ---- Temple Of The Elders ----
    -- Snow
    local templeOfTheElders = gm.sprite_find("ror-Tile16Temple")
    local templeOfTheElders_snow = gm.sprite_find("ror-Tile16Temple_S")

    -- Night
    local templeOfTheElders_night = Resources.sprite_load(NAMESPACE, "templeOfTheElders_night", path.combine(
        PATH .. "/Stages/templeOfTheElders", "Night.png"), 1, 0, 0)
    local moon = Resources.sprite_load(NAMESPACE, "moon", path.combine(PATH .. "/Stages/templeOfTheElders", "moon.png"),
        1, 0, 0)

    ---- Sunken Tombs ----
    local sunkenTombs = gm.sprite_find("ror-Tile16Water")
    -- Flaming
    local sunkenTombs_flaming = Resources.sprite_load(NAMESPACE, "sunkenTombs_flaming",
        path.combine(PATH .. "/Stages/sunkenTombs", "Flaming.png"), 1, 0, 0)
    local ceiling_1 = Resources.sprite_load(NAMESPACE, "sunkenTombs-ceiling_1",
        path.combine(PATH .. "/Stages/sunkenTombs/Sprites", "ceiling_1.png"), 1, 0, 0)

    
    -- make sure to put this after loading in sprites, but before adding the variants as it will break otherwise
    if hotload then
        gm.sprite_replace(desolateForest_retro, path.combine(PATH .. "/Stages/desolateForest", "Retro.png"), 1, false,
            false, 0, 0)
        gm.sprite_replace(desolateForest_retro_2, path.combine(PATH .. "/Stages/desolateForest", "Retro_2.png"), 1,
            false, false, 0, 0)
        gm.sprite_replace(backTiles1_retro, path.combine(PATH .. "/Stages/desolateForest", "backTiles1_retro.png"), 1,
            false, false, 0, 0)
        gm.sprite_replace(driedlake_retro, path.combine(PATH .. "/Stages/driedLake", "Retro.png"), 1, false, false, 0, 0)
        gm.sprite_replace(templeOfTheElders_night, path.combine(PATH .. "/Stages/templeOfTheElders", "Night.png"), 1,
            false, false, 0, 0)
        gm.sprite_replace(sunkenTombs_flaming, path.combine(PATH .. "/Stages/sunkenTombs", "Flaming.png"), 1, false, false, 0, 0)
    end
    hotload = true

    --adding the variants
    ---- Dried Lake ----
    local variant = StageVariants.create(NAMESPACE, "driedlake_retro", Stage.find("ror", "driedLake"), "Retro", "Retro")
    StageVariants.swap_tileset(variant, driedlake, driedlake_retro)

    ---- Desolate Forest ----
    variant = StageVariants.create(NAMESPACE, "desolateForest_retro", Stage.find("ror", "desolateForest"), "Retro",
        "Retro")
    StageVariants.swap_tileset(variant, desolateForest, desolateForest_retro)
    StageVariants.swap_tileset(variant, desolateForest_2, desolateForest_retro_2)
    StageVariants.swap_tileset(variant, backTiles1, backTiles1_retro)

    ---- Temple Of The Elders ----
    -- Snow
    local variant = StageVariants.create(NAMESPACE, "templeOfTheElders_snow", Stage.find("ror", "templeOfTheElders"),
        "Snowy", "Snowy")
    StageVariants.swap_tileset(variant, templeOfTheElders, templeOfTheElders_snow)

    -- Night
    local variant = StageVariants.create(NAMESPACE, "templeOfTheElders_night", Stage.find("ror", "templeOfTheElders"),
        "Night", "Night")
    StageVariants.swap_tileset(variant, templeOfTheElders, templeOfTheElders_night)
    StageVariants.recolor_layer(variant, "bg_col", 0) -- higher background
    StageVariants.recolor_layer(variant, "bg8", 8421504) -- background ship
    StageVariants.recolor_layer(variant, "bg7", 8421504) -- hills
    StageVariants.recolor_layer(variant, "bg6", 0) -- lower background
    StageVariants.swap_sprite(variant, gm.constants.bSun2, moon)
    StageVariants.swap_sprite(variant, gm.constants.bTempleCloudsNew_4, gm.constants.bSnowCloudsNew7)
    StageVariants.swap_sprite(variant, gm.constants.bTempleCloudsNew_1, empty)
    StageVariants.swap_sprite(variant, gm.constants.bTempleCloudsNew_2, empty)
    StageVariants.swap_sprite(variant, gm.constants.bTempleCloudsNew_3, empty)
    StageVariants.swap_sprite(variant, gm.constants.bTempleCloudsNew_5, empty)
    StageVariants.swap_sprite(variant, gm.constants.bTempleCloudsNew_6, empty)

    ---- Sunken Tombs ----
    -- Flaming
    local variant = StageVariants.create(NAMESPACE, "sunkenTombs_flaming", Stage.find("ror", "sunkenTombs"), "Flaming",
        "Flaming")
    StageVariants.swap_tileset(variant, sunkenTombs, sunkenTombs_flaming)
    StageVariants.recolor_layer(variant, "bg_col", Color.from_hex(0x815134))
    StageVariants.recolor_layer(variant, "bg0", Color.from_hex(0x00ff64)) -- light rays
    StageVariants.recolor_layer(variant, "bg5", Color.from_hex(0xff9632)) -- stalagmites
    StageVariants.recolor_layer(variant, "bg4", Color.from_hex(0xff9632)) -- background close

    StageVariants.recolor_layer(variant, "bg1", 0) -- back stalagtites
    StageVariants.recolor_layer(variant, "bg2", 255) -- mid stalagtites
    StageVariants.recolor_layer(variant, "bg3", 255) -- front stalagtites
    StageVariants.swap_sprite(variant, gm.constants.bWater_Ceiling_1, ceiling_1)
    StageVariants.swap_sprite(variant, gm.constants.bWater_Ceiling_2, ceiling_1)
end
Initialize(init)

if hotload then
    StageVariants.unload_stage()
    for _, variant in ipairs(StageVariants.find_all()) do --clear the content of all stagevariants, so there won't be duplicates when init gets run again
        StageVariants.clear(variant)
    end
    init()
end

Callback.remove(NAMESPACE .. "GetLayerNames")
Callback.add(Callback.TYPE.onStageStart, NAMESPACE .. "GetLayerNames", function() -- used to get all layer names in room
    -- for k, v in pairs(gm.layer_get_all()) do
    --     log.warning(gm.layer_get_name(v))
    -- end
end)

gm.pre_script_hook(gm.constants.stage_goto, function(self, other, result, args) -- force a specific stage
    args[1].value = 0 -- Stage number
        if args[2] == nil then
            return
        end
        args[2].value = 2 -- Room number
end)
