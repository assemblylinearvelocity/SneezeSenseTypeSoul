local MiscTab = {}

function MiscTab:Init(Page, WorldModulation, Automation, Library)
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

    WorldSection:Slider({
        Name     = "Brightness",
        Flag     = "Brightness Value",
        Min      = 0,
        Max      = 10,
        Default  = 2,
        Decimals = 0.1,
        Compact  = true,
        Callback = function(Value)
            game:GetService("Lighting").Brightness = Value
        end
    })

    local AutomationSection = Page:Section({ Name = "Automation", Side = 2 })

    local FlyToggle = AutomationSection:Toggle({
        Name     = "Fly",
        Flag     = "Fly",
        Default  = false,
        Callback = function() Automation:Update() end
    })

    AutomationSection:Label({ Name = "Fly Keybind", Alignment = "Left" }):Keybind({
        Name     = "Fly Keybind",
        Flag     = "Fly Bind",
        Default  = Enum.KeyCode.Backspace,
        Mode     = "Toggle",
        Callback = function(Value)
            local flag = Library.Flags["Fly Bind"]
            if not flag or not flag.Key or flag.Key == "Enum.KeyCode.Unknown" or flag.Key == "Enum.KeyCode.Backspace" then return end
            FlyToggle:Set(Value)
        end
    })

    AutomationSection:Slider({
        Name     = "Fly Speed",
        Flag     = "Fly Speed",
        Min      = 1,
        Max      = 200,
        Default  = 20,
        Decimals = 1,
        Compact  = true,
        Callback = function() end
    })

    local SpeedToggle = AutomationSection:Toggle({
        Name     = "Speedhack",
        Flag     = "Speedhack",
        Default  = false,
        Callback = function() Automation:Update() end
    })

    AutomationSection:Label({ Name = "Speed Keybind", Alignment = "Left" }):Keybind({
        Name     = "Speed Keybind",
        Flag     = "Speed Bind",
        Default  = Enum.KeyCode.Backspace,
        Mode     = "Toggle",
        Callback = function(Value)
            local flag = Library.Flags["Speed Bind"]
            if not flag or not flag.Key or flag.Key == "Enum.KeyCode.Unknown" or flag.Key == "Enum.KeyCode.Backspace" then return end
            SpeedToggle:Set(Value)
        end
    })

    AutomationSection:Slider({
        Name     = "Speed",
        Flag     = "Speed Value",
        Min      = 1,
        Max      = 200,
        Default  = 20,
        Decimals = 1,
        Compact  = true,
        Callback = function() end
    })

    local _mutexLock = false

    NoclipToggle = AutomationSection:Toggle({
        Name     = "Noclip",
        Flag     = "Noclip",
        Default  = false,
        Callback = function(Value)
            if _mutexLock then return end
            if Value and InfJumpToggle and Library.Flags["Inf Jump"] then
                _mutexLock = true
                InfJumpToggle:Set(false)
                _mutexLock = false
            end
            Automation:Update()
        end
    })

    AutomationSection:Label({ Name = "Noclip Keybind", Alignment = "Left" }):Keybind({
        Name     = "Noclip Keybind",
        Flag     = "Noclip Bind",
        Default  = Enum.KeyCode.Backspace,
        Mode     = "Toggle",
        Callback = function(Value)
            local flag = Library.Flags["Noclip Bind"]
            if not flag or not flag.Key or flag.Key == "Enum.KeyCode.Unknown" or flag.Key == "Enum.KeyCode.Backspace" then return end
            NoclipToggle:Set(Value)
        end
    })

    InfJumpToggle = AutomationSection:Toggle({
        Name     = "Inf Jump",
        Flag     = "Inf Jump",
        Default  = false,
        Callback = function(Value)
            if _mutexLock then return end
            if Value and NoclipToggle and Library.Flags["Noclip"] then
                _mutexLock = true
                NoclipToggle:Set(false)
                _mutexLock = false
            end
            Automation:Update()
        end
    })

    AutomationSection:Label({ Name = "Inf Jump Keybind", Alignment = "Left" }):Keybind({
        Name     = "Inf Jump Keybind",
        Flag     = "Inf Jump Bind",
        Default  = Enum.KeyCode.Backspace,
        Mode     = "Toggle",
        Callback = function(Value)
            local flag = Library.Flags["Inf Jump Bind"]
            if not flag or not flag.Key or flag.Key == "Enum.KeyCode.Unknown" or flag.Key == "Enum.KeyCode.Backspace" then return end
            InfJumpToggle:Set(Value)
        end
    })

    AutomationSection:Slider({
        Name     = "Jump Height",
        Flag     = "Jump Power",
        Min      = 1,
        Max      = 200,
        Default  = 50,
        Decimals = 1,
        Compact  = true,
        Callback = function() end
    })
end

return MiscTab
