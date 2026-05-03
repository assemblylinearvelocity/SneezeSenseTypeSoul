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
            _G.Flags = _G.Flags or {}
            _G.Flags["Fly"] = Value
            Automation:Update()
        end
    })

    AutomationSection:Slider({
        Name     = "Fly Speed",
        Flag     = "Fly Speed",
        Min      = 10,
        Max      = 500,
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
    })

    AutomationSection:Slider({
        Name     = "Speed",
        Flag     = "Speedhack Value",
        Min      = 10,
        Max      = 500,
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
        Default  = Enum.KeyCode.N,
        Mode     = "Toggle",
        Callback = function(Value)
            _G.Flags = _G.Flags or {}
            _G.Flags["Noclip"] = Value
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
            _G.Flags = _G.Flags or {}
            _G.Flags["Inf Jump"] = Value
            Automation:Update()
        end
    })

    AutomationSection:Slider({
        Name     = "Jump Power",
        Flag     = "Jump Power",
        Min      = 10,
        Max      = 200,
        Default  = 50,
        Decimals = 1,
        Compact  = true,
        Callback = function() Automation:Update() end
    })

    AutomationSection:Toggle({
        Name     = "No Fall",
        Flag     = "No Fall",
        Default  = false,
        Callback = function() Automation:Update() end
    }):Keybind({
        Name     = "No Fall Bind",
        Flag     = "No Fall Bind",
        Default  = Enum.KeyCode.Unknown,
        Mode     = "Toggle",
        Callback = function(Value)
            _G.Flags = _G.Flags or {}
            _G.Flags["No Fall"] = Value
            Automation:Update()
        end
    })
end

return MiscTab
