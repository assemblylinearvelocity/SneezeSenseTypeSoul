local VisualsTab = {}

function VisualsTab.Init(Page, Visuals)
    local ESPSection = Page:Section({ Name = "ESP", Side = 1 })

    ESPSection:Toggle({
        Name     = "Box ESP",
        Flag     = "Box ESP",
        Default  = false,
        Callback = function(Value)
            Visuals:Update()
        end
    }):Colorpicker({
        Name     = "Box Color",
        Flag     = "Box Color",
        Default  = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            Visuals:Update()
        end
    })

    local HealthTextToggle

    ESPSection:Toggle({
        Name     = "HP Bar",
        Flag     = "HP Bar",
        Default  = false,
        Callback = function(Value)
            HealthTextToggle:SetVisiblity(Value)
            Visuals:Update()
        end
    })

    HealthTextToggle = ESPSection:Toggle({
        Name     = "Health Text",
        Flag     = "Health Text",
        Sub      = true,
        Default  = false,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    HealthTextToggle:SetVisiblity(false)

    local NameModeDropdown

    ESPSection:Toggle({
        Name     = "Name ESP",
        Flag     = "Name ESP",
        Default  = false,
        Callback = function(Value)
            NameModeDropdown:SetVisibility(Value)
            Visuals:Update()
        end
    })

    NameModeDropdown = ESPSection:Dropdown({
        Name     = "Name Mode",
        Flag     = "Name Mode",
        Default  = "Both",
        Items    = { "Both", "Display Name", "Username" },
        Callback = function(Value)
            Visuals:Update()
        end
    })

    NameModeDropdown:SetVisibility(false)
end

return VisualsTab
