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

    local AutomationSection = Page:Section({ Name = "Automation", Side = 2 })
end

return MiscTab
