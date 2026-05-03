local GITHUB_BASE = "https://raw.githubusercontent.com/assemblylinearvelocity/SneezeSenseTypeSoul/main/"

local function loadModule(path)
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_BASE .. path)
    end)
    if not success then
        warn("[SneezeSense] Failed to fetch:", path, "|", result)
        return nil
    end
    local loadSuccess, module = pcall(function()
        return loadstring(result)()
    end)
    if not loadSuccess then
        warn("[SneezeSense] Failed to execute:", path, "|", module)
        return nil
    end
    return module
end

if shared.SneezeSense then
    if shared.SneezeSense.detach then
        shared.SneezeSense.detach()
    end
end

task.spawn(function()
    local Library = loadModule("GUI/Library.lua")
    if not Library then return warn("Failed to load Library") end

    local EspRenderer = loadModule("Game/Visuals/EspRenderer.lua")
    if not EspRenderer then return warn("Failed to load EspRenderer") end

    local Visuals = loadModule("Game/Visuals/Visuals.lua")
    if not Visuals then return warn("Failed to load Visuals") end

    local WorldModulation = loadModule("Game/Misc/WorldModulation.lua")
    if not WorldModulation then return warn("Failed to load WorldModulation") end

    local Automation = loadModule("Game/Misc/Automation.lua")
    if not Automation then return warn("Failed to load Automation") end

    local AutoParry = loadModule("Game/Combat/AutoParry.lua")
    if not AutoParry then return warn("Failed to load AutoParry") end

    local CombatTab = loadModule("Menu/CombatTab.lua")
    if not CombatTab then return warn("Failed to load CombatTab") end

    local VisualsTab = loadModule("Menu/VisualsTab.lua")
    if not VisualsTab then return warn("Failed to load VisualsTab") end

    local MiscTab = loadModule("Menu/MiscTab.lua")
    if not MiscTab then return warn("Failed to load MiscTab") end

    local SettingsTab = loadModule("Menu/SettingsTab.lua")
    if not SettingsTab then return warn("Failed to load SettingsTab") end

    local SneezeSense = {}

    function SneezeSense.init()
        local Window = Library:Window({
            Name = "SneezeSense",
            FadeSpeed = 0.25,
        })

        local Watermark = Library:Watermark("SneezeSense ~ " .. os.date("%b %d %Y"))
        Watermark:SetVisibility(true)

        local KeybindList = Library:KeybindList()
        KeybindList:SetVisibility(false)

        local CombatPage   = Window:Page({ Name = "Combat",   Columns = 2, Subtabs = false })
        local VisualsPage  = Window:Page({ Name = "Visuals",  Columns = 2, Subtabs = false })
        local MiscPage     = Window:Page({ Name = "Misc",     Columns = 2, Subtabs = false })
        local SettingsPage = Window:Page({ Name = "Settings", Columns = 2, Subtabs = false })

        Visuals:Init(Library, EspRenderer)

        CombatTab.Init(CombatPage, AutoParry)
        VisualsTab.Init(VisualsPage, Visuals)
        MiscTab:Init(MiscPage, WorldModulation, Automation)
        SettingsTab.Init(SettingsPage, Library, KeybindList, Watermark, SneezeSense.detach)

        Library.MenuKeybind = tostring(Enum.KeyCode.RightControl)
    end

    function SneezeSense.detach()
        if AutoParry and AutoParry.Enabled then
            AutoParry:Stop()
        end
        if Visuals then
            Visuals:Unload()
        end
        if WorldModulation then
            WorldModulation:Unload()
        end
        if Automation then
            Automation:Unload()
        end
        if Library then
            Library:Unload()
        end
    end

    shared.SneezeSense = SneezeSense

    local ok, err = xpcall(SneezeSense.init, function(e)
        warn("Init failed:", e, debug.traceback())
        SneezeSense.detach()
    end)

    if not ok then
        warn("Initialization failed:", err)
    end
end)
