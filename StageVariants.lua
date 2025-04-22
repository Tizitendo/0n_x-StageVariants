StageVariants = Proxy.new()
mods.on_all_mods_loaded(function()
    for k, v in pairs(mods) do
        if type(v) == "table" and v.tomlfuncs then
            Toml = v
        end
    end
    params = {
        stageWeights = {},
        textureKey = 0
    }
    params = Toml.config_update(_ENV["!guid"], params) -- Load Save
end)

local variants = {}
local currentVariant = 0
local currentStage = nil
local switched = false
local lastSwitch = false
StageVariants.create = function(namespace, identifier, stage, name, subname, weight)
    if type(stage) == "number" then
        stage = Stage.wrap(stage)
    end
    local stageName = stage.namespace .. "-" .. stage.identifier
    if variants[stageName] == nil then
        variants[stageName] = {}
        StageVariants.create(stage.namespace, stage.identifier, stage, "Default", "")
        -- StageVariants.create(stage.namespace, stage.identifier, stage, Language.translate_token(stage.token_name), "")
    end
    if params.stageWeights[stageName] == nil then
        params.stageWeights[stageName] = {}
    end
    if params.stageWeights[stageName][namespace .. "-" .. identifier] == nil then
        params.stageWeights[stageName][namespace .. "-" .. identifier] = weight or 5
    end
    if not StageVariants.find(namespace, identifier) then
        -- variants[stageName][variant][{namespace, identifier, name, subname, {tileset}, {recolor}, {resprite}, hidden}]
        -- {tileset} = {original_tileset, replacement_tileset}
        table.insert(variants[stageName], {namespace, identifier, name, subname, {}, {}, {}, false})
    end
    return StageVariants.find(namespace, identifier)
end

StageVariants.find = function(namespace, identifier)
    for _, stage in pairs(variants) do
        for _, variant in ipairs(stage) do
            if variant[1] == namespace and variant[2] == identifier then
                return variant
            end
        end
    end
    return nil
end

StageVariants.find_all = function(namespace)
    local variantList = {}
    for _, stage in pairs(variants) do
        for _, variant in ipairs(stage) do
            if namespace == nil or variant[1] == namespace then
                table.insert(variantList, variant)
            end
        end
    end
    return variantList
end

StageVariants.delete = function(variant)
    for stagename, stage in pairs(variants) do
        for variantid, Stagevariant in ipairs(stage) do
            if Stagevariant == variant then
                table.remove(variants[stagename][variantid])
                return true
            end
        end
    end
    return false
end

StageVariants.clear = function(variant)
    if variant == nil then
        log.warning("StageVariants.clear: variant is nil")
        return
    end
    variant[5] = {}
    variant[6] = {}
    variant[7] = {}
end

local forcedVariants = {}
StageVariants.force_next = function(variant)
    table.insert(forcedVariants, variant)
end

StageVariants.set_hidden = function(variant, hidden)
    if hidden == nil then
        hidden = true
    end
    variant[8] = hidden
end

StageVariants.set_weight = function(variant, weight)
    params.stageWeights[variant[1] .. "-" .. variant[2]] = weight
end

StageVariants.swap_tileset = function(stage_variant, original_tileset, replacement_tileset)
    table.insert(stage_variant[5],
        {gm.sprite_get_texture(original_tileset, 0), gm.sprite_get_texture(replacement_tileset, 0)})
end

StageVariants.get_active_variant = function()
    if variants[currentStage] == nil then
        return nil
    end
    return variants[currentStage][currentVariant]
end

StageVariants.recolor_layer = function(stage_variant, layer_name, color)
    table.insert(stage_variant[6], {layer_name, color})
end

StageVariants.swap_sprite = function(stage_variant, original_sprite, replacement_sprite)
    table.insert(stage_variant[7], {original_sprite, replacement_sprite})
end

local lastTextures = {}
local lastResprites = {}
local lastRecolor = {}
local lastVariant = nil

StageVariants.unload_stage = function()
    if not variants[currentStage] then return end
    -- unload the tileset override when entering a new stage
    for _, texture in ipairs(lastTextures) do
        for _, tileset in ipairs(variants[currentStage][currentVariant][5]) do
            if gm.struct_get(texture, "tiles_tex") == tileset[2] then
                gm._mod_variable_struct_set(texture, "tiles_tex", tileset[1])
            end
        end
    end
    lastTextures = {}
end

