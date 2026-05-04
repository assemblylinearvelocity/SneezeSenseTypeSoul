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

    FarmSection:Dropdown({
        Name     = "Mob Type",
        Flag     = "Farm Mob",
        Default  = "Shinigami",
        Items    = { "Shinigami", "Frisker", "Fishbone", "Hollow", "Adjuchas" },
        Callback = function() end
    })
end

return CombatTab
