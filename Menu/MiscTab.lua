local MiscTab = {}

function MiscTab:Init(Page, WorldModulation, Automation)
    local WorldSection = Page:Section({ Name = "World", Side = 1 })

    WorldSection:Toggle({
        Name     = "Time Change",
        Flag     = "Time Change",
        Default  = false,
        Callback = function(Value)
            WorldModulation:Update()
        end
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
        Callback = function(Value)
            WorldModulation:Update()
        end
    })

    WorldSection:Toggle({
        Name     = "No Fog",
        Flag     = "No Fog",
        Default  = false,
        Callback = function(Value)
            WorldModulation:Update()
        end
    })

    WorldSection:Toggle({
        Name     = "Fullbright",
        Flag     = "Fullbright",
        Default  = false,
        Callback = function(Value)
            WorldModulation:Update()
        end
    })

    local AutomationSection = Page:Section({ Name = "Automation", Side = 2 })

    AutomationSection:Toggle({
        Name     = "Fly",
        Flag     = "Fly",
        Default  = false,
        Callback = function(Value)
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
        Callback = function(Value)
            Automation:Update()
        end
    })

    AutomationSection:Toggle({
        Name     = "Noclip",
        Flag     = "Noclip",
        Default  = false,
        Callback = function(Value)
            Automation:Update()
        end
    })

    AutomationSection:Toggle({
        Name     = "Inf Jump",
        Flag     = "Inf Jump",
        Default  = false,
        Callback = function(Value)
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
        Callback = function(Value)
            Automation:Update()
        end
    })

    AutomationSection:Toggle({
        Name     = "No Fall",
        Flag     = "No Fall",
        Default  = false,
        Callback = function(Value)
            Automation:Update()
        end
    })
end

return MiscTab