gm.pre_script_hook(gm.constants.room_goto, function(self, other, result, args)
    if not gm._mod_game_ingame() then return true end
    StageVariants.unload_stage()
    currentStage = Stage.wrap(gm._mod_game_getCurrentStage()).namespace .. "-" ..
                       Stage.wrap(gm._mod_game_getCurrentStage()).identifier
    local weightedStages = {}
    if variants[currentStage] ~= nil then
        for index, variant in ipairs(variants[currentStage]) do
            for i = 1, params.stageWeights[currentStage][variant[1] .. "-" .. variant[2]] do
                table.insert(weightedStages, index)
            end
        end
    end

    if #forcedVariants ~= 0 then
        weightedStages = {}
        for index, variant in ipairs(variants[currentStage]) do
            for _, forced in ipairs(forcedVariants) do
                if forced == variant then
                    table.insert(weightedStages, index)
                end
            end
        end
    end
    forcedVariants = {}
    if #weightedStages > 0 then
        currentVariant = weightedStages[math.random(1, #weightedStages)]
    else
        currentVariant = nil
    end
    if currentVariant and variants[currentStage] and variants[currentStage][currentVariant][4] and
        variants[currentStage][currentVariant][4] ~= "" then
        Global.level_subname = variants[currentStage][currentVariant][4]
        lastVariant = variants[currentStage][currentVariant]
    else
        lastVariant = nil
    end
end)

Callback.add(Callback.TYPE.onStageStart, NAMESPACE .. "onStageStart", function()
    if currentVariant == nil or variants[currentStage] == nil then
        return
    end
    for _, recolor in ipairs(variants[currentStage][currentVariant][6]) do
        local elements = gm.layer_get_all_elements(recolor[1])
        for j = 0, gm.array_length(elements) - 1 do
            local element = gm.array_get(elements, j)
            if gm.layer_get_element_type(element) == 1 then
                table.insert(lastRecolor, gm.layer_background_get_blend(element))
                gm.layer_background_blend(element, recolor[2])
            end
        end
    end

    for i, resprite in ipairs(variants[currentStage][currentVariant][7]) do
        lastResprites[i] = Resources.sprite_load(NAMESPACE, i, PATH .. "/empty.png")
        gm.sprite_assign(lastResprites[i], resprite[1])
        gm.sprite_assign(resprite[1], resprite[2])
    end
end)

gm.pre_script_hook(gm.constants
                       .anon_tile_render_setup_draw_func_gml_GlobalScript_scr_tilemap_rendering_33181338_tile_render_setup_draw_func_gml_GlobalScript_scr_tilemap_rendering,
    function(self, other, result, args)
        if self and currentVariant ~= nil and currentStage ~= nil then
            for _, tileset in ipairs(variants[currentStage][currentVariant][5]) do
                if gm.struct_get(self, "tiles_tex") == tileset[1] then
                    table.insert(lastTextures, self)
                    gm._mod_variable_struct_set(self, "tiles_tex", tileset[2])
                end
            end
        end

        if switched then
            for _, texture in ipairs(lastTextures) do
                for _, tileset in ipairs(variants[currentStage][currentVariant][5]) do
                    if gm.struct_get(texture, "tiles_tex") == tileset[2] then
                        gm._mod_variable_struct_set(texture, "tiles_tex", tileset[1])
                    end
                end
            end
            lastTextures = {}
        end
    end)

-- GUI
local awaitingChatKeybind = false
gui.add_imgui(function()
    if ImGui.Begin("StageVariants") then
        ImGui.Text("Test Texture Keybind")
        if awaitingChatKeybind then
            ImGui.Button("<Waiting for Key>")
        else
            if ImGui.Button("          " .. params.textureKey .. "          ") then
                awaitingChatKeybind = true
            end
        end
        for keyCode = 0, 512 do
            if ImGui.IsKeyPressed(keyCode) and awaitingChatKeybind then
                params.textureKey = keyCode
                awaitingChatKeybind = false
                break
            end
        end

        local spaces = ""
        for i = 0, #Global.class_stage - 1 do
            local stage = Stage.wrap(i)
            local stageName = stage.namespace .. "-" .. stage.identifier
            if variants[stageName] then
                spaces = spaces .. " "
                local collapse = ImGui.CollapsingHeader(Language.translate_token(stage.token_name))
                -- local collapse = ImGui.CollapsingHeader(stage.token_name)
                -- ImGui.Text(Language.translate_token(stage.token_name))
                if collapse then
                    for _, variant in ipairs(variants[stageName]) do
                        if not variant[8] then
                            params.stageWeights[stageName][variant[1] .. "-" .. variant[2]] = ImGui.SliderInt(
                                variant[3] .. spaces,
                                params.stageWeights[stageName][variant[1] .. "-" .. variant[2]], 0, 10)
                        end
                    end
                end
            end
        end
        Toml.save_cfg(_ENV["!guid"], params)
    end
    ImGui.End()
end)

gui.add_always_draw_imgui(function()
    switched = ImGui.IsKeyDown(params.textureKey)
end)

Callback.add(Callback.TYPE.onStep, NAMESPACE .. "onStep", function()
    if lastSwitch ~= switched then
        if switched then
            if lastVariant then
                for i, sprite in ipairs(lastVariant[7]) do
                    gm.sprite_assign(sprite[1], lastResprites[i])
                end
            end
            local index = 1
            for _, recolor in ipairs(variants[currentStage][currentVariant][6]) do
                local elements = gm.layer_get_all_elements(recolor[1])
                for j = 0, gm.array_length(elements) - 1 do
                    local element = gm.array_get(elements, j)
                    if gm.layer_get_element_type(element) == 1 then
                        gm.layer_background_blend(element, lastRecolor[index])
                        index = index + 1
                    end
                end
            end
        else
            for i, resprite in ipairs(variants[currentStage][currentVariant][7]) do
                lastResprites[i] = Resources.sprite_load(NAMESPACE, i, PATH .. "/empty.png")
                gm.sprite_assign(resprite[1], resprite[2])
            end
            for _, recolor in ipairs(variants[currentStage][currentVariant][6]) do
                local elements = gm.layer_get_all_elements(recolor[1])
                for j = 0, gm.array_length(elements) - 1 do
                    local element = gm.array_get(elements, j)
                    if gm.layer_get_element_type(element) == 1 then
                        gm.layer_background_blend(element, recolor[2])
                    end
                end
            end
        end
    end
    lastSwitch = switched
end)
