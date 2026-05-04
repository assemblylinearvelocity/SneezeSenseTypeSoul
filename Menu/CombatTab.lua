local CombatTab = {}

function CombatTab.Init(Page, AutoParry, AutoFarm)
    local FarmSection = Page:Section({ Name = "Mission Farm", Side = 1 })

    FarmSection:Toggle({
        Name     = "Mission Farm",
        Flag     = "Mission Farm",
        Default  = false,
        Callback = function()
            AutoFarm:Update()
        end
    })
end

return CombatTab
