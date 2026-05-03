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

    ESPSection:Toggle({
        Name     = "Race",
        Flag     = "Race ESP",
        Default  = false,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    local MobSection = Page:Section({ Name = "Mob & NPC ESP", Side = 2 })

    MobSection:Toggle({
        Name     = "Mob ESP",
        Flag     = "Mob ESP",
        Default  = false,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    MobSection:Slider({
        Name     = "Mob Distance",
        Flag     = "Mob ESP Distance",
        Min      = 50,
        Max      = 2000,
        Default  = 500,
        Decimals = 1,
        Compact  = true,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    MobSection:Toggle({
        Name     = "NPC ESP",
        Flag     = "NPC ESP",
        Default  = false,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    MobSection:Slider({
        Name     = "NPC Distance",
        Flag     = "NPC ESP Distance",
        Min      = 50,
        Max      = 2000,
        Default  = 500,
        Decimals = 1,
        Compact  = true,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    local CameraSection = Page:Section({ Name = "Camera", Side = 2 })

    CameraSection:Toggle({
        Name     = "FOV Changer",
        Flag     = "FOV Changer",
        Default  = false,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    CameraSection:Slider({
        Name     = "FOV",
        Flag     = "FOV Value",
        Min      = 30,
        Max      = 120,
        Default  = 70,
        Decimals = 1,
        Compact  = true,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    CameraSection:Toggle({
        Name     = "Freecam",
        Flag     = "Freecam",
        Default  = false,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    CameraSection:Slider({
        Name     = "Freecam Speed",
        Flag     = "Freecam Speed",
        Min      = 0.1,
        Max      = 10,
        Default  = 0.5,
        Decimals = 0.1,
        Compact  = true,
        Callback = function(Value)
            Visuals:Update()
        end
    })

    CameraSection:Slider({
        Name     = "Freecam Sens",
        Flag     = "Freecam Sens",
        Min      = 0.1,
        Max      = 5,
        Default  = 0.3,
        Decimals = 0.1,
        Compact  = true,
        Callback = function(Value)
            Visuals:Update()
        end
    })
end

return VisualsTab
