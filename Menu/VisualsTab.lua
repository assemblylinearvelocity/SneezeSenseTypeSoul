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

    local PlayerDistToggle
    local PlayerDistUnitDropdown

    PlayerDistToggle = ESPSection:Toggle({
        Name     = "Distance",
        Flag     = "Player Distance",
        Default  = false,
        Callback = function(Value)
            PlayerDistUnitDropdown:SetVisibility(Value)
            Visuals:Update()
        end
    })

    PlayerDistUnitDropdown = ESPSection:Dropdown({
        Name     = "Unit",
        Flag     = "Player Distance Unit",
        Default  = "studs",
        Items    = { "studs", "m" },
        Callback = function() Visuals:Update() end
    })
    PlayerDistUnitDropdown:SetVisibility(false)

    local MobSection = Page:Section({ Name = "Mob ESP", Side = 2 })

    local MobBoxToggle
    local MobNameToggle
    local MobHpBarToggle
    local MobHpTextToggle
    local MobDistSlider

    MobSection:Toggle({
        Name     = "Mob ESP",
        Flag     = "Mob ESP",
        Default  = false,
        Callback = function(Value)
            MobBoxToggle:SetVisiblity(Value)
            MobNameToggle:SetVisiblity(Value)
            MobHpBarToggle:SetVisiblity(Value)
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

    MobHpBarToggle = MobSection:Toggle({
        Name     = "HP Bar",
        Flag     = "Mob HP Bar",
        Sub      = true,
        Default  = false,
        Callback = function(Value)
            MobHpTextToggle:SetVisiblity(Value)
            Visuals:Update()
        end
    })

    MobHpTextToggle = MobSection:Toggle({
        Name     = "HP Text",
        Flag     = "Mob HP Text",
        Sub      = true,
        Default  = false,
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
    MobHpBarToggle:SetVisiblity(false)
    MobHpTextToggle:SetVisiblity(false)
    MobDistSlider:SetVisibility(false)

    local MobDistToggle
    local MobDistUnitDropdown

    MobDistToggle = MobSection:Toggle({
        Name     = "Show Distance",
        Flag     = "Mob Distance",
        Sub      = true,
        Default  = false,
        Callback = function(Value)
            MobDistUnitDropdown:SetVisibility(Value)
            Visuals:Update()
        end
    })

    MobDistUnitDropdown = MobSection:Dropdown({
        Name     = "Unit",
        Flag     = "Mob Distance Unit",
        Default  = "studs",
        Items    = { "studs", "m" },
        Callback = function() Visuals:Update() end
    })

    MobDistToggle:SetVisiblity(false)
    MobDistUnitDropdown:SetVisibility(false)

    local NpcSection = Page:Section({ Name = "NPC ESP", Side = 2 })

    local NpcDistSlider

    NpcSection:Toggle({
        Name     = "NPC ESP",
        Flag     = "NPC ESP",
        Default  = false,
        Callback = function(Value)
            NpcDistSlider:SetVisibility(Value)
            Visuals:Update()
        end
    }):Colorpicker({
        Name     = "NPC Color",
        Flag     = "NPC Color",
        Default  = Color3.fromRGB(100, 220, 255),
        Callback = function() Visuals:Update() end
    })

    NpcDistSlider = NpcSection:Slider({
        Name     = "Max Distance",
        Flag     = "NPC ESP Distance",
        Min      = 50,
        Max      = 5000,
        Default  = 1000,
        Decimals = 1,
        Compact  = true,
        Callback = function() Visuals:Update() end
    })

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
end

return VisualsTab
