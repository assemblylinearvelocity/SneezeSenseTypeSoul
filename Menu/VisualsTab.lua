local VisualsTab = {}

function VisualsTab.Init(Page, Visuals)
    local ESPSection = Page:Section({ Name = "Player ESP", Side = 1 })

    ESPSection:Toggle({
        Name     = "Box ESP",
        Flag     = "Box ESP",
        Default  = false,
        Callback = function() Visuals:Update() end
    }):Colorpicker({
        Name     = "Box Color",
        Flag     = "Box Color",
        Default  = Color3.fromRGB(255, 255, 255),
        Callback = function() Visuals:Update() end
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
        Callback = function() Visuals:Update() end
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
        Callback = function() Visuals:Update() end
    })
    NameModeDropdown:SetVisibility(false)

    ESPSection:Toggle({
        Name     = "Race",
        Flag     = "Race ESP",
        Default  = false,
        Callback = function() Visuals:Update() end
    })

    local MobSection = Page:Section({ Name = "Mob ESP", Side = 2 })

    local MobBoxToggle
    local MobNameToggle
    local MobHealthToggle
    local MobDistSlider

    MobSection:Toggle({
        Name     = "Mob ESP",
        Flag     = "Mob ESP",
        Default  = false,
        Callback = function(Value)
            MobBoxToggle:SetVisiblity(Value)
            MobNameToggle:SetVisiblity(Value)
            MobHealthToggle:SetVisiblity(Value)
            MobDistSlider:SetVisibility(Value)
            Visuals:Update()
        end
    }):Colorpicker({
        Name     = "Mob Color",
        Flag     = "Mob Color",
        Default  = Color3.fromRGB(255, 200, 100),
        Callback = function() Visuals:Update() end
    })

    MobBoxToggle = MobSection:Toggle({
        Name     = "Box",
        Flag     = "Mob Box",
        Sub      = true,
        Default  = true,
        Callback = function() Visuals:Update() end
    })

    MobNameToggle = MobSection:Toggle({
        Name     = "Name",
        Flag     = "Mob Name",
        Sub      = true,
        Default  = true,
        Callback = function() Visuals:Update() end
    })

    MobHealthToggle = MobSection:Toggle({
        Name     = "Health",
        Flag     = "Mob Health",
        Sub      = true,
        Default  = true,
        Callback = function() Visuals:Update() end
    })

    MobDistSlider = MobSection:Slider({
        Name     = "Distance",
        Flag     = "Mob ESP Distance",
        Min      = 50,
        Max      = 2000,
        Default  = 500,
        Decimals = 1,
        Compact  = true,
        Callback = function() Visuals:Update() end
    })

    MobBoxToggle:SetVisiblity(false)
    MobNameToggle:SetVisiblity(false)
    MobHealthToggle:SetVisiblity(false)
    MobDistSlider:SetVisibility(false)

    local NpcSection = Page:Section({ Name = "NPC ESP", Side = 2 })

    local NpcBoxToggle
    local NpcNameToggle
    local NpcDistSlider

    NpcSection:Toggle({
        Name     = "NPC ESP",
        Flag     = "NPC ESP",
        Default  = false,
        Callback = function(Value)
            NpcBoxToggle:SetVisiblity(Value)
            NpcNameToggle:SetVisiblity(Value)
            NpcDistSlider:SetVisibility(Value)
            Visuals:Update()
        end
    }):Colorpicker({
        Name     = "NPC Color",
        Flag     = "NPC Color",
        Default  = Color3.fromRGB(100, 220, 255),
        Callback = function() Visuals:Update() end
    })

    NpcBoxToggle = NpcSection:Toggle({
        Name     = "Box",
        Flag     = "NPC Box",
        Sub      = true,
        Default  = true,
        Callback = function() Visuals:Update() end
    })

    NpcNameToggle = NpcSection:Toggle({
        Name     = "Name",
        Flag     = "NPC Name",
        Sub      = true,
        Default  = true,
        Callback = function() Visuals:Update() end
    })

    NpcDistSlider = NpcSection:Slider({
        Name     = "Distance",
        Flag     = "NPC ESP Distance",
        Min      = 50,
        Max      = 2000,
        Default  = 500,
        Decimals = 1,
        Compact  = true,
        Callback = function() Visuals:Update() end
    })

    NpcBoxToggle:SetVisiblity(false)
    NpcNameToggle:SetVisiblity(false)
    NpcDistSlider:SetVisibility(false)

    local CameraSection = Page:Section({ Name = "Camera", Side = 2 })

    CameraSection:Toggle({
        Name     = "FOV Changer",
        Flag     = "FOV Changer",
        Default  = false,
        Callback = function() Visuals:Update() end
    })

    CameraSection:Slider({
        Name     = "FOV",
        Flag     = "FOV Value",
        Min      = 30,
        Max      = 120,
        Default  = 70,
        Decimals = 1,
        Compact  = true,
        Callback = function() Visuals:Update() end
    })

    CameraSection:Toggle({
        Name     = "Freecam",
        Flag     = "Freecam",
        Default  = false,
        Callback = function() Visuals:Update() end
    })

    CameraSection:Slider({
        Name     = "Freecam Speed",
        Flag     = "Freecam Speed",
        Min      = 0.1,
        Max      = 10,
        Default  = 0.5,
        Decimals = 0.1,
        Compact  = true,
        Callback = function() Visuals:Update() end
    })

    CameraSection:Slider({
        Name     = "Freecam Sens",
        Flag     = "Freecam Sens",
        Min      = 0.1,
        Max      = 5,
        Default  = 0.3,
        Decimals = 0.1,
        Compact  = true,
        Callback = function() Visuals:Update() end
    })
end

return VisualsTab
