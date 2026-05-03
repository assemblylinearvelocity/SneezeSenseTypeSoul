local SettingsTab = {}

function SettingsTab.Init(Page, Library, KeybindList, Watermark, DetachCallback)
    local SettingsSection = Page:Section({ Name = "Settings", Side = 1 })

    SettingsSection:Label({ Name = "Menu Keybind", Alignment = "Left" }):Keybind({
        Name     = "Menu Keybind",
        Flag     = "Menu Keybind",
        Default  = Enum.KeyCode.RightControl,
        Mode     = "Toggle",
        Callback = function(Value)
            local flag = Library.Flags["Menu Keybind"]
            if flag and flag.Key then
                Library.MenuKeybind = flag.Key
            end
        end
    })

    SettingsSection:Toggle({
        Name     = "Watermark",
        Flag     = "Watermark",
        Default  = true,
        Callback = function(Value)
            Watermark:SetVisibility(Value)
        end
    })

    SettingsSection:Toggle({
        Name     = "Keybind List",
        Flag     = "Keybind List",
        Default  = false,
        Callback = function(Value)
            KeybindList:SetVisibility(Value)
        end
    })

    SettingsSection:Button({
        Name     = "Unload",
        Callback = function()
            DetachCallback()
        end
    })
end

return SettingsTab
