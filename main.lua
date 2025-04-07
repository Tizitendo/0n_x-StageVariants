log.info("Successfully loaded " .. _ENV["!guid"] .. ".")
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)
local envy = mods["MGReturns-ENVY"]
envy.auto()
PATH = _ENV["!plugins_mod_folder_path"]
NAMESPACE = "OnyxStageVariants"

function public.setup(env)
    if env == nil then
        env = envy.getfenv(2)
    end
    local wrapper = {}
    for k, v in pairs(StageVariants) do
        wrapper[k] = v
    end
    return wrapper
end

require("./StageVariants")
require("./variants")
