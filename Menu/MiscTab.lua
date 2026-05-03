local MiscTab = {}

function MiscTab:Init(Page, WorldModulation, Automation)
    local WorldSection = Page:Section({ Name = "World", Side = 1 })

    WorldSection:Toggle({
        Name     = "Time Change",
        Flag     = "Time Change",
        Default  = false,
        Callback = function() WorldModulation:Update() end
    })

    WorldSection:Slider({
        Name     = "Time of Day",
        Flag     = "Time Value",
        Min      = 0,
        Max      = 24,
        Default  = 14,
        Decimals = 0.5,
        Suffix   = "h",
        Compact  = true,
        Callback = function() WorldModulation:Update() end
    })

    WorldSection:Toggle({
        Name     = "No Fog",
        Flag     = "No Fog",
        Default  = false,
        Callback = function() WorldModulation:Update() end
    })

    WorldSection:Toggle({
        Name     = "Fullbright",
        Flag     = "Fullbright",
        Default  = false,
        Callback = function() WorldModulation:Update() end
    })

    WorldSection:Slider({
        Name     = "Brightness",
        Flag     = "Brightness Value",
        Min      = 0,
        Max      = 10,
        Default  = 2,
        Decimals = 0.1,
        Compact  = true,
        Callback = function(Value)
            game:GetService("Lighting").Brightness = Value
        end
    })

    local AutomationSection = Page:Section({ Name = "Automation", Side = 2 })

    AutomationSection:Toggle({
        Name     = "Fly",
        Flag     = "Fly",
        Default  = false,
        Callback = function() Automation:Update() end
    }):Keybind({
        Name     = "Fly Bind",
        Flag     = "Fly Bind",
        Default  = Enum.KeyCode.Y,
        Mode     = "Toggle",
        Callback = function(Value)
            if _G.Flags then _G.Flags["Fly"] = Value end
            Automation:Update()
        end
    })

    AutomationSection:Slider({
        Name     = "Fly Speed",
        Flag     = "Fly Speed",
        Min      = 0,
        Max      = 1000,
        Default  = 100,
        Decimals = 1,
        Compact  = true,
        Callback = function() Automation:Update() end
    })

    AutomationSection:Toggle({
        Name     = "Speedhack",
        Flag     = "Speedhack",
        Default  = false,
        Callback = function() Automation:Update() end
    }):Keybind({
        Name     = "Speed Bind",
        Flag     = "Speed Bind",
        Default  = Enum.KeyCode.N,
        Mode     = "Toggle",
        Callback = function(Value)
            if _G.Flags then _G.Flags["Speedhack"] = Value end
            Automation:Update()
        end
    })

    AutomationSection:Slider({
        Name     = "Speed",
        Flag     = "Speed Value",
        Min      = 0,
        Max      = 1000,
        Default  = 100,
        Decimals = 1,
        Compact  = true,
        Callback = function() Automation:Update() end
    })

    AutomationSection:Toggle({
        Name     = "Noclip",
        Flag     = "Noclip",
        Default  = false,
        Callback = function() Automation:Update() end
    }):Keybind({
        Name     = "Noclip Bind",
        Flag     = "Noclip Bind",
        Default  = Enum.KeyCode.Unknown,
        Mode     = "Toggle",
        Callback = function(Value)
            if _G.Flags then _G.Flags["Noclip"] = Value end
            Automation:Update()
        end
    })

    AutomationSection:Toggle({
        Name     = "Inf Jump",
        Flag     = "Inf Jump",
        Default  = false,
        Callback = function() Automation:Update() end
    }):Keybind({
        Name     = "Inf Jump Bind",
        Flag     = "Inf Jump Bind",
        Default  = Enum.KeyCode.H,
        Mode     = "Toggle",
        Callback = function(Value)
            if _G.Flags then _G.Flags["Inf Jump"] = Value end
            Automation:Update()
        end
    })

    AutomationSection:Slider({
        Name     = "Jump Height",
        Flag     = "Jump Power",
        Min      = 0,
        Max      = 1000,
        Default  = 50,
        Decimals = 1,
        Compact  = true,
        Callback = function() Automation:Update() end
    })
end

return MiscTab
