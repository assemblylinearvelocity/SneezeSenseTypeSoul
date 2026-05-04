local CombatTab = {}

function CombatTab.Init(Page, AutoParry, AutoFarm)
    local FarmSection = Page:Section({ Name = "Auto Farm", Side = 1 })

    FarmSection:Toggle({
        Name     = "Auto Farm",
        Flag     = "Auto Farm",
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
